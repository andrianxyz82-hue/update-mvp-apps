import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/app_theme.dart';

class ExamResultScreen extends StatelessWidget {
  final String examId;
  
  const ExamResultScreen({super.key, required this.examId});

  @override
  Widget build(BuildContext context) {
    // Dummy data - in real app, this would come from exam submission
    final examResults = {
      '0': {
        'examName': 'Mathematics Final Exam',
        'totalQuestions': 50,
        'correctAnswers': 42,
        'wrongAnswers': 8,
        'score': 84,
        'duration': '90 min',
        'completedIn': '75 min',
      },
      '1': {
        'examName': 'Physics Mid-Term',
        'totalQuestions': 30,
        'correctAnswers': 25,
        'wrongAnswers': 5,
        'score': 83,
        'duration': '60 min',
        'completedIn': '55 min',
      },
    };

    final result = examResults[examId] ?? examResults['0']!;
    final correctAnswers = result['correctAnswers'] as int;
    final wrongAnswers = result['wrongAnswers'] as int;
    final totalQuestions = result['totalQuestions'] as int;
    final score = result['score'] as int;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => context.go('/student/home'),
        ),
        title: const Text(
          'Exam Result',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Exam Name
            Text(
              result['examName'] as String,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),

            // Score Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF7C7CFF), Color(0xFF5C5CE0)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  const Text(
                    'Your Score',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '$score',
                    style: const TextStyle(
                      fontSize: 72,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Text(
                    'out of 100',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildScoreDetail(
                        Icons.check_circle,
                        'Correct',
                        '$correctAnswers',
                        Colors.greenAccent,
                      ),
                      _buildScoreDetail(
                        Icons.cancel,
                        'Wrong',
                        '$wrongAnswers',
                        Colors.redAccent,
                      ),
                      _buildScoreDetail(
                        Icons.quiz,
                        'Total',
                        '$totalQuestions',
                        Colors.white70,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Analytics Chart
            const Text(
              'Answer Analysis',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF2D2D44),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  // Bar Chart
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildBar(
                        'Correct',
                        correctAnswers,
                        totalQuestions,
                        Colors.greenAccent,
                      ),
                      _buildBar(
                        'Wrong',
                        wrongAnswers,
                        totalQuestions,
                        Colors.redAccent,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Percentage breakdown
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildPercentage(
                        'Accuracy',
                        '${((correctAnswers / totalQuestions) * 100).toStringAsFixed(1)}%',
                        Colors.greenAccent,
                      ),
                      _buildPercentage(
                        'Error Rate',
                        '${((wrongAnswers / totalQuestions) * 100).toStringAsFixed(1)}%',
                        Colors.redAccent,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Exam Details
            const Text(
              'Exam Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF2D2D44),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  _buildDetailRow(
                    Icons.timer_outlined,
                    'Duration',
                    result['duration'] as String,
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    Icons.access_time,
                    'Completed In',
                    result['completedIn'] as String,
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    Icons.quiz_outlined,
                    'Total Questions',
                    '$totalQuestions',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Action Buttons
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.go('/student/home'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7C7CFF),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Back to Home',
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

  Widget _buildScoreDetail(IconData icon, String label, String value, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildBar(String label, int value, int total, Color color) {
    final percentage = (value / total);
    final maxHeight = 150.0;
    final barHeight = maxHeight * percentage;

    return Column(
      children: [
        Text(
          '$value',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 60,
          height: barHeight,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildPercentage(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF7C7CFF), size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
