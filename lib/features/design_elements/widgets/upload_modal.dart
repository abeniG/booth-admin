import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:booth_admin/core/responsive/responsive_layout.dart';
import 'package:booth_admin/core/theme/app_theme.dart';
import 'package:booth_admin/services/cloudinary_service.dart';
import 'package:booth_admin/services/design_asset_service.dart';
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
  final TextEditingController _nameController = TextEditingController();
  PlatformFile? _selectedFile;
  bool isActive = true;
  bool _isUploading = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.pickFiles(
      type: FileType.image,
    );

    if (result.isEmpty) return;

    setState(() {
      _selectedFile = result.first;
    });
  }

  Future<void> _saveAsset() async {
    final name = _nameController.text.trim();
    final file = _selectedFile;

    if (file == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image first.')),
      );
      return;
    }

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a name for this asset.')),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      final bytes = await _readFileBytes(file);
      final folder = '${widget.itemType.toLowerCase()}s';
      final url = await CloudinaryService.uploadImage(
        bytes,
        file.name,
        folder: folder,
      );

      try {
        await DesignAssetService.saveAsset(
          itemType: widget.itemType,
          name: name,
          url: url,
          enabled: isActive,
        );
      } catch (error) {
        throw Exception('Image uploaded, but Firestore save failed: $error');
      }

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${widget.itemType} uploaded successfully.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload failed: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  Future<Uint8List> _readFileBytes(PlatformFile file) async {
    return file.readAsBytes();
  }

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
              label: _selectedFile != null
                  ? _selectedFile!.name
                  : 'Select ${widget.itemType} Image',
              onSelectFile: _pickImage,
            ),
            if (_selectedFile != null) ...[
              const SizedBox(height: 12),
              Text(
                'Selected: ${_selectedFile!.name}',
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
            const SizedBox(height: 24),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: '${widget.itemType} Name',
                hintText: 'e.g. Vintage Frame',
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Active Status'),
              subtitle:
                  const Text('Make this element available in the Photo Booth'),
              value: isActive,
              onChanged: (val) => setState(() => isActive = val),
              activeThumbColor: AppTheme.primary,
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
                  onPressed: _isUploading ? null : _saveAsset,
                  child: _isUploading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text('Save ${widget.itemType}'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
