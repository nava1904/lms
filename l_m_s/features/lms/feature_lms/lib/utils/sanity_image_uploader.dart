import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class SanityImageUploader {
  static Future<String?> uploadImage(List<int> imageBytes, String filename) async {
    try {
      const projectId = 'w18438cu';
      const dataset = 'production';
      final token = dotenv.env['SANITY_API_TOKEN'] ?? dotenv.env['SANITY_TOKEN'] ?? '';

      final url = Uri.https(
        '$projectId.api.sanity.io',
        '/v2023-05-30/assets/images/$dataset',
      );

      final request = http.MultipartRequest('POST', url)
        ..headers['Authorization'] = 'Bearer $token'
        ..files.add(
          http.MultipartFile.fromBytes(
            'file',
            imageBytes,
            filename: filename,
          ),
        );

      final response = await request.send();

      if (response.statusCode == 201) {
        final responseData = await response.stream.toBytes();
        final jsonData = jsonDecode(utf8.decode(responseData));
        return jsonData['document']['_id'] as String?;
      } else {
        return null;
      }
    } catch (e) {
      debugPrint('Error uploading image: $e');
      return null;
    }
  }
}
