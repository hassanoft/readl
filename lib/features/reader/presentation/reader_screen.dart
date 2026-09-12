import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../../library/application/library_providers.dart';
import '../../library/domain/pdf_document.dart';
import '../application/tts_controller.dart';

class ReaderScreen extends ConsumerStatefulWidget {
  const ReaderScreen({
    super.key,
    required this.document,
  });

  final PdfDocumentModel document;

  @override
  ConsumerState<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends ConsumerState<ReaderScreen> {
  final _tts = TtsController();
  final _pdf = PdfViewerController();

  String _text = '';
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tts.addListener(_refresh);
    _load();
  }

  void _refresh() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _load() async {
    try {
      final controller = ref.read(libraryControllerProvider);

      // Le texte est déjà stocké dans PdfDocumentModel
      _text = widget.document.text;

      if (_text.trim().isEmpty) {
        _error =
            'Aucun texte extractible. Ce PDF est peut-être scanné.';
      }
    } catch (_) {
      _error = 'Impossible d’extraire le texte de ce PDF.';
    }

    if (mounted) {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _tts.removeListener(_refresh);
    _tts.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.document.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            onPressed: _text.trim().isEmpty ? null : _showText,
            icon: const Icon(Icons.text_snippet_outlined),
            tooltip: 'Voir le texte',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SfPdfViewer.file(
              File(widget.document.path),
              controller: _pdf,
              onPageChanged: (details) {
                ref
                    .read(libraryControllerProvider)
                    .updateProgress(
                      widget.document.id,
                      details.newPageNumber,
                    );
              },
            ),
          ),
          _player(),
        ],
      ),
    );
  }

  Widget _player() {
    return Material(
      elevation: 8,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          child: Column(
            children: [
              if (_loading)
                const LinearProgressIndicator(
                  minHeight: 2,
                ),

              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    _error!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.orange,
                    ),
                  ),
                ),

              Row(
                children: [
                  IconButton(
                    onPressed: _text.trim().isEmpty
                        ? null
                        : _tts.stop,
                    icon: const Icon(
                      Icons.stop_circle_outlined,
                    ),
                    tooltip: 'Arrêter',
                  ),

                  Expanded(
                    child: Text(
                      _tts.speaking
                          ? (_tts.paused
                              ? 'En pause'
                              : 'Lecture en cours…')
                          : 'Prêt à lire',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  IconButton.filled(
                    onPressed: _text.trim().isEmpty
                        ? null
                        : () async {
                            if (_tts.speaking &&
                                !_tts.paused) {
                              await _tts.pause();
                            } else if (_tts.paused) {
                              await _tts.resume();
                            } else {
                              await _tts.play(_text);
                            }
                          },
                    icon: Icon(
                      _tts.speaking && !_tts.paused
                          ? Icons.pause
                          : Icons.play_arrow,
                    ),
                    tooltip: 'Lire / Pause',
                  ),

                  PopupMenuButton<double>(
                    onSelected: _tts.setRate,
                    itemBuilder: (_) => [
                      for (final rate in [
                        0.35,
                        0.48,
                        0.60,
                        0.75,
                        0.90,
                      ])
                        PopupMenuItem(
                          value: rate,
                          child: Text('${rate}x'),
                        ),
                    ],
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        '${_tts.rate.toStringAsFixed(2)}x',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showText() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.75,
          builder: (_, controller) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                controller: controller,
                child: Text(_text),
              ),
            );
          },
        );
      },
    );
  }
}