import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../application/library_providers.dart';

class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key, this.onImportPdf});
  final VoidCallback? onImportPdf;
  @override Widget build(BuildContext context, WidgetRef ref) {
    final library = ref.watch(libraryControllerProvider);
    if (library.loading) return const Center(child: CircularProgressIndicator());
    final docs = library.documents;
    return Scaffold(appBar: AppBar(title: const Text('Bibliothèque')),
      body: docs.isEmpty ? _empty(onImportPdf) : ListView.separated(padding: const EdgeInsets.fromLTRB(16, 12, 16, 100), itemCount: docs.length, separatorBuilder: (_, __) => const SizedBox(height: 8), itemBuilder: (_, i) {
        final d = docs[i];
        return Card(child: ListTile(onTap: () => context.push(AppRoutes.reader, extra: d), leading: const CircleAvatar(backgroundColor: AppColors.primaryGreenLight, child: Icon(Icons.picture_as_pdf, color: AppColors.primaryGreen)), title: Text(d.name, maxLines: 2, overflow: TextOverflow.ellipsis), subtitle: Text(_size(d.sizeBytes) + (d.currentPage > 1 ? ' • page ${d.currentPage}' : '')), trailing: PopupMenuButton<String>(onSelected: (v) async { if (v == 'delete') await library.delete(d); if (v == 'fav') await library.update(d, favorite: !d.favorite); }, itemBuilder: (_) => [PopupMenuItem(value: 'fav', child: Text(d.favorite ? 'Retirer des favoris' : 'Ajouter aux favoris')), const PopupMenuItem(value: 'delete', child: Text('Supprimer'))])));
      }));
  }
  Widget _empty(VoidCallback? onImport) => Center(child: Padding(padding: const EdgeInsets.all(32), child: Column(mainAxisSize: MainAxisSize.min, children: [Container(width: 96,height:96,decoration: const BoxDecoration(color: AppColors.primaryGreenLight,shape: BoxShape.circle),child: const Icon(Icons.folder_open_rounded,size:42,color:AppColors.primaryGreen)), const SizedBox(height:20), const Text('Aucun document pour le moment', style: TextStyle(fontSize:17,fontWeight:FontWeight.w700)), const SizedBox(height:8), const Text('Importez votre premier PDF pour commencer à l’écouter.',textAlign:TextAlign.center,style:TextStyle(color:AppColors.textSecondary)), const SizedBox(height:20), FilledButton.icon(onPressed:onImport, icon:const Icon(Icons.upload_file_rounded), label:const Text('Importer un PDF'))])));
  String _size(int bytes) { if (bytes < 1024*1024) return '${(bytes/1024).toStringAsFixed(0)} Ko'; return '${(bytes/(1024*1024)).toStringAsFixed(1)} Mo'; }
}
