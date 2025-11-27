import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/app_theme.dart';
import '../../services/exam_service.dart';
import '../exam/take_exam_screen.dart';

class ExamsScreen extends StatefulWidget {
  const ExamsScreen({super.key});

  @override
  State<ExamsScreen> createState() => _ExamsScreenState();
}

class _ExamsScreenState extends State<ExamsScreen> {
  final _examService = ExamService();
  List<Map<String, dynamic>> _exams = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadExams();
  }

  Future<void> _loadExams() async {
    try {
      final exams = await _examService.getStudentExamsWithStatus();
      setState(() {
        _exams = exams;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
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
        title: Text(
          'Available Exams',
          style: TextStyle(color: isDark ? Colors.white : AppTheme.textDark),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _exams.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.quiz_outlined, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(
                        'No exams available',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: _exams.length,
                  itemBuilder: (context, index) {
                    return _buildExamCard(context, _exams[index], isDark);
                  },
                ),
    );
  }

  Widget _buildExamCard(BuildContext context, Map<String, dynamic> exam, bool isDark) {
    final isCompleted = exam['status'] == 'completed';
    final score = exam['score'];
    
    // Check expiration
    final expiresAt = exam['expires_at'] != null ? DateTime.parse(exam['expires_at']) : null;
    final isExpired = expiresAt != null && DateTime.now().isAfter(expiresAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2D2D44) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isCompleted 
              ? Colors.green.withOpacity(0.5) 
              : (isExpired ? Colors.red.withOpacity(0.3) : const Color(0xFF7C7CFF).withOpacity(0.3)),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  exam['title'] ?? 'Untitled Exam',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                    color: isDark ? Colors.white : AppTheme.textDark,
                  ),
                ),
              ),
              if (isCompleted)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, size: 14, color: Colors.green),
                      const SizedBox(width: 4),
                      Text(
                        score != null ? '${score.toStringAsFixed(0)}%' : 'Done',
                        style: const TextStyle(
                          color: Colors.green,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                )
              else if (isExpired)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Expired',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            exam['description'] ?? '',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey[300] : Colors.grey[700],
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildInfoChip(Icons.access_time, '${exam['duration_minutes'] ?? 0} min'),
              const SizedBox(width: 12),
              _buildInfoChip(Icons.quiz_outlined, '${exam['total_questions'] ?? 0} Questions'),
            ],
          ),
          if (expiresAt != null && !isCompleted && !isExpired) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.timer_off_outlined, size: 14, color: Colors.orange),
                const SizedBox(width: 4),
                Text(
                  'Expires: ${expiresAt.day}/${expiresAt.month} ${expiresAt.hour}:${expiresAt.minute.toString().padLeft(2, '0')}',
                  style: const TextStyle(fontSize: 12, color: Colors.orange),
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: (isCompleted || isExpired)
                  ? null // Disable if completed or expired
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TakeExamScreen(examId: exam['id']),
                        ),
                      ).then((_) => _loadExams()); // Refresh after return
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: isCompleted ? Colors.grey : (isExpired ? Colors.red : const Color(0xFF7C7CFF)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(isCompleted ? 'Completed' : (isExpired ? 'Expired' : 'Start Exam')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.lightPurple.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppTheme.primaryPurple),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textDark,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
