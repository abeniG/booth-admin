import 'package:flutter/material.dart';
import 'package:booth_admin/features/design_elements/widgets/design_element_grid.dart';
import 'package:booth_admin/features/design_elements/widgets/upload_modal.dart';

class StickersScreen extends StatelessWidget {
  const StickersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DesignElementGrid(
      title: 'Stickers',
      itemType: 'Sticker',
      onUploadPressed: () => UploadModal.show(context, 'Sticker'),
    );
  }
}

class BackgroundsScreen extends StatelessWidget {
  const BackgroundsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DesignElementGrid(
      title: 'Backgrounds',
      itemType: 'Background',
      onUploadPressed: () => UploadModal.show(context, 'Background'),
    );
  }
}

class FiltersScreen extends StatelessWidget {
  const FiltersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Note: Filters usually might just be definitions and not images,
    // but the UI behaves the same out of the box for editing.
    return DesignElementGrid(
      title: 'Filters',
      itemType: 'Filter',
      onUploadPressed: () => UploadModal.show(context, 'Filter'),
    );
  }
}

class CoverPagesScreen extends StatelessWidget {
  const CoverPagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DesignElementGrid(
      title: 'Cover Pages',
      itemType: 'Cover Page',
      onUploadPressed: () => UploadModal.show(context, 'Cover Page'),
    );
  }
}
