import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:booth_admin/core/responsive/responsive_layout.dart';
import 'package:booth_admin/core/theme/app_theme.dart';
import 'package:booth_admin/models/printable.dart';
import 'package:booth_admin/services/print_service.dart';
import 'package:booth_admin/services/printable_service.dart';

class PrintablesScreen extends StatelessWidget {
  const PrintablesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaxWidthContainer(
      child: Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(24),
              child: Text('Printables',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            ),
            Expanded(
              child: StreamBuilder<List<Printable>>(
                stream: PrintableService.streamPrintables(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                        child: Text(
                            'Failed to load printables: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final printables = snapshot.data!;
                  if (printables.isEmpty) {
                    return const Center(child: Text('No printables found.'));
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    itemCount: printables.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) =>
                        _PrintableCard(printable: printables[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PrintableCard extends StatefulWidget {
  final Printable printable;

  const _PrintableCard({required this.printable});

  @override
  State<_PrintableCard> createState() => _PrintableCardState();
}

class _PrintableCardState extends State<_PrintableCard> {
  bool _isPrinting = false;

  Future<void> _print() async {
    setState(() => _isPrinting = true);
    try {
      final printed = await PrintService.printPrintable(widget.printable);
      if (printed) {
        await PrintableService.markAsSuccess(widget.printable.id);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(printed
                ? 'Printable sent to the printer.'
                : 'Printing was cancelled.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Print failed: $error')),
      );
    } finally {
      if (mounted) setState(() => _isPrinting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final printable = widget.printable;
    final isPending = printable.status == 'pending';
    final dimensions = printable.printWidthInches > 0 &&
            printable.printHeightInches > 0
        ? '${printable.printWidthInches} x ${printable.printHeightInches} in'
        : 'Dimensions unavailable';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 20,
          runSpacing: 16,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SizedBox(
              width: 96,
              height: 96,
              child: Image.network(
                printable.imageUrl,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(LucideIcons.imageOff),
              ),
            ),
            SizedBox(
              width: ResponsiveLayout.isMobile(context) ? double.infinity : 360,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      'Print size: ${printable.printSize.isEmpty ? 'Not specified' : printable.printSize}',
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Text(
                      'Amount: ${printable.amountToPrint}  |  Copies: ${printable.copies}  |  Pages: ${printable.pages}'),
                  Text(dimensions),
                ],
              ),
            ),
            Chip(
              label: Text(printable.status.toUpperCase()),
              backgroundColor: isPending
                  ? Colors.orange.withValues(alpha: 0.12)
                  : AppTheme.success.withValues(alpha: 0.12),
            ),
            ElevatedButton.icon(
              onPressed: isPending && !_isPrinting ? _print : null,
              icon: _isPrinting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(LucideIcons.printer),
              label: const Text('Print'),
            ),
          ],
        ),
      ),
    );
  }
}
