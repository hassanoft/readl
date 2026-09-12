import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'library_controller.dart';

final libraryControllerProvider = ChangeNotifierProvider<LibraryController>((ref) {
  final controller = LibraryController();
  controller.init();
  ref.onDispose(controller.dispose);
  return controller;
});
