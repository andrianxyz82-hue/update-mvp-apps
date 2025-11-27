import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

class ExamService {
  final _supabase = SupabaseService().client;

  // Get all exams
  Future<List<Map<String, dynamic>>> getExams() async {
    try {
      return await _supabase
          .from('exams')
          .select()
          .order('scheduled_at', ascending: false);
    } catch (e) {
      print('Error fetching exams: $e');
      return [];
    }
  }

  // Get exams with student submission status
  Future<List<Map<String, dynamic>>> getStudentExamsWithStatus() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return [];

      // 1. Get all exams
      print('Fetching all exams...');
      final exams = await _supabase
          .from('exams')
          .select()
          .order('created_at', ascending: false);
      print('Exams found: ${exams.length}');

      // 2. Get user's submissions
      print('Fetching submissions for user: $userId');
      final submissions = await _supabase
          .from('exam_submissions')
          .select('exam_id, score, created_at')
          .eq('student_id', userId);
      print('Submissions found: ${submissions.length}');

      // 3. Merge data
      final List<Map<String, dynamic>> result = [];
      
      for (var exam in exams) {
        final submission = submissions.cast<Map<String, dynamic>?>().firstWhere(
          (s) => s?['exam_id'] == exam['id'],
          orElse: () => null,
        );

        final Map<String, dynamic> examData = Map.from(exam);
        if (submission != null) {
          examData['status'] = 'completed';
          examData['score'] = submission['score'];
          examData['submitted_at'] = submission['created_at'];
        } else {
          examData['status'] = 'available';
        }
        
        result.add(examData);
      }
      
      print('Returning ${result.length} exams with status');
      return result;
    } catch (e) {
      print('Error fetching student exams: $e');
      return [];
    }
  }

  // Get exam with questions
  Future<Map<String, dynamic>?> getExamDetail(String examId) async {
    try {
      final exam = await _supabase
          .from('exams')
          .select('*, exam_questions(*)')
          .eq('id', examId)
          .single();
      
      // Sort questions by order_index
      if (exam['exam_questions'] != null) {
        (exam['exam_questions'] as List).sort((a, b) => 
          (a['order_index'] as int).compareTo(b['order_index'] as int)
        );
      }
      
      return exam;
    } catch (e) {
      print('Error fetching exam detail: $e');
      return null;
    }
  }



  // Get submission result
  Future<Map<String, dynamic>?> getSubmission(String examId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return null;
      
      final result = await _supabase
          .from('exam_submissions')
          .select()
          .eq('exam_id', examId)
          .eq('student_id', userId)
          .maybeSingle();
      
      return result;
    } catch (e) {
      print('Error fetching submission: $e');
      return null;
    }
  }

  // Get exam by ID
  Future<Map<String, dynamic>?> getExamById(String examId) async {
    try {
      return await _supabase
          .from('exams')
          .select()
          .eq('id', examId)
          .single();
    } catch (e) {
      print('Error fetching exam: $e');
      return null;
    }
  }

  // Get exam questions
  Future<List<Map<String, dynamic>>> getExamQuestions(String examId) async {
    try {
      print('Fetching questions for exam: $examId');
      final questions = await _supabase
          .from('exam_questions')
          .select()
          .eq('exam_id', examId)
          .order('order_index', ascending: true);
      
      print('Questions found: ${questions.length}');
      return questions;
    } catch (e) {
      print('Error fetching questions: $e');
      return [];
    }
  }

  // Submit exam with auto-grading
  Future<String?> submitExam(String examId, Map<String, dynamic> answers) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return null;

      // Get exam and questions for grading
      final exam = await getExamById(examId);
      final questions = await getExamQuestions(examId);
      
      if (exam == null || questions.isEmpty) return null;

      // Calculate score for MC questions
      int totalQuestions = questions.length;
      int correctAnswers = 0;

      for (var question in questions) {
        if (question['question_type'] == 'multiple_choice') {
          final questionId = question['id'];
          final correctAnswer = question['correct_answer'];
          final studentAnswer = answers[questionId];
          
          if (studentAnswer == correctAnswer) {
            correctAnswers++;
          }
        }
      }

      // Calculate percentage score
      double score = totalQuestions > 0 ? (correctAnswers / totalQuestions) * 100 : 0;

      // Insert submission
      final result = await _supabase.from('exam_submissions').insert({
        'exam_id': examId,
        'student_id': userId,
        'answers': answers,
        'score': score,
        'total_questions': totalQuestions,
        'correct_answers': correctAnswers,
      }).select().single();

      return result['id'] as String;
    } catch (e) {
      print('Error submitting exam: $e');
      return null;
    }
  }

  // Get exam submissions with student profile
  Future<List<Map<String, dynamic>>> getExamSubmissions(String examId) async {
    try {
      final submissions = await _supabase
          .from('exam_submissions')
          .select('*, profiles:student_id(full_name, email)')
          .eq('exam_id', examId)
          .order('score', ascending: false);
      
      return List<Map<String, dynamic>>.from(submissions);
    } catch (e) {
      print('Error fetching submissions: $e');
      return [];
    }
  }



  // Get submission result
  Future<Map<String, dynamic>?> getSubmissionResult(String submissionId) async {
    try {
      final submission = await _supabase
          .from('exam_submissions')
          .select('*, exams(passing_score)')
          .eq('id', submissionId)
          .single();
      
      // Extract passing score from nested exam data
      if (submission['exams'] != null) {
        submission['passing_score'] = submission['exams']['passing_score'];
      }
      
      return submission;
    } catch (e) {
      print('Error fetching submission result: $e');
      return null;
    }
  }

  // ===== TEACHER METHODS =====

  // Get teacher's exams
  Future<List<Map<String, dynamic>>> getTeacherExams() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return [];

      return await _supabase
          .from('exams')
          .select()
          .eq('teacher_id', userId)
          .order('created_at', ascending: false);
    } catch (e) {
      print('Error fetching teacher exams: $e');
      return [];
    }
  }

  // Create exam
  Future<String?> createExam(Map<String, dynamic> examData) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        print('Error: User not logged in');
        return null;
      }

      examData['teacher_id'] = userId;
      print('Creating exam with data: $examData');

      final result = await _supabase
          .from('exams')
          .insert(examData)
          .select()
          .single();

      print('Exam created successfully: ${result['id']}');
      return result['id'] as String;
    } catch (e) {
      print('Error creating exam: $e');
      return null;
    }
  }

  // Add question to exam
  Future<bool> addQuestion(String examId, Map<String, dynamic> questionData) async {
    try {
      questionData['exam_id'] = examId;
      
      await _supabase.from('exam_questions').insert(questionData);
      return true;
    } catch (e) {
      print('Error adding question: $e');
      return false;
    }
  }

  // Update question
  Future<bool> updateQuestion(String questionId, Map<String, dynamic> data) async {
    try {
      await _supabase
          .from('exam_questions')
          .update(data)
          .eq('id', questionId);
      
      return true;
    } catch (e) {
      print('Error updating question: $e');
      return false;
    }
  }

  // Delete question
  Future<bool> deleteQuestion(String questionId) async {
    try {
      await _supabase
          .from('exam_questions')
          .delete()
          .eq('id', questionId);
      
      return true;
    } catch (e) {
      print('Error deleting question: $e');
      return false;
    }
  }

  // Delete exam
  Future<bool> deleteExam(String examId) async {
    try {
      await _supabase
          .from('exams')
          .delete()
          .eq('id', examId);
      
      return true;
    } catch (e) {
      print('Error deleting exam: $e');
      return false;
    }
  }
}
