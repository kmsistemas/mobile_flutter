import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// Dialog simples de scanner. Retorna o código lido via Navigator.pop(code).
class ScannerDialog extends StatefulWidget {
  const ScannerDialog({super.key});

  @override
  State<ScannerDialog> createState() => _ScannerDialogState();
}

class _ScannerDialogState extends State<ScannerDialog> {
  final MobileScannerController _controller = MobileScannerController(formats: const [BarcodeFormat.all]);
  bool _handled = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_handled) return;
    final code = capture.barcodes.firstOrNull?.rawValue;
    if (code != null && code.isNotEmpty) {
      _handled = true;
      Navigator.of(context).pop(code);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: AspectRatio(
        aspectRatio: 3 / 4,
        child: Stack(
          children: [
            MobileScanner(
              controller: _controller,
              onDetect: _onDetect,
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            const Center(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.fromBorderSide(
                    BorderSide(color: Colors.white70, width: 2),
                  ),
                ),
                child: SizedBox(width: 200, height: 200),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Helper para abrir o dialog e retornar o código lido.
Future<String?> showScannerDialog(BuildContext context) {
  return showDialog<String>(
    context: context,
    builder: (_) => const ScannerDialog(),
  );
}
