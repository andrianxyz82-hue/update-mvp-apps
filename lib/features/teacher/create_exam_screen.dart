import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/app_theme.dart';
import '../../services/exam_service.dart';
import '../../services/course_service.dart';
import 'add_questions_screen.dart';

class CreateExamScreen extends StatefulWidget {
  const CreateExamScreen({super.key});

  @override
  State<CreateExamScreen> createState() => _CreateExamScreenState();
}

class _CreateExamScreenState extends State<CreateExamScreen> {
  final _formKey = GlobalKey<FormState>();
  final _examService = ExamService();
  final _courseService = CourseService();
  
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _durationController = TextEditingController();
  final _passingScoreController = TextEditingController();
  
  List<Map<String, dynamic>> _courses = [];
  String? _selectedCourseId;
  DateTime? _expirationDate;
  bool _lockMode = true;
  bool _loading = false;
  bool _loadingCourses = true;

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    try {
      final courses = await _courseService.getTeacherCourses();
      setState(() {
        _courses = courses;
        _loadingCourses = false;
      });
    } catch (e) {
      setState(() => _loadingCourses = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _durationController.dispose();
    _passingScoreController.dispose();
    super.dispose();
  }

  Future<void> _createExam() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCourseId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a course')),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final examId = await _examService.createExam({
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'course_id': _selectedCourseId,
        'duration_minutes': int.parse(_durationController.text.trim()),
        'passing_score': int.parse(_passingScoreController.text),
        'expires_at': _expirationDate?.toIso8601String(),
        'is_lock_mode': _lockMode,
        'total_questions': 0, // Will be updated when questions are added
      });

      if (examId != null && mounted) {
        // Navigate to add questions screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddQuestionsScreen(examId: examId),
          ),
        ).then((_) => context.pop());
      } else if (mounted) {
        throw Exception('Failed to create exam');
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
          'Create New Exam',
          style: TextStyle(color: isDark ? Colors.white : AppTheme.textDark),
        ),
      ),
      body: _loadingCourses
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // Title Field
                  TextFormField(
                    controller: _titleController,
                    style: TextStyle(color: isDark ? Colors.white : AppTheme.textDark),
                    decoration: InputDecoration(
                      labelText: 'Exam Title',
                      labelStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: isDark ? const Color(0xFF2D2D44) : Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(Icons.quiz, color: Color(0xFF7C7CFF)),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter exam title';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 16),

                  // Description Field
                  TextFormField(
                    controller: _descriptionController,
                    style: TextStyle(color: isDark ? Colors.white : AppTheme.textDark),
                    maxLines: 3,
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

                  // Course Selection
                  DropdownButtonFormField<String>(
                    value: _selectedCourseId,
                    style: TextStyle(color: isDark ? Colors.white : AppTheme.textDark),
                    decoration: InputDecoration(
                      labelText: 'Select Course',
                      labelStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: isDark ? const Color(0xFF2D2D44) : Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(Icons.book, color: Color(0xFF7C7CFF)),
                    ),
                    dropdownColor: isDark ? const Color(0xFF2D2D44) : Colors.white,
                    items: _courses.map((course) {
                      return DropdownMenuItem<String>(
                        value: course['id'],
                        child: Text(course['title'] ?? 'Untitled'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _selectedCourseId = value);
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a course';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Duration Field
                  TextFormField(
                    controller: _durationController,
                    style: TextStyle(color: isDark ? Colors.white : AppTheme.textDark),
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Duration (minutes)',
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
                      if (int.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Passing Score Field
                  TextFormField(
                    controller: _passingScoreController,
                    style: TextStyle(color: isDark ? Colors.white : AppTheme.textDark),
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Passing Score (%)',
                      labelStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: isDark ? const Color(0xFF2D2D44) : Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(Icons.grade, color: Color(0xFF7C7CFF)),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter passing score';
                      }
                      final score = double.tryParse(value);
                      if (score == null || score < 0 || score > 100) {
                        return 'Please enter a valid score (0-100)';
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
                      onPressed: _loading ? null : _createExam,
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
                              'Next: Add Questions',
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
