import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

class MaterialService {
  final _supabase = SupabaseService().client;

  // Add material to course
  Future<bool> addMaterial(String courseId, Map<String, dynamic> materialData) async {
    try {
      materialData['course_id'] = courseId;
      
      await _supabase.from('materials').insert(materialData);
      return true;
    } catch (e) {
      print('Error adding material: $e');
      return false;
    }
  }

  // Delete material
  Future<bool> deleteMaterial(String materialId) async {
    try {
      await _supabase
          .from('materials')
          .delete()
          .eq('id', materialId);
      
      return true;
    } catch (e) {
      print('Error deleting material: $e');
      return false;
    }
  }

  // Get materials for a course
  Future<List<Map<String, dynamic>>> getMaterials(String courseId) async {
    try {
      return await _supabase
          .from('materials')
          .select()
          .eq('course_id', courseId)
          .order('created_at', ascending: false);
    } catch (e) {
      print('Error fetching materials: $e');
      return [];
    }
  }
}
