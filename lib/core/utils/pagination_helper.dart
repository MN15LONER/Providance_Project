import 'package:cloud_firestore/cloud_firestore.dart';

/// Pagination helper for Firestore queries
class PaginationHelper<T> {
  final int pageSize;
  DocumentSnapshot? lastDocument;
  bool hasMore = true;
  
  PaginationHelper({this.pageSize = 20});
  
  /// Get paginated query
  Query<Map<String, dynamic>> getPaginatedQuery(
    Query<Map<String, dynamic>> baseQuery,
  ) {
    Query<Map<String, dynamic>> query = baseQuery.limit(pageSize);
    
    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument!);
    }
    
    return query;
  }
  
  /// Update pagination state after fetching
  void updateState(List<DocumentSnapshot> documents) {
    if (documents.length < pageSize) {
      hasMore = false;
    }
    
    if (documents.isNotEmpty) {
      lastDocument = documents.last;
    }
  }
  
  /// Reset pagination
  void reset() {
    lastDocument = null;
    hasMore = true;
  }
}

/// Paginated data result
class PaginatedResult<T> {
  final List<T> items;
  final bool hasMore;
  final DocumentSnapshot? lastDocument;
  
  const PaginatedResult({
    required this.items,
    required this.hasMore,
    this.lastDocument,
  });
  
  PaginatedResult<T> copyWith({
    List<T>? items,
    bool? hasMore,
    DocumentSnapshot? lastDocument,
  }) {
    return PaginatedResult<T>(
      items: items ?? this.items,
      hasMore: hasMore ?? this.hasMore,
      lastDocument: lastDocument ?? this.lastDocument,
    );
  }
}
