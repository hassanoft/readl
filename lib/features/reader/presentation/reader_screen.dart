import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../../../data/models/readl_document.dart';
import '../../library/application/library_providers.dart';
import '../application/tts_controller.dart';

class ReaderScreen extends ConsumerStatefulWidget {
  const ReaderScreen({super.key, required this.document});
  final ReadlDocument document;
  @override ConsumerState<ReaderScreen> createState() => _ReaderScreenState();
}
class _ReaderScreenState extends ConsumerState<ReaderScreen> {
  final _tts = TtsController();
  final _pdf = PdfViewerController();
  String _text = ''; String? _error; bool _loading = true;
  @override void initState() { super.initState(); _tts.addListener(_refresh); _load(); }
  void _refresh() { if (mounted) setState(() {}); }
  Future<void> _load() async {
    try {
      _text = await ref.read(libraryControllerProvider).readText(widget.document);
      if (_text.isEmpty) _error = 'Aucun texte extractible. Ce PDF est peut-être scanné.';
    } catch (_) { _error = 'Impossible d’extraire le texte de ce PDF.'; }
    if (mounted) setState(() => _loading = false);
  }
  @override void dispose() { _tts.removeListener(_refresh); _tts.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(widget.document.name, maxLines: 1, overflow: TextOverflow.ellipsis), actions: [
      IconButton(onPressed: _text.isEmpty ? null : _showText, icon: const Icon(Icons.text_snippet_outlined)),
    ]),
    body: Column(children: [
      Expanded(child: SfPdfViewer.file(File(widget.document.path), controller: _pdf,
        onPageChanged: (d) => ref.read(libraryControllerProvider).update(widget.document, page: d.newPageNumber))),
      _player(),
    ]),
  );
  Widget _player() => Material(elevation: 8, child: SafeArea(top: false, child: Padding(
    padding: const EdgeInsets.fromLTRB(12, 8, 12, 8), child: Column(children: [
      if (_loading) const LinearProgressIndicator(minHeight: 2),
      if (_error != null) Padding(padding: const EdgeInsets.only(bottom: 4), child: Text(_error!, style: const TextStyle(fontSize: 12, color: Colors.orange))),
      Row(children: [
        IconButton(onPressed: _text.isEmpty ? null : _tts.stop, icon: const Icon(Icons.stop_circle_outlined)),
        Expanded(child: Text(_tts.speaking ? (_tts.paused ? 'En pause' : 'Lecture en cours…') : 'Prêt à lire', style: const TextStyle(fontWeight: FontWeight.w600))),
        IconButton.filled(onPressed: _text.isEmpty ? null : () async {
          if (_tts.speaking && !_tts.paused) await _tts.pause(); else if (_tts.paused) await _tts.resume(); else await _tts.play(_text);
        }, icon: Icon(_tts.speaking && !_tts.paused ? Icons.pause : Icons.play_arrow)),
        PopupMenuButton<double>(onSelected: _tts.setRate, itemBuilder: (_) => [for (final v in [.35,.48,.6,.75,.9]) PopupMenuItem(value: v, child: Text('${v}x'))], child: Padding(padding: const EdgeInsets.all(8), child: Text('${_tts.rate.toStringAsFixed(2)}x'))),
      ]),
    ]),
  )));
  void _showText() => showModalBottomSheet(context: context, isScrollControlled: true, builder: (_) => DraggableScrollableSheet(expand: false, initialChildSize: .75, builder: (_, c) => Padding(padding: const EdgeInsets.all(16), child: SingleChildScrollView(controller: c, child: Text(_text)))));
}
