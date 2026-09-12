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

  List<PdfDocumentModel> get documents =>
      List.unmodifiable(_documents);

  bool get loading => _loading;

  String? get error => _error;

  /// Initialise et restaure la bibliothèque locale.
  Future<void> init() async {
    await load();
  }

  /// Restaure les PDF enregistrés localement.
  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);

      if (raw == null || raw.isEmpty) {
        return;
      }

      final decoded = jsonDecode(raw);

      if (decoded is! List) {
        throw const FormatException('Bibliothèque invalide.');
      }

      _documents
        ..clear()
        ..addAll(
          decoded
              .whereType<Map<String, dynamic>>()
              .map(PdfDocumentModel.fromJson),
        );

      // Supprime les fichiers qui n'existent plus sur l'appareil.
      _documents.removeWhere(
        (doc) => !File(doc.path).existsSync(),
      );

      await _save();
    } catch (_) {
      _error = 'Impossible de restaurer la bibliothèque.';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Importe un fichier PDF depuis l'appareil.
  Future<PdfDocumentModel?> importPdf() async {
    _error = null;
    _loading = true;
    notifyListeners();

    try {
      final picked = await FilePicker.platform.pickFile(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: false,
      );

      if (picked == null) {
        return null;
      }

      final sourcePath = picked.path;

      if (sourcePath == null) {
        throw Exception('Fichier inaccessible.');
      }

      final appDir = await getApplicationDocumentsDirectory();

      final pdfDir = Directory(
        '${appDir.path}/pdfs',
      );

      await pdfDir.create(recursive: true);

      final id = '${DateTime.now().microsecondsSinceEpoch}';

      final destination = File(
        '${pdfDir.path}/$id.pdf',
      );

      final copied = await File(sourcePath).copy(
        destination.path,
      );

      final bytes = await copied.readAsBytes();

      final pdf = PdfDocument(
        inputBytes: bytes,
      );

      try {
        final pageCount = pdf.pages.count;
        final extractor = PdfTextExtractor(pdf);
        final buffer = StringBuffer();

        for (var page = 1; page <= pageCount; page++) {
          final pageText = extractor.extractText(
            startPageIndex: page - 1,
            endPageIndex: page - 1,
          );

          if (pageText.trim().isNotEmpty) {
            buffer.writeln(pageText.trim());
            buffer.writeln();
          }
        }

        final doc = PdfDocumentModel(
          id: id,
          name: picked.name,
          path: copied.path,
          size: await copied.length(),
          pageCount: pageCount,
          text: buffer.toString().trim(),
        );

        _documents.removeWhere(
          (d) => d.name == doc.name && d.path == doc.path,
        );

        _documents.insert(0, doc);

        await _save();

        return doc;
      } finally {
        pdf.dispose();
      }
    } catch (e) {
      _error = 'Import PDF impossible : $e';
      return null;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Met à jour la dernière page consultée.
  Future<void> updateProgress(
    String id,
    int page,
  ) async {
    final index = _documents.indexWhere(
      (d) => d.id == id,
    );

    if (index < 0) {
      return;
    }

    final document = _documents[index];

    final safePage = page.clamp(
      1,
      document.pageCount,
    );

    _documents[index] = document.copyWith(
      lastPage: safePage,
    );

    await _save();
    notifyListeners();
  }

  /// Met à jour la page de lecture.
  Future<void> update(
    String id,
    int page,
  ) async {
    await updateProgress(id, page);
  }

  /// Ajoute ou retire un PDF des favoris.
  Future<void> toggleFavorite(String id) async {
    final index = _documents.indexWhere(
      (d) => d.id == id,
    );

    if (index < 0) {
      return;
    }

    final document = _documents[index];

    _documents[index] = document.copyWith(
      isFavorite: !document.isFavorite,
    );

    await _save();
    notifyListeners();
  }

  /// Supprime un PDF de la bibliothèque.
  Future<void> delete(String id) async {
    final index = _documents.indexWhere(
      (d) => d.id == id,
    );

    if (index < 0) {
      return;
    }

    final document = _documents.removeAt(index);

    try {
      await File(document.path).delete();
    } catch (_) {
      // Le fichier peut déjà avoir été supprimé.
    }

    await _save();
    notifyListeners();
  }

  /// Recherche un document par son identifiant.
  PdfDocumentModel? getById(String id) {
    for (final document in _documents) {
      if (document.id == id) {
        return document;
      }
    }

    return null;
  }

  /// Retourne le texte extrait d'un document.
  String readText(String id) {
    return getById(id)?.text ?? '';
  }

  /// Efface l'erreur actuelle.
  void clearError() {
    if (_error == null) {
      return;
    }

    _error = null;
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();

    final data = _documents
        .map((document) => document.toJson())
        .toList();

    await prefs.setString(
      _storageKey,
      jsonEncode(data),
    );
  }
}