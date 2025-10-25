import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../errors/failures.dart';

/// Error handling utilities
class ErrorHandler {
  // Handle Firebase Auth errors
  static Failure handleAuthError(FirebaseAuthException error) {
    switch (error.code) {
      case 'user-not-found':
        return AuthFailure('No user found with this email');
      case 'wrong-password':
        return AuthFailure('Incorrect password');
      case 'email-already-in-use':
        return AuthFailure('This email is already registered');
      case 'invalid-email':
        return AuthFailure('Invalid email address');
      case 'weak-password':
        return AuthFailure('Password is too weak');
      case 'user-disabled':
        return AuthFailure('This account has been disabled');
      case 'operation-not-allowed':
        return AuthFailure('Operation not allowed');
      case 'too-many-requests':
        return AuthFailure('Too many requests. Please try again later');
      case 'network-request-failed':
        return NetworkFailure('Network error. Please check your connection');
      default:
        return AuthFailure(error.message ?? 'Authentication failed');
    }
  }
  
  // Handle Firestore errors
  static Failure handleFirestoreError(FirebaseException error) {
    switch (error.code) {
      case 'permission-denied':
        return ServerFailure('Permission denied');
      case 'unavailable':
        return NetworkFailure('Service unavailable. Please try again');
      case 'not-found':
        return ServerFailure('Resource not found');
      case 'already-exists':
        return ServerFailure('Resource already exists');
      case 'resource-exhausted':
        return ServerFailure('Resource exhausted. Please try again later');
      case 'failed-precondition':
        return ServerFailure('Operation failed. Please try again');
      case 'aborted':
        return ServerFailure('Operation aborted. Please try again');
      case 'out-of-range':
        return ServerFailure('Invalid operation');
      case 'unimplemented':
        return ServerFailure('Operation not supported');
      case 'internal':
        return ServerFailure('Internal server error');
      case 'data-loss':
        return ServerFailure('Data loss occurred');
      case 'unauthenticated':
        return AuthFailure('Please sign in to continue');
      default:
        return ServerFailure(error.message ?? 'An error occurred');
    }
  }
  
  // Handle generic errors
  static Failure handleError(dynamic error) {
    if (error is FirebaseAuthException) {
      return handleAuthError(error);
    } else if (error is FirebaseException) {
      return handleFirestoreError(error);
    } else if (error is Failure) {
      return error;
    } else {
      return ServerFailure(error.toString());
    }
  }
  
  // Get user-friendly error message
  static String getUserMessage(Failure failure) {
    if (failure is NetworkFailure) {
      return 'Network error. Please check your internet connection';
    } else if (failure is AuthFailure) {
      return failure.message;
    } else if (failure is ServerFailure) {
      return failure.message;
    } else if (failure is CacheFailure) {
      return 'Local storage error';
    } else if (failure is ValidationFailure) {
      return failure.message;
    } else {
      return 'An unexpected error occurred';
    }
  }
  
  // Log error
  static void logError(dynamic error, [StackTrace? stackTrace]) {
    // In production, send to crash reporting service
    print('Error: $error');
    if (stackTrace != null) {
      print('Stack trace: $stackTrace');
    }
  }
  
  // Check if error is network related
  static bool isNetworkError(dynamic error) {
    if (error is FirebaseException) {
      return error.code == 'network-request-failed' ||
          error.code == 'unavailable';
    }
    return error is NetworkFailure;
  }
  
  // Check if error is auth related
  static bool isAuthError(dynamic error) {
    return error is FirebaseAuthException || error is AuthFailure;
  }
  
  // Check if error is permission related
  static bool isPermissionError(dynamic error) {
    if (error is FirebaseException) {
      return error.code == 'permission-denied';
    }
    return false;
  }
}
