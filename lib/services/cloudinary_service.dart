import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

/// Cloudinary REST API vasitəsilə şəkil yükləmə servisi.
/// Profil fotoları və ev tapşırığı şəkilləri üçün istifadə olunur.
class CloudinaryService {
  static const String _cloudName = 'acwz9zcj';
  static const String _apiKey = '446487942781273';
  static const String _apiSecret = 'KL9yOHgjs1P7yqipVRArNxE6tdg';

  static final ImagePicker _picker = ImagePicker();

  /// Kameranı açıb foto çəkir, Cloudinary-yə yükləyib URL qaytarır.
  /// [folder] – Cloudinary-də saxlanacaq qovluq (məs: 'idrak/profiles')
  static Future<String?> pickAndUploadFromCamera({
    String folder = 'idrak/profiles',
    int imageQuality = 85,
    double? maxWidth = 1024,
    double? maxHeight = 1024,
  }) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: imageQuality,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
      );
      if (image == null) return null;
      return await _uploadToCloudinary(image, folder);
    } catch (e) {
      debugPrint('CloudinaryService: Kameradan foto alma xətası: $e');
      return null;
    }
  }

  /// Qalereyadan foto seçir, Cloudinary-yə yükləyib URL qaytarır.
  static Future<String?> pickAndUploadFromGallery({
    String folder = 'idrak/profiles',
    int imageQuality = 85,
    double? maxWidth = 1024,
    double? maxHeight = 1024,
  }) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: imageQuality,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
      );
      if (image == null) return null;
      return await _uploadToCloudinary(image, folder);
    } catch (e) {
      debugPrint('CloudinaryService: Qalereyadan foto alma xətası: $e');
      return null;
    }
  }

  /// Qalereyadan çox sayda foto seçir və hamısını yükləyir.
  /// Ev tapşırığı səhifələri üçün istifadə olunur.
  static Future<List<String>> pickMultipleAndUpload({
    String folder = 'idrak/homework',
    int imageQuality = 80,
    double? maxWidth = 1600,
  }) async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        imageQuality: imageQuality,
        maxWidth: maxWidth,
      );
      if (images.isEmpty) return [];

      final List<String> urls = [];
      for (final image in images) {
        final url = await _uploadToCloudinary(image, folder);
        if (url != null) urls.add(url);
      }
      return urls;
    } catch (e) {
      debugPrint('CloudinaryService: Çoxlu foto seçmə xətası: $e');
      return [];
    }
  }

  /// XFile-ı Cloudinary-yə yükləyir və secure_url qaytarır.
  static Future<String?> _uploadToCloudinary(XFile file, String folder) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final paramsToSign = 'folder=$folder&timestamp=$timestamp$_apiSecret';
      final signature = sha1.convert(utf8.encode(paramsToSign)).toString();

      final uri = Uri.parse(
        'https://api.cloudinary.com/v1_1/$_cloudName/image/upload',
      );

      final request = http.MultipartRequest('POST', uri)
        ..fields['api_key'] = _apiKey
        ..fields['timestamp'] = timestamp.toString()
        ..fields['folder'] = folder
        ..fields['signature'] = signature;

      if (kIsWeb) {
        final bytes = await file.readAsBytes();
        request.files.add(http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: file.name,
        ));
      } else {
        request.files.add(await http.MultipartFile.fromPath(
          'file',
          file.path,
          filename: file.name,
        ));
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final secureUrl = data['secure_url'] as String;
        debugPrint('CloudinaryService: Yükləndi → $secureUrl');
        return secureUrl;
      } else {
        debugPrint('CloudinaryService: Yükləmə uğursuz oldu: ${response.statusCode} ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('CloudinaryService: Yükləmə xətası: $e');
      return null;
    }
  }
}
