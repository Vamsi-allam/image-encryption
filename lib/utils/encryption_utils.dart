import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

class EncryptionUtils {
  // Common key used along with the secret key
  static const String _commonKey = "ImageEncryptionAppCommonKey2023";

  // Generate an encryption key from the user's secret key and the common key
  static encrypt.Key _generateKey(String secretKey) {
    final combinedKey = secretKey + _commonKey;
    final keyBytes = sha256.convert(utf8.encode(combinedKey)).bytes;
    return encrypt.Key(Uint8List.fromList(keyBytes));
  }

  // Encrypt an image
  static Future<String> encryptImage(Uint8List imageBytes, String secretKey) async {
    try {
      // First, convert the image to Base64 string
      final base64Image = base64Encode(imageBytes);
      
      // Generate encryption key
      final key = _generateKey(secretKey);
      final iv = encrypt.IV.fromLength(16);
      
      // Encrypt the Base64 string
      final encrypter = encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));
      final encrypted = encrypter.encrypt(base64Image, iv: iv);
      
      // Create final encrypted text with IV included
      final encryptedData = {
        'iv': base64Encode(iv.bytes),
        'data': encrypted.base64,
      };
      
      return jsonEncode(encryptedData);
    } catch (e) {
      throw Exception('Failed to encrypt image: $e');
    }
  }

  // Decrypt an image
  static Future<Uint8List> decryptImage(String encryptedText, String secretKey) async {
    try {
      // Parse the encrypted data JSON
      final encryptedData = jsonDecode(encryptedText);
      final ivString = encryptedData['iv'];
      final dataString = encryptedData['data'];
      
      // Generate decryption key
      final key = _generateKey(secretKey);
      final iv = encrypt.IV.fromBase64(ivString);
      
      // Decrypt the data
      final encrypter = encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));
      final decrypted = encrypter.decrypt64(dataString, iv: iv);
      
      // Convert Base64 back to image bytes
      return Uint8List.fromList(base64Decode(decrypted));
    } catch (e) {
      throw Exception('Failed to decrypt image: $e');
    }
  }
}
