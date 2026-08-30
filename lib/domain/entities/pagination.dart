class Pagination {
  final int totalItems;
  final int totalItemsPerPage;
  final int currentPage;
  final int totalPages;
  const Pagination({
    required this.totalItems,
    required this.totalItemsPerPage,
    required this.currentPage,
    required this.totalPages,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
        totalItems: (json['totalItems'] as num?)?.toInt() ?? 0,
        totalItemsPerPage: (json['totalItemsPerPage'] as num?)?.toInt() ?? 24,
        currentPage: (json['currentPage'] as num?)?.toInt() ?? 1,
        totalPages: (json['totalPages'] as num?)?.toInt() ?? 1,
      );

  // v1 pagination uses pageRanges instead of totalPages
  factory Pagination.fromV1Json(Map<String, dynamic> json) => Pagination(
        totalItems: (json['totalItems'] as num?)?.toInt() ?? 0,
        totalItemsPerPage: (json['totalItemsPerPage'] as num?)?.toInt() ?? 24,
        currentPage: (json['currentPage'] as num?)?.toInt() ?? 1,
        totalPages: (json['totalPages'] as num?)?.toInt() ??
            (json['pageRanges'] as num?)?.toInt() ??
            1,
      );
}

class PaginatedMovies {
  final List<dynamic> items; // will be List<Movie>
  final Pagination pagination;
  const PaginatedMovies({required this.items, required this.pagination});
}
