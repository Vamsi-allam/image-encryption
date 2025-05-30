import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io';
import 'package:universal_html/html.dart' as html;
import '../utils/encryption_utils.dart';

class DecryptScreen extends StatefulWidget {
  const DecryptScreen({super.key});

  @override
  State<DecryptScreen> createState() => _DecryptScreenState();
}

class _DecryptScreenState extends State<DecryptScreen> {
  final TextEditingController _encryptedTextController = TextEditingController();
  final TextEditingController _secretKeyController = TextEditingController();
  Uint8List? _decryptedImageBytes;
  bool _isLoading = false;

  Future<void> _decryptImage() async {
    if (_encryptedTextController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the encrypted text')),
      );
      return;
    }

    if (_secretKeyController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the secret key')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final decryptedBytes = await EncryptionUtils.decryptImage(
        _encryptedTextController.text,
        _secretKeyController.text,
      );

      setState(() {
        _decryptedImageBytes = decryptedBytes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error decrypting image: $e')),
      );
    }
  }

  Future<void> _saveImage() async {
    if (_decryptedImageBytes == null) return;

    try {
      if (kIsWeb) {
        // For web platform, browser handles download location
        final blob = html.Blob([_decryptedImageBytes!]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute('download', 'decrypted_image.png')
          ..click();
        html.Url.revokeObjectUrl(url);
      } else {
        // For mobile and desktop platforms
        if (Platform.isAndroid || Platform.isIOS || Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
          // Ask user where to save the file
          String? outputPath;
          
          // Show save dialog
          String? selectedDirectory = await FilePicker.platform.getDirectoryPath(
            dialogTitle: 'Select where to save the decrypted image',
          );
          
          if (selectedDirectory == null) {
            // User canceled the picker
            return;
          }
          
          // Create filename with timestamp to avoid overwriting
          final timestamp = DateTime.now().millisecondsSinceEpoch;
          final filename = 'decrypted_image_$timestamp.png';
          outputPath = '$selectedDirectory${Platform.pathSeparator}$filename';
          
          // Save the file
          final file = File(outputPath);
          await file.writeAsBytes(_decryptedImageBytes!);
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Image saved to: $outputPath')),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving image: $e')),
      );
    }
  }
  
  void _pasteFromClipboard() async {
    final data = await Clipboard.getData('text/plain');
    if (data != null && data.text != null) {
      setState(() {
        _encryptedTextController.text = data.text!;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Decrypt Image'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Paste encrypted text and enter your secret key to decrypt',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _encryptedTextController,
                    decoration: const InputDecoration(
                      labelText: 'Paste Encrypted Text',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 5,
                  ),
                ),
                IconButton(
                  onPressed: _pasteFromClipboard,
                  icon: const Icon(Icons.paste),
                  tooltip: 'Paste from clipboard',
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _secretKeyController,
              decoration: const InputDecoration(
                labelText: 'Enter Secret Key',
                border: OutlineInputBorder(),
                hintText: 'Enter the same key used for encryption',
              ),
              obscureText: true,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _isLoading ? null : _decryptImage,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Decrypt Image', style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 30),
            if (_decryptedImageBytes != null) ...[
              const Text(
                'Decrypted Image:',
                style: TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Container(
                height: 300,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Image.memory(
                    _decryptedImageBytes!,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _saveImage,
                icon: const Icon(Icons.save),
                label: const Text('Save Decrypted Image'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _encryptedTextController.dispose();
    _secretKeyController.dispose();
    super.dispose();
  }
}
