import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:nutribin_application/utils/response_handler.dart';
import 'package:http/http.dart' as http;

final String restServer = dotenv.env['RAILWAY_SERVER'].toString();
final String anonKey = dotenv.env['SUPABASE_ANON'].toString();

class AnnouncementService {
  static Future<Map<String, dynamic>> fetchAnnouncements() async {
    try {
      final url = Uri.parse('$restServer/announcements');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $anonKey',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("ANNOUNCEMENT API RESPONSE: $data");

        // Normalize the API response to match Flutter expectations
        List<Map<String, dynamic>> normalizedAnnouncements = [];

        if (data is Map && data['data'] is List) {
          // If response has a 'data' wrapper (most common)
          print("Processing as Map with data List");
          normalizedAnnouncements = List<Map<String, dynamic>>.from(
            (data['data'] as List).map(
              (announcement) => _normalizeAnnouncement(announcement),
            ),
          );
        } else if (data is List) {
          // If response is directly a list
          print("Processing as direct List");
          normalizedAnnouncements = List<Map<String, dynamic>>.from(
            data.map((announcement) => _normalizeAnnouncement(announcement)),
          );
        } else if (data is Map) {
          // Handle edge cases with nested structure
          print("Processing as Map - looking for announcements");
          final announcementList =
              data['announcements'] ?? data['data'] ?? data['rows'] ?? [];
          if (announcementList is List) {
            normalizedAnnouncements = List<Map<String, dynamic>>.from(
              announcementList.map(
                (announcement) => _normalizeAnnouncement(announcement),
              ),
            );
          }
        } else {
          print(
            "UNEXPECTED DATA STRUCTURE. data type: ${data.runtimeType}, content: $data",
          );
        }

        print("NORMALIZED ANNOUNCEMENTS: $normalizedAnnouncements");

        return Success.successResponse('Successfully fetched announcements', {
          'announcements': normalizedAnnouncements,
        });
      } else {
        print(
          "API ERROR: Status code ${response.statusCode}, body: ${response.body}",
        );
        return Error.errorResponse(
          'Failed to fetch announcements: ${response.statusCode}',
        );
      }
    } catch (e) {
      return Error.errorResponse(e.toString());
    }
  }

  // Normalize API response fields to match Flutter expectations
  static Map<String, dynamic> _normalizeAnnouncement(dynamic announcement) {
    if (announcement is! Map) return {};

    return {
      'title': announcement['title'] ?? 'Announcement',
      'description': announcement['body'] ?? '',
      'importance': _mapPriorityToImportance(announcement['priority']),
      'date':
          announcement['date_published'] ?? announcement['date_created'] ?? '',
      'author': announcement['author'] ?? '',
      'announcement_id': announcement['announcement_id'] ?? '',
    };
  }

  // Map API priority to UI importance level
  static String _mapPriorityToImportance(dynamic priority) {
    if (priority is! String) return 'Low';

    final priorityLower = priority.toLowerCase();
    if (priorityLower.contains('high') || priorityLower.contains('urgent')) {
      return 'High';
    } else if (priorityLower.contains('medium') ||
        priorityLower.contains('normal')) {
      return 'Medium';
    }
    return 'Low';
  }
}
