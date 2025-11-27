import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

class LessonService {
  final _supabase = SupabaseService().client;

  // Add lesson to course
  Future<bool> addLesson(String courseId, Map<String, dynamic> lessonData) async {
    try {
      lessonData['course_id'] = courseId;
      
      await _supabase.from('lessons').insert(lessonData);
      return true;
    } catch (e) {
      print('Error adding lesson: $e');
      return false;
    }
  }

  // Update lesson
  Future<bool> updateLesson(String lessonId, Map<String, dynamic> data) async {
    try {
      await _supabase
          .from('lessons')
          .update(data)
          .eq('id', lessonId);
      
      return true;
    } catch (e) {
      print('Error updating lesson: $e');
      return false;
    }
  }

  // Delete lesson
  Future<bool> deleteLesson(String lessonId) async {
    try {
      await _supabase
          .from('lessons')
          .delete()
          .eq('id', lessonId);
      
      return true;
    } catch (e) {
      print('Error deleting lesson: $e');
      return false;
    }
  }

  // Get lessons for a course
  Future<List<Map<String, dynamic>>> getLessons(String courseId) async {
    try {
      return await _supabase
          .from('lessons')
          .select()
          .eq('course_id', courseId)
          .order('order_index', ascending: true);
    } catch (e) {
      print('Error fetching lessons: $e');
      return [];
    }
  }
}
