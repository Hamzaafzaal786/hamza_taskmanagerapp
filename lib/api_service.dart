import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://jsonplaceholder.typicode.com';

  // Fetch posts from API
  Future<List<dynamic>> fetchPosts() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/posts'));
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load posts');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Fetch users from API
  Future<Map<String, dynamic>> fetchUser(int userId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/users/$userId'));
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load user');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Fetch single post by ID
  Future<Map<String, dynamic>> fetchPost(int postId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/posts/$postId'));
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load post');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Fetch comments for a post
  Future<List<dynamic>> fetchComments(int postId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/posts/$postId/comments'));
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load comments');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}