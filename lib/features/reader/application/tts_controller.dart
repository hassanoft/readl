import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TtsController extends ChangeNotifier {
  TtsController() {
    _tts.awaitSpeakCompletion(true);
    _tts.setStartHandler(() { _speaking = true; notifyListeners(); });
    _tts.setCompletionHandler(() { _speaking = false; notifyListeners(); });
    _tts.setCancelHandler(() { _speaking = false; notifyListeners(); });
    _tts.setErrorHandler((_) { _speaking = false; notifyListeners(); });
  }
  final FlutterTts _tts = FlutterTts();
  bool _speaking = false, _paused = false;
  double _rate = 0.48;
  int _token = 0, _chunkIndex = 0;
  List<String> _chunks = [];
  bool get speaking => _speaking;
  bool get paused => _paused;
  double get rate => _rate;

  Future<void> configure() async {
    await _tts.setLanguage('fr-FR');
    await _tts.setSpeechRate(_rate);
    await _tts.setVolume(1);
    await _tts.setPitch(1);
  }

  Future<void> play(String text) async {
    if (text.trim().isEmpty) return;
    await configure();
    final token = ++_token;
    _chunks = _split(text); _chunkIndex = 0; _paused = false; notifyListeners();
    while (_chunkIndex < _chunks.length && token == _token) {
      await _tts.speak(_chunks[_chunkIndex]);
      if (token != _token) break;
      _chunkIndex++;
    }
    if (token == _token) { _speaking = false; _paused = false; notifyListeners(); }
  }

  Future<void> pause() async { _paused = true; await _tts.pause(); notifyListeners(); }
  Future<void> resume() async {
    _paused = false;
    if (_chunkIndex < _chunks.length) await _tts.speak(_chunks[_chunkIndex]);
    notifyListeners();
  }
  Future<void> stop() async { ++_token; await _tts.stop(); _speaking = false; _paused = false; notifyListeners(); }
  Future<void> setRate(double value) async { _rate = value.clamp(.25, .9); await _tts.setSpeechRate(_rate); notifyListeners(); }

  List<String> _split(String text) {
    final clean = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    const max = 2800; final result = <String>[]; var rest = clean;
    while (rest.length > max) {
      var cut = rest.lastIndexOf(RegExp(r'[.!?;:]'), max);
      if (cut < 500) cut = rest.lastIndexOf(' ', max);
      if (cut < 1) cut = max;
      result.add(rest.substring(0, cut + 1).trim()); rest = rest.substring(cut + 1).trim();
    }
    if (rest.isNotEmpty) result.add(rest); return result;
  }
  @override void dispose() { _tts.stop(); super.dispose(); }
}
