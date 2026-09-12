import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

import '../../../data/models/readl_document.dart';

class LibraryController extends ChangeNotifier {
  List<ReadlDocument> _documents = [];
  bool _loading = true;

  List<ReadlDocument> get documents => List.unmodifiable(_documents);
  bool get loading => _loading;

  Future<void> init() async {
    if (!_loading) return;
    try {
      final file = await _indexFile();
      if (await file.exists()) {
        final raw = jsonDecode(await file.readAsString()) as List<dynamic>;
        _documents = raw
            .map((e) => ReadlDocument.fromJson(Map<String, dynamic>.from(e as Map)))
            .where((d) => File(d.path).existsSync())
            .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      }
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<ReadlDocument?> importPdf() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return null;

    final picked = result.files.single;
    final bytes = picked.bytes ?? await File(picked.path!).readAsBytes();
    if (bytes.isEmpty) throw Exception('Le fichier PDF est vide.');

    final base = await getApplicationDocumentsDirectory();
    final pdfDir = Directory('${base.path}/readl_documents');
    await pdfDir.create(recursive: true);
    final id = '${DateTime.now().microsecondsSinceEpoch}';
    final safeName = _safeName(picked.name);
    final pdfPath = '${pdfDir.path}/$id-$safeName';
    final textPath = '${pdfDir.path}/$id.txt';
    await File(pdfPath).writeAsBytes(bytes, flush: true);

    String text = '';
    PdfDocument? pdf;
    try {
      pdf = PdfDocument(inputBytes: Uint8List.fromList(bytes));
      text = PdfTextExtractor(pdf).extractText(layoutText: true).trim();
    } finally {
      pdf?.dispose();
    }
    await File(textPath).writeAsString(text, flush: true);

    final document = ReadlDocument(
      id: id,
      name: picked.name,
      path: pdfPath,
      sizeBytes: bytes.length,
      createdAt: DateTime.now(),
      textPath: textPath,
    );
    _documents = [document, ..._documents];
    await _save();
    notifyListeners();
    return document;
  }

  Future<String> readText(ReadlDocument document) async {
    final file = File(document.textPath);
    if (!await file.exists()) return '';
    return file.readAsString();
  }

  Future<void> update(ReadlDocument document, {int? page, double? progress, bool? favorite}) async {
    final i = _documents.indexWhere((d) => d.id == document.id);
    if (i < 0) return;
    _documents[i] = document.copyWith(
      currentPage: page,
      progress: progress,
      favorite: favorite,
    );
    await _save();
    notifyListeners();
  }

  Future<void> delete(ReadlDocument document) async {
    try { await File(document.path).delete(); } catch (_) {}
    try { await File(document.textPath).delete(); } catch (_) {}
    _documents.removeWhere((d) => d.id == document.id);
    await _save();
    notifyListeners();
  }

  Future<File> _indexFile() async {
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory('${base.path}/readl_documents');
    await dir.create(recursive: true);
    return File('${dir.path}/library.json');
  }

  Future<void> _save() async => (await _indexFile()).writeAsString(
        jsonEncode(_documents.map((d) => d.toJson()).toList()),
        flush: true,
      );

  String _safeName(String name) => name.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
}
