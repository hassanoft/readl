import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

import '../domain/pdf_document.dart';

class LibraryController extends ChangeNotifier {
  static const _storageKey = 'readl_library_v1';

  final List<PdfDocumentModel> _documents = [];
  bool _loading = false;
  String? _error;

  List<PdfDocumentModel> get documents => List.unmodifiable(_documents);
  bool get loading => _loading;
  String? get error => _error;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) return;
    try {
      final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
      _documents
        ..clear()
        ..addAll(list.map(PdfDocumentModel.fromJson));
      _documents.removeWhere((doc) => !File(doc.path).existsSync());
      await _save();
      notifyListeners();
    } catch (_) {
      _error = 'Impossible de restaurer la bibliothèque.';
      notifyListeners();
    }
  }

  Future<PdfDocumentModel?> importPdf() async {
    _error = null;
    _loading = true;
    notifyListeners();
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: false,
      );
      if (result == null || result.files.isEmpty) return null;

      final picked = result.files.single;
      final sourcePath = picked.path;
      if (sourcePath == null) throw Exception('Fichier inaccessible.');

      final appDir = await getApplicationDocumentsDirectory();
      final pdfDir = Directory('${appDir.path}/pdfs');
      await pdfDir.create(recursive: true);
      final id = '${DateTime.now().microsecondsSinceEpoch}';
      final destination = File('${pdfDir.path}/$id.pdf');
      final copied = await File(sourcePath).copy(destination.path);

      final bytes = await copied.readAsBytes();
      final pdf = PdfDocument(inputBytes: bytes);
      final pageCount = pdf.pages.count;
      final extractor = PdfTextExtractor(pdf);
      final buffer = StringBuffer();
      for (var page = 1; page <= pageCount; page++) {
        final pageText = extractor.extractText(startPageIndex: page - 1, endPageIndex: page - 1);
        if (pageText.trim().isNotEmpty) {
          buffer.writeln(pageText.trim());
          buffer.writeln();
        }
      }
      pdf.dispose();

      final doc = PdfDocumentModel(
        id: id,
        name: picked.name,
        path: copied.path,
        size: await copied.length(),
        pageCount: pageCount,
        text: buffer.toString().trim(),
      );
      _documents.removeWhere((d) => d.name == doc.name && d.path == doc.path);
      _documents.insert(0, doc);
      await _save();
      notifyListeners();
      return doc;
    } catch (e) {
      _error = 'Import PDF impossible : $e';
      notifyListeners();
      return null;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> updateProgress(String id, int page) async {
    final index = _documents.indexWhere((d) => d.id == id);
    if (index < 0) return;
    _documents[index] = _documents[index].copyWith(lastPage: page.clamp(1, _documents[index].pageCount));
    await _save();
    notifyListeners();
  }

  Future<void> toggleFavorite(String id) async {
    final index = _documents.indexWhere((d) => d.id == id);
    if (index < 0) return;
    _documents[index] = _documents[index].copyWith(isFavorite: !_documents[index].isFavorite);
    await _save();
    notifyListeners();
  }

  Future<void> delete(String id) async {
    final index = _documents.indexWhere((d) => d.id == id);
    if (index < 0) return;
    final doc = _documents.removeAt(index);
    try { await File(doc.path).delete(); } catch (_) {}
    await _save();
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(_documents.map((d) => d.toJson()).toList()));
  }
}
