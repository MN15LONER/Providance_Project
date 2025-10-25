import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../constants/app_constants.dart';

/// Image processing utilities
class ImageUtils {
  static const _uuid = Uuid();
  
  // Compress image to specified size
  static Future<File?> compressImage(
    File file, {
    int maxSizeMB = AppConstants.maxImageSizeMB,
    int quality = 85,
  }) async {
    try {
      final filePath = file.absolute.path;
      final fileSize = await file.length();
      final maxSizeBytes = maxSizeMB * 1024 * 1024;
      
      // If file is already small enough, return it
      if (fileSize <= maxSizeBytes) {
        return file;
      }
      
      // Create output path
      final dir = path.dirname(filePath);
      final fileName = path.basenameWithoutExtension(filePath);
      final ext = path.extension(filePath);
      final targetPath = path.join(dir, '${fileName}_compressed$ext');
      
      // Compress image
      final result = await FlutterImageCompress.compressAndGetFile(
        filePath,
        targetPath,
        quality: quality,
        minWidth: 1920,
        minHeight: 1080,
      );
      
      if (result == null) return null;
      
      // Check if compressed file is still too large
      final compressedFile = File(result.path);
      final compressedSize = await compressedFile.length();
      
      if (compressedSize > maxSizeBytes && quality > 50) {
        // Try again with lower quality
        return compressImage(file, maxSizeMB: maxSizeMB, quality: quality - 10);
      }
      
      return compressedFile;
    } catch (e) {
      return null;
    }
  }
  
  // Compress multiple images
  static Future<List<File>> compressImages(
    List<File> files, {
    int maxSizeMB = AppConstants.maxImageSizeMB,
  }) async {
    final compressed = <File>[];
    
    for (final file in files) {
      final result = await compressImage(file, maxSizeMB: maxSizeMB);
      if (result != null) {
        compressed.add(result);
      }
    }
    
    return compressed;
  }
  
  // Generate unique filename
  static String generateFileName(String extension) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final uuid = _uuid.v4().substring(0, 8);
    return '${timestamp}_$uuid$extension';
  }
  
  // Get file extension
  static String getFileExtension(String filePath) {
    return path.extension(filePath).toLowerCase();
  }
  
  // Check if file is an image
  static bool isImageFile(String filePath) {
    final ext = getFileExtension(filePath);
    return ['.jpg', '.jpeg', '.png', '.gif', '.webp'].contains(ext);
  }
  
  // Get file size in MB
  static Future<double> getFileSizeMB(File file) async {
    final bytes = await file.length();
    return bytes / (1024 * 1024);
  }
  
  // Validate image file
  static Future<String?> validateImage(File file) async {
    // Check if file exists
    if (!await file.exists()) {
      return 'File does not exist';
    }
    
    // Check if file is an image
    if (!isImageFile(file.path)) {
      return 'File is not a valid image';
    }
    
    // Check file size
    final sizeMB = await getFileSizeMB(file);
    if (sizeMB > AppConstants.maxImageSizeMB * 2) {
      // Allow 2x max size before compression
      return 'Image is too large (max ${AppConstants.maxImageSizeMB * 2}MB)';
    }
    
    return null;
  }
  
  // Validate multiple images
  static Future<String?> validateImages(List<File> files) async {
    if (files.isEmpty) {
      return 'Please select at least one image';
    }
    
    if (files.length > AppConstants.maxPhotos) {
      return 'Maximum ${AppConstants.maxPhotos} images allowed';
    }
    
    for (final file in files) {
      final error = await validateImage(file);
      if (error != null) return error;
    }
    
    return null;
  }
  
  // Delete temporary files
  static Future<void> deleteTempFiles(List<File> files) async {
    for (final file in files) {
      try {
        if (await file.exists()) {
          await file.delete();
        }
      } catch (e) {
        // Ignore errors
      }
    }
  }
  
  // Get image dimensions
  static Future<Map<String, int>?> getImageDimensions(File file) async {
    try {
      final bytes = await file.readAsBytes();
      final image = await decodeImageFromList(bytes);
      return {
        'width': image.width,
        'height': image.height,
      };
    } catch (e) {
      return null;
    }
  }
  
  // Decode image from bytes
  static Future<dynamic> decodeImageFromList(List<int> bytes) async {
    // This would require flutter's image package
    // For now, return null
    return null;
  }
  
  /// Upload image to Firebase Storage
  static Future<String> uploadToStorage(
    File file,
    String storagePath, {
    String? userId,
    Map<String, String>? metadata,
  }) async {
    try {
      // Generate unique filename
      final extension = getFileExtension(file.path);
      final fileName = generateFileName(extension);
      final fullPath = '$storagePath/$fileName';
      
      // Create storage reference
      final ref = FirebaseStorage.instance.ref().child(fullPath);
      
      // Prepare metadata
      final uploadMetadata = SettableMetadata(
        contentType: _getContentType(extension),
        customMetadata: {
          'uploadedAt': DateTime.now().toIso8601String(),
          if (userId != null) 'uploadedBy': userId,
          ...?metadata,
        },
      );
      
      // Upload file
      final uploadTask = await ref.putFile(file, uploadMetadata);
      
      // Get download URL
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }
  
  /// Upload multiple images to Firebase Storage
  static Future<List<String>> uploadMultipleToStorage(
    List<File> files,
    String storagePath, {
    String? userId,
    Map<String, String>? metadata,
  }) async {
    final urls = <String>[];
    
    for (final file in files) {
      try {
        final url = await uploadToStorage(
          file,
          storagePath,
          userId: userId,
          metadata: metadata,
        );
        urls.add(url);
      } catch (e) {
        // Continue with other files even if one fails
        continue;
      }
    }
    
    return urls;
  }
  
  /// Delete image from Firebase Storage
  static Future<void> deleteFromStorage(String downloadUrl) async {
    try {
      final ref = FirebaseStorage.instance.refFromURL(downloadUrl);
      await ref.delete();
    } catch (e) {
      // Ignore errors (file might not exist)
    }
  }
  
  /// Delete multiple images from Firebase Storage
  static Future<void> deleteMultipleFromStorage(List<String> downloadUrls) async {
    for (final url in downloadUrls) {
      await deleteFromStorage(url);
    }
  }
  
  /// Get content type from file extension
  static String _getContentType(String extension) {
    switch (extension.toLowerCase()) {
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      case '.gif':
        return 'image/gif';
      case '.webp':
        return 'image/webp';
      default:
        return 'application/octet-stream';
    }
  }
}
