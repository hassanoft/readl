import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../reader/presentation/reader_screen.dart';
import '../application/library_providers.dart';
import '../domain/pdf_document.dart';

class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key, this.onImportPdf});

  final VoidCallback? onImportPdf;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final library = ref.watch(libraryControllerProvider);
    final docs = library.documents;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bibliothèque'),
      ),
      body: library.loading && docs.isEmpty
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : docs.isEmpty
              ? _Empty(
                  onImportPdf: onImportPdf,
                )
              : RefreshIndicator(
                  onRefresh: () =>
                      ref.read(libraryControllerProvider).load(),
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(
                      16,
                      16,
                      16,
                      120,
                    ),
                    itemCount: docs.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 10),
                    itemBuilder: (context, index) => _PdfTile(
                      document: docs[index],
                    ),
                  ),
                ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({this.onImportPdf});

  final VoidCallback? onImportPdf;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: const BoxDecoration(
                color: AppColors.primaryGreenLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.picture_as_pdf_rounded,
                size: 44,
                color: AppColors.primaryGreen,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Aucun PDF',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Importez un PDF pour le lire et l’écouter.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onImportPdf,
              icon: const Icon(Icons.upload_file_rounded),
              label: const Text('Importer un PDF'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PdfTile extends ConsumerWidget {
  const _PdfTile({
    required this.document,
  });

  final PdfDocumentModel document;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = document.pageCount == 0
        ? 0.0
        : document.lastPage / document.pageCount;

    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 6,
        ),
        leading: const CircleAvatar(
          backgroundColor: AppColors.primaryGreenLight,
          child: Icon(
            Icons.picture_as_pdf_rounded,
            color: AppColors.primaryGreen,
          ),
        ),
        title: Text(
          document.name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              '${document.pageCount} pages • '
              '${_size(document.size)} • '
              'page ${document.lastPage}',
            ),
            const SizedBox(height: 6),
            LinearProgressIndicator(
              value: progress,
              minHeight: 4,
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) async {
            final controller =
                ref.read(libraryControllerProvider);

            if (value == 'favorite') {
              await controller.toggleFavorite(document.id);
            } else if (value == 'delete') {
              await controller.delete(document.id);
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'favorite',
              child: Text(
                document.isFavorite
                    ? 'Retirer des favoris'
                    : 'Ajouter aux favoris',
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Text('Supprimer'),
            ),
          ],
        ),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ReaderScreen(
                document: document,
              ),
            ),
          );
        },
      ),
    );
  }
}

String _size(int bytes) {
  if (bytes < 1024) {
    return '$bytes o';
  }

  if (bytes < 1024 * 1024) {
    return '${(bytes / 1024).toStringAsFixed(1)} Ko';
  }

  return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} Mo';
}