class ReadlDocument {
  const ReadlDocument({
    required this.id,
    required this.name,
    required this.path,
    required this.sizeBytes,
    required this.createdAt,
    required this.textPath,
    this.currentPage = 1,
    this.progress = 0,
    this.favorite = false,
  });

  final String id;
  final String name;
  final String path;
  final int sizeBytes;
  final DateTime createdAt;
  final String textPath;
  final int currentPage;
  final double progress;
  final bool favorite;

  ReadlDocument copyWith({
    String? name,
    int? currentPage,
    double? progress,
    bool? favorite,
  }) => ReadlDocument(
        id: id,
        name: name ?? this.name,
        path: path,
        sizeBytes: sizeBytes,
        createdAt: createdAt,
        textPath: textPath,
        currentPage: currentPage ?? this.currentPage,
        progress: progress ?? this.progress,
        favorite: favorite ?? this.favorite,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'path': path,
        'sizeBytes': sizeBytes,
        'createdAt': createdAt.toIso8601String(),
        'textPath': textPath,
        'currentPage': currentPage,
        'progress': progress,
        'favorite': favorite,
      };

  factory ReadlDocument.fromJson(Map<String, dynamic> json) => ReadlDocument(
        id: json['id'] as String,
        name: json['name'] as String,
        path: json['path'] as String,
        sizeBytes: (json['sizeBytes'] as num).toInt(),
        createdAt: DateTime.parse(json['createdAt'] as String),
        textPath: json['textPath'] as String,
        currentPage: (json['currentPage'] as num?)?.toInt() ?? 1,
        progress: (json['progress'] as num?)?.toDouble() ?? 0,
        favorite: json['favorite'] as bool? ?? false,
      );
}
