import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/app_theme.dart';
import '../../services/course_service.dart';

class CreateCourseScreen extends StatefulWidget {
  const CreateCourseScreen({super.key});

  @override
  State<CreateCourseScreen> createState() => _CreateCourseScreenState();
}

class _CreateCourseScreenState extends State<CreateCourseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _courseService = CourseService();
  
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _durationController = TextEditingController();
  
  bool _loading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  Future<void> _createCourse() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      final courseId = await _courseService.createCourse({
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'duration': _durationController.text.trim(),
        'instructor_name': 'Test Teacher', // TODO: Get from profile
      });

      if (courseId != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Course created successfully!'),
            backgroundColor: Color(0xFF7C7CFF),
          ),
        );
        context.pop();
      } else if (mounted) {
        throw Exception('Failed to create course');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : AppTheme.textDark),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Create New Course',
          style: TextStyle(color: isDark ? Colors.white : AppTheme.textDark),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Title Field
            TextFormField(
              controller: _titleController,
              style: TextStyle(color: isDark ? Colors.white : AppTheme.textDark),
              decoration: InputDecoration(
                labelText: 'Course Title',
                labelStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: isDark ? const Color(0xFF2D2D44) : Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.book, color: Color(0xFF7C7CFF)),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter course title';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),

            // Description Field
            TextFormField(
              controller: _descriptionController,
              style: TextStyle(color: isDark ? Colors.white : AppTheme.textDark),
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Description',
                labelStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: isDark ? const Color(0xFF2D2D44) : Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.description, color: Color(0xFF7C7CFF)),
                alignLabelWithHint: true,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter description';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Duration Field
            TextFormField(
              controller: _durationController,
              style: TextStyle(color: isDark ? Colors.white : AppTheme.textDark),
              decoration: InputDecoration(
                labelText: 'Duration (e.g., 14h)',
                labelStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: isDark ? const Color(0xFF2D2D44) : Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.access_time, color: Color(0xFF7C7CFF)),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter duration';
                }
                return null;
              },
            ),

            const SizedBox(height: 32),

            // Create Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _loading ? null : _createCourse,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7C7CFF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Create Course',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
