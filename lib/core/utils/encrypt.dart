import 'package:encrypt/encrypt.dart' as encrypt;

class CryptoHelper {
  static final _key = encrypt.Key.fromUtf8('12345678901234567890123456789012'); // 32 chars
  static final _iv = encrypt.IV.fromUtf8('1234567890123456'); // 16 chars

  static String encryptData(String plainText) {
    final encrypter = encrypt.Encrypter(encrypt.AES(_key, mode: encrypt.AESMode.cbc));
    final encrypted = encrypter.encrypt(plainText, iv: _iv);
    return encrypted.base64; // QR code va contenir ça
  }

  static String decryptData(String encryptedText) {
    try {
      final encrypter = encrypt.Encrypter(encrypt.AES(_key, mode: encrypt.AESMode.cbc));
      final decrypted = encrypter.decrypt64(encryptedText.trim(), iv: _iv);
      return decrypted;
    } catch (e) {
      throw Exception("QR Code invalide ou corrompu");
    }
  }
}
