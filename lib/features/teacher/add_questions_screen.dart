import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:convert';
import '../../core/app_theme.dart';
import '../../services/exam_service.dart';

class AddQuestionsScreen extends StatefulWidget {
  final String examId;
  const AddQuestionsScreen({super.key, required this.examId});

  @override
  State<AddQuestionsScreen> createState() => _AddQuestionsScreenState();
}

class _AddQuestionsScreenState extends State<AddQuestionsScreen> {
  final _examService = ExamService();
  final List<Map<String, dynamic>> _questions = [];
  bool _loading = false;

  void _addQuestion() {
    showDialog(
      context: context,
      builder: (context) => _AddQuestionDialog(
        onAdd: (question) {
          setState(() {
            _questions.add(question);
          });
        },
      ),
    );
  }

  Future<void> _saveQuestions() async {
    if (_questions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one question')),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      // Add all questions to the exam
      for (int i = 0; i < _questions.length; i++) {
        final question = _questions[i];
        await _examService.addQuestion(widget.examId, {
          'question_text': question['text'],
          'question_type': question['type'] == 'Multiple Choice' ? 'multiple_choice' : 'essay',
          'options': question['options'] != null ? jsonEncode(question['options']) : null,
          'correct_answer': question['correctAnswer'],
          'points': question['points'] ?? 1,
          'order_index': i + 1,
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Exam created successfully!'),
            backgroundColor: Color(0xFF7C7CFF),
          ),
        );
        context.pop();
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
          'Add Questions',
          style: TextStyle(color: isDark ? Colors.white : AppTheme.textDark),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _questions.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.quiz_outlined, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(
                          'No questions added yet',
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: _questions.length,
                    itemBuilder: (context, index) {
                      final question = _questions[index];
                      return _buildQuestionCard(index, question, isDark);
                    },
                  ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2D2D44) : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _addQuestion,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Question'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF7C7CFF),
                      side: const BorderSide(color: Color(0xFF7C7CFF)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _loading ? null : _saveQuestions,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7C7CFF),
                      padding: const EdgeInsets.symmetric(vertical: 16),
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
                        : const Text('Save Exam'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(int index, Map<String, dynamic> question, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2D2D44) : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF7C7CFF).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Q${index + 1}',
                  style: const TextStyle(
                    color: Color(0xFF7C7CFF),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () {
                  setState(() {
                    _questions.removeAt(index);
                  });
                },
                icon: const Icon(Icons.delete, color: Colors.red),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            question['text'] ?? '',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: question['type'] == 'Multiple Choice'
                      ? Colors.blue.withOpacity(0.2)
                      : Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  question['type'] ?? '',
                  style: TextStyle(
                    fontSize: 12,
                    color: question['type'] == 'Multiple Choice' ? Colors.blue : Colors.green,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${question['points'] ?? 1} point(s)',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          if (question['options'] != null) ...[
            const SizedBox(height: 12),
            ...List.generate(question['options'].length, (i) {
              final option = question['options'][i];
              final isCorrect = option == question['correctAnswer'];
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Icon(
                      isCorrect ? Icons.check_circle : Icons.circle_outlined,
                      size: 16,
                      color: isCorrect ? Colors.green : Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      option,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.grey[300] : Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}

class _AddQuestionDialog extends StatefulWidget {
  final Function(Map<String, dynamic>) onAdd;
  const _AddQuestionDialog({required this.onAdd});

  @override
  State<_AddQuestionDialog> createState() => _AddQuestionDialogState();
}

class _AddQuestionDialogState extends State<_AddQuestionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _questionController = TextEditingController();
  final _pointsController = TextEditingController(text: '1');
  String _questionType = 'Multiple Choice';
  
  final List<TextEditingController> _optionControllers = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];
  int _correctAnswerIndex = 0;

  @override
  void dispose() {
    _questionController.dispose();
    _pointsController.dispose();
    for (var controller in _optionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final question = {
      'text': _questionController.text.trim(),
      'type': _questionType,
      'points': int.tryParse(_pointsController.text) ?? 1,
    };

    if (_questionType == 'Multiple Choice') {
      final options = _optionControllers.map((c) => c.text.trim()).where((t) => t.isNotEmpty).toList();
      if (options.length < 2) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please add at least 2 options')),
        );
        return;
      }
      question['options'] = options;
      question['correctAnswer'] = options[_correctAnswerIndex];
    }

    widget.onAdd(question);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      backgroundColor: isDark ? const Color(0xFF2D2D44) : Colors.white,
      title: Text('Add Question', style: TextStyle(color: isDark ? Colors.white : AppTheme.textDark)),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _questionController,
                style: TextStyle(color: isDark ? Colors.white : AppTheme.textDark),
                decoration: const InputDecoration(
                  labelText: 'Question Text',
                  hintText: 'Enter your question',
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter question text';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _questionType,
                style: TextStyle(color: isDark ? Colors.white : AppTheme.textDark),
                decoration: const InputDecoration(labelText: 'Type'),
                dropdownColor: isDark ? const Color(0xFF2D2D44) : Colors.white,
                items: ['Multiple Choice', 'Essay'].map((type) {
                  return DropdownMenuItem(value: type, child: Text(type));
                }).toList(),
                onChanged: (value) {
                  setState(() => _questionType = value!);
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _pointsController,
                style: TextStyle(color: isDark ? Colors.white : AppTheme.textDark),
                decoration: const InputDecoration(labelText: 'Points'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || int.tryParse(value) == null) {
                    return 'Please enter valid points';
                  }
                  return null;
                },
              ),
              if (_questionType == 'Multiple Choice') ...[
                const SizedBox(height: 16),
                const Text('Options:', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                ...List.generate(4, (index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Radio<int>(
                          value: index,
                          groupValue: _correctAnswerIndex,
                          onChanged: (value) {
                            setState(() => _correctAnswerIndex = value!);
                          },
                        ),
                        Expanded(
                          child: TextFormField(
                            controller: _optionControllers[index],
                            style: TextStyle(color: isDark ? Colors.white : AppTheme.textDark),
                            decoration: InputDecoration(
                              hintText: 'Option ${String.fromCharCode(65 + index)}',
                              isDense: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF7C7CFF)),
          child: const Text('Add'),
        ),
      ],
    );
  }
}
