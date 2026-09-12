import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

import '../domain/pdf_document.dart';

class LibraryController extends ChangeNotifier {
  static const String _storageKey = 'readl_library_v1';

  final List<PdfDocumentModel> _documents = [];

  bool _loading = false;
  String? _error;

  List<PdfDocumentModel> get documents => List.unmodifiable(_documents);

  bool get loading => _loading;

  String? get error => _error;

  /// Initialisation appelée par library_providers.dart.
  Future<void> init() async {
    await load();
  }

  /// Restaure la bibliothèque sauvegardée.
  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);

      _documents.clear();

      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw);

        if (decoded is List) {
          for (final item in decoded) {
            if (item is Map) {
              final document = PdfDocumentModel.fromJson(
                Map<String, dynamic>.from(item),
              );

              if (document.path.isNotEmpty &&
                  await File(document.path).exists()) {
                _documents.add(document);
              }
            }
          }
        }
      }

      await _save();
    } catch (e) {
      _error = 'Impossible de restaurer la bibliothèque.';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Importe un seul PDF.
  ///
  /// file_picker v12 retourne directement List<PlatformFile>.
  Future<PdfDocumentModel?> importPdf() async {
    _error = null;
    _loading = true;
    notifyListeners();

    try {
      final files = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
      );

      if (files.isEmpty) {
        return null;
      }

      final picked = files.first;

      final sourcePath = picked.path;

      if (sourcePath == null || sourcePath.isEmpty) {
        throw Exception(
          'Le chemin du fichier PDF est inaccessible.',
        );
      }

      final sourceFile = File(sourcePath);

      if (!await sourceFile.exists()) {
        throw Exception(
          'Le fichier PDF sélectionné n’existe plus.',
        );
      }

      final appDir = await getApplicationDocumentsDirectory();

      final pdfDir = Directory(
        '${appDir.path}/pdfs',
      );

      await pdfDir.create(
        recursive: true,
      );

      final id = DateTime.now()
          .microsecondsSinceEpoch
          .toString();

      final destination = File(
        '${pdfDir.path}/$id.pdf',
      );

      final copiedFile = await sourceFile.copy(
        destination.path,
      );

      final bytes = await copiedFile.readAsBytes();

      final pdf = PdfDocument(
        inputBytes: bytes,
      );

      try {
        final pageCount = pdf.pages.count;

        final extractor = PdfTextExtractor(pdf);

        final buffer = StringBuffer();

        for (var page = 0; page < pageCount; page++) {
          final pageText = extractor.extractText(
            startPageIndex: page,
            endPageIndex: page,
          );

          if (pageText.trim().isNotEmpty) {
            buffer.writeln(pageText.trim());
            buffer.writeln();
          }
        }

        final document = PdfDocumentModel(
          id: id,
          name: picked.name,
          path: copiedFile.path,
          size: await copiedFile.length(),
          pageCount: pageCount,
          text: buffer.toString().trim(),
          lastPage: 1,
          isFavorite: false,
          createdAt: DateTime.now(),
        );

        _documents.removeWhere(
          (existing) => existing.path == document.path,
        );

        _documents.insert(
          0,
          document,
        );

        await _save();

        notifyListeners();

        return document;
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
      (document) => document.id == id,
    );

    if (index == -1) {
      return;
    }

    final document = _documents[index];

    final safePage = page.clamp(
      1,
      document.pageCount < 1 ? 1 : document.pageCount,
    );

    _documents[index] = document.copyWith(
      lastPage: safePage,
    );

    await _save();

    notifyListeners();
  }

  /// Alias pratique pour les écrans qui utilisent update().
  Future<void> update(
    String id,
    int page,
  ) async {
    await updateProgress(
      id,
      page,
    );
  }

  /// Active/désactive le favori.
  Future<void> toggleFavorite(
    String id,
  ) async {
    final index = _documents.indexWhere(
      (document) => document.id == id,
    );

    if (index == -1) {
      return;
    }

    final document = _documents[index];

    _documents[index] = document.copyWith(
      isFavorite: !document.isFavorite,
    );

    await _save();

    notifyListeners();
  }

  /// Supprime un document de la bibliothèque et du stockage local.
  Future<void> delete(
    String id,
  ) async {
    final index = _documents.indexWhere(
      (document) => document.id == id,
    );

    if (index == -1) {
      return;
    }

    final document = _documents.removeAt(index);

    try {
      final file = File(document.path);

      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {
      // Le document est quand même retiré de la bibliothèque.
    }

    await _save();

    notifyListeners();
  }

  /// Retourne un document par son ID.
  PdfDocumentModel? getById(
    String id,
  ) {
    for (final document in _documents) {
      if (document.id == id) {
        return document;
      }
    }

    return null;
  }

  /// Retourne le texte extrait d'un document.
  String readText(
    String id,
  ) {
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
        .map(
          (document) => document.toJson(),
        )
        .toList();

    await prefs.setString(
      _storageKey,
      jsonEncode(data),
    );
  }
}