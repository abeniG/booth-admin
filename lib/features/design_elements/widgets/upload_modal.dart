import 'package:flutter/material.dart';
import 'package:booth_admin/core/responsive/responsive_layout.dart';
import 'package:booth_admin/core/theme/app_theme.dart';
import 'package:booth_admin/shared/widgets/upload_zone.dart';

class UploadModal extends StatefulWidget {
  final String itemType; // 'Sticker', 'Background', 'Filter'

  const UploadModal({super.key, required this.itemType});

  static void show(BuildContext context, String itemType) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        insetPadding:
            EdgeInsets.all(ResponsiveLayout.isMobile(context) ? 16 : 40),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: UploadModal(itemType: itemType),
        ),
      ),
    );
  }

  @override
  State<UploadModal> createState() => _UploadModalState();
}

class _UploadModalState extends State<UploadModal> {
  bool isActive = true;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Upload ${widget.itemType}',
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
                CloseButton(onPressed: () => Navigator.pop(context)),
              ],
            ),
            const SizedBox(height: 24),
            UploadZone(
              label: 'Select ${widget.itemType} Image',
              onSelectFile: () {
                // Mock selection
              },
            ),
            const SizedBox(height: 24),
            TextField(
              decoration: InputDecoration(
                labelText: '${widget.itemType} Name',
                hintText: 'e.g. Vintage Frame',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Category',
                hintText: 'e.g. Wedding, Birthday',
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Active Status'),
              subtitle:
                  const Text('Make this element available in the Photo Booth'),
              value: isActive,
              onChanged: (val) => setState(() => isActive = val),
              activeColor: AppTheme.primary,
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    // Mock upload
                    Navigator.pop(context);
                  },
                  child: Text('Save ${widget.itemType}'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
