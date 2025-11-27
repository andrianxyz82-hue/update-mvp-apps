import 'package:flutter/material.dart';
import '../../../core/app_theme.dart';
import '../../../services/exam_service.dart';

class ExamResultsListScreen extends StatefulWidget {
  final String examId;
  final Map<String, dynamic> examData;

  const ExamResultsListScreen({
    super.key,
    required this.examId,
    required this.examData,
  });

  @override
  State<ExamResultsListScreen> createState() => _ExamResultsListScreenState();
}

class _ExamResultsListScreenState extends State<ExamResultsListScreen> {
  final _examService = ExamService();
  List<Map<String, dynamic>> _submissions = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSubmissions();
  }

  Future<void> _loadSubmissions() async {
    try {
      final submissions = await _examService.getExamSubmissions(widget.examId);
      setState(() {
        _submissions = submissions;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final passingScore = widget.examData['passing_score'] ?? 70;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : AppTheme.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.examData['title'] ?? 'Exam Results',
          style: TextStyle(color: isDark ? Colors.white : AppTheme.textDark),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.download, color: isDark ? Colors.white : AppTheme.textDark),
            onPressed: () {
              // TODO: Implement Excel Export
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Export to Excel coming soon!')),
              );
            },
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _submissions.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.people_outline, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(
                        'No submissions yet',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Summary Card
                    Container(
                      margin: const EdgeInsets.all(20),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF7C7CFF), Color(0xFF5C5CFF)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildSummaryItem('Total', '${_submissions.length}'),
                          _buildSummaryItem('Passed', '${_submissions.where((s) => (s['score'] ?? 0) >= passingScore).length}'),
                          _buildSummaryItem('Failed', '${_submissions.where((s) => (s['score'] ?? 0) < passingScore).length}'),
                        ],
                      ),
                    ),
                    
                    // List Header
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Text(
                              'Student',
                              style: TextStyle(
                                color: isDark ? Colors.grey[400] : Colors.grey[600],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              'Score',
                              style: TextStyle(
                                color: isDark ? Colors.grey[400] : Colors.grey[600],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              'Status',
                              style: TextStyle(
                                color: isDark ? Colors.grey[400] : Colors.grey[600],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    
                    // Submissions List
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        itemCount: _submissions.length,
                        separatorBuilder: (context, index) => const Divider(),
                        itemBuilder: (context, index) {
                          final submission = _submissions[index];
                          final score = submission['score'] ?? 0;
                          final passed = score >= passingScore;
                          final studentName = submission['profiles']?['full_name'] ?? 'Unknown Student';
                          
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        studentName,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: isDark ? Colors.white : AppTheme.textDark,
                                        ),
                                      ),
                                      Text(
                                        _formatDate(submission['created_at']),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: isDark ? Colors.grey[500] : Colors.grey[500],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    '${score.toStringAsFixed(1)}%',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: isDark ? Colors.white : AppTheme.textDark,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: passed ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      passed ? 'Passed' : 'Failed',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: passed ? Colors.green : Colors.red,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  String _formatDate(String? timestamp) {
    if (timestamp == null) return '-';
    try {
      final date = DateTime.parse(timestamp);
      return '${date.day}/${date.month} ${date.hour}:${date.minute}';
    } catch (e) {
      return '-';
    }
  }
}
