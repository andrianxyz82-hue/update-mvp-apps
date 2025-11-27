import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/app_theme.dart';
import '../../../services/exam_service.dart';

class MonitoringDashboardScreen extends StatefulWidget {
  const MonitoringDashboardScreen({super.key});

  @override
  State<MonitoringDashboardScreen> createState() => _MonitoringDashboardScreenState();
}

class _MonitoringDashboardScreenState extends State<MonitoringDashboardScreen> {
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
      final exams = await _examService.getTeacherExams();
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
          'Exam Monitoring',
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
                      Icon(Icons.analytics_outlined, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(
                        'No exams created yet',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: _exams.length,
                  itemBuilder: (context, index) {
                    final exam = _exams[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      color: isDark ? const Color(0xFF2D2D44) : Colors.white,
                      elevation: 2,
                      child: InkWell(
                        onTap: () {
                          context.push('/teacher/monitoring/${exam['id']}', extra: exam);
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      exam['title'] ?? 'Untitled',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: isDark ? Colors.white : AppTheme.textDark,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    size: 16,
                                    color: isDark ? Colors.grey : Colors.grey[600],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Course ID: ${exam['course_id'] ?? 'N/A'}',
                                style: TextStyle(
                                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  _buildStatChip(
                                    Icons.people_outline,
                                    'View Results',
                                    const Color(0xFF7C7CFF),
                                  ),
                                  const SizedBox(width: 12),
                                  if (exam['expires_at'] != null)
                                    _buildStatChip(
                                      Icons.timer_off_outlined,
                                      'Has Expiration',
                                      Colors.orange,
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  Widget _buildStatChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
