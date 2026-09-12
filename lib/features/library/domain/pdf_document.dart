import 'dart:convert';

class PdfDocumentModel {
  final String id;
  final String name;
  final String path;
  final int size;
  final int pageCount;
  final String text;
  final int lastPage;
  final bool isFavorite;
  final DateTime createdAt;

  const PdfDocumentModel({
    required this.id,
    required this.name,
    required this.path,
    required this.size,
    required this.pageCount,
    required this.text,
    this.lastPage = 1,
    this.isFavorite = false,
    required this.createdAt,
  });

  PdfDocumentModel copyWith({
    String? id,
    String? name,
    String? path,
    int? size,
    int? pageCount,
    String? text,
    int? lastPage,
    bool? isFavorite,
    DateTime? createdAt,
  }) {
    return PdfDocumentModel(
      id: id ?? this.id,
      name: name ?? this.name,
      path: path ?? this.path,
      size: size ?? this.size,
      pageCount: pageCount ?? this.pageCount,
      text: text ?? this.text,
      lastPage: lastPage ?? this.lastPage,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'path': path,
      'size': size,
      'pageCount': pageCount,
      'text': text,
      'lastPage': lastPage,
      'isFavorite': isFavorite,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory PdfDocumentModel.fromJson(Map<String, dynamic> json) {
    return PdfDocumentModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Document PDF',
      path: json['path']?.toString() ?? '',
      size: _toInt(json['size']),
      pageCount: _toInt(json['pageCount'], fallback: 1),
      text: json['text']?.toString() ?? '',
      lastPage: _toInt(json['lastPage'], fallback: 1),
      isFavorite: json['isFavorite'] == true,
      createdAt: DateTime.tryParse(
            json['createdAt']?.toString() ?? '',
          ) ??
          DateTime.now(),
    );
  }

  String encode() => jsonEncode(toJson());

  factory PdfDocumentModel.decode(String source) {
    return PdfDocumentModel.fromJson(
      jsonDecode(source) as Map<String, dynamic>,
    );
  }

  static int _toInt(
    dynamic value, {
    int fallback = 0,
  }) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }
}