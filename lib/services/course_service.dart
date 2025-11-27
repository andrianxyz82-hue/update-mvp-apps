import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

class CourseService {
  final _supabase = SupabaseService().client;

  // Get all courses
  Future<List<Map<String, dynamic>>> getCourses() async {
    try {
      return await _supabase
          .from('courses')
          .select()
          .order('created_at', ascending: false);
    } catch (e) {
      print('Error fetching courses: $e');
      return [];
    }
  }

  // Get enrolled courses for current student
  Future<List<Map<String, dynamic>>> getEnrolledCourses() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return [];

      final result = await _supabase
          .from('course_enrollments')
          .select('*, courses(*)')
          .eq('student_id', userId)
          .order('enrolled_at', ascending: false);

      return result;
    } catch (e) {
      print('Error fetching enrolled courses: $e');
      return [];
    }
  }

  // Get course detail with lessons and materials
  Future<Map<String, dynamic>?> getCourseDetail(String courseId) async {
    try {
      final course = await _supabase
          .from('courses')
          .select('*, lessons(*), materials(*)')
          .eq('id', courseId)
          .single();

      // Sort lessons by order_index
      if (course['lessons'] != null) {
        (course['lessons'] as List).sort((a, b) => 
          (a['order_index'] as int).compareTo(b['order_index'] as int)
        );
      }

      return course;
    } catch (e) {
      print('Error fetching course detail: $e');
      return null;
    }
  }

  // Enroll in course
  Future<bool> enrollCourse(String courseId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return false;

      await _supabase.from('course_enrollments').insert({
        'student_id': userId,
        'course_id': courseId,
        'progress': 0,
      });

      return true;
    } catch (e) {
      print('Error enrolling in course: $e');
      return false;
    }
  }

  // Update course progress
  Future<bool> updateProgress(String courseId, double progress) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return false;

      await _supabase
          .from('course_enrollments')
          .update({'progress': progress})
          .eq('student_id', userId)
          .eq('course_id', courseId);

      return true;
    } catch (e) {
      print('Error updating progress: $e');
      return false;
    }
  }

  // ===== TEACHER METHODS =====

  // Get courses created by current teacher
  Future<List<Map<String, dynamic>>> getTeacherCourses() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return [];

      return await _supabase
          .from('courses')
          .select()
          .eq('instructor_id', userId)
          .order('created_at', ascending: false);
    } catch (e) {
      print('Error fetching teacher courses: $e');
      return [];
    }
  }

  // Create new course
  Future<String?> createCourse(Map<String, dynamic> courseData) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return null;

      // Add instructor_id to course data
      courseData['instructor_id'] = userId;

      final result = await _supabase
          .from('courses')
          .insert(courseData)
          .select()
          .single();

      return result['id'] as String;
    } catch (e) {
      print('Error creating course: $e');
      return null;
    }
  }

  // Update course
  Future<bool> updateCourse(String courseId, Map<String, dynamic> data) async {
    try {
      await _supabase
          .from('courses')
          .update(data)
          .eq('id', courseId);

      return true;
    } catch (e) {
      print('Error updating course: $e');
      return false;
    }
  }

  // Delete course
  Future<bool> deleteCourse(String courseId) async {
    try {
      await _supabase
          .from('courses')
          .delete()
          .eq('id', courseId);

      return true;
    } catch (e) {
      print('Error deleting course: $e');
      return false;
    }
  }
}
