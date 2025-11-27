import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../core/app_theme.dart';
import 'dart:async';

class ExamDetailScreen extends StatefulWidget {
  final String examId;
  const ExamDetailScreen({super.key, required this.examId});

  @override
  State<ExamDetailScreen> createState() => _ExamDetailScreenState();
}

class _ExamDetailScreenState extends State<ExamDetailScreen> {
  bool _isExamStarted = false;
  bool _isLockModeActive = false;
  int _remainingSeconds = 5400; // 90 minutes
  Timer? _timer;
  int _currentQuestionIndex = 0;
  final Map<int, String> _answers = {};
  final AudioPlayer _audioPlayer = AudioPlayer();

  static const platform = MethodChannel('com.eskalasi.safeexam/lock');

  final List<Map<String, dynamic>> _questions = [
    {
      'question': 'What is the capital of France?',
      'options': ['London', 'Paris', 'Berlin', 'Madrid'],
      'type': 'multiple_choice'
    },
    {
      'question': 'Solve: 2 + 2 = ?',
      'options': ['3', '4', '5', '6'],
      'type': 'multiple_choice'
    },
    {
      'question': 'Explain the process of photosynthesis.',
      'type': 'essay'
    },
  ];

  @override
  void initState() {
    super.initState();
    _setupLifecycleListener();
  }

  void _setupLifecycleListener() {
    SystemChannels.lifecycle.setMessageHandler((msg) async {
      if (_isLockModeActive && msg == AppLifecycleState.paused.toString()) {
        // User tried to leave the app during exam
        _handleExamViolation();
      }
      return null;
    });
  }

  Future<void> _startExam() async {
    final confirmed = await _showConfirmationDialog();
    if (confirmed != true) return;

    setState(() {
      _isExamStarted = true;
    });

    await _enableLockMode();
    _startTimer();
  }

  Future<void> _enableLockMode() async {
    try {
      // Enable wakelock
      await WakelockPlus.enable();

      // Set immersive mode
      await SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.immersiveSticky,
        overlays: [],
      );

      // Lock orientation
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);

      // Try to start lock task mode (Android)
      try {
        await platform.invokeMethod('startLockTask');
      } catch (e) {
        debugPrint('Lock task not available: $e');
      }

      // Disable gesture navigation
      try {
        await platform.invokeMethod('disableGestureNavigation');
      } catch (e) {
        debugPrint('Disable gesture navigation not available: $e');
      }

      // Prevent screenshots
      try {
        await platform.invokeMethod('setSecureFlag');
      } catch (e) {
        debugPrint('Secure flag not available: $e');
      }

      setState(() {
        _isLockModeActive = true;
      });
    } catch (e) {
      debugPrint('Error enabling lock mode: $e');
    }
  }

  Future<void> _disableLockMode() async {
    try {
      // Disable wakelock
      await WakelockPlus.disable();

      // Restore system UI
      await SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.edgeToEdge,
        overlays: SystemUiOverlay.values,
      );

      // Unlock orientation
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
        DeviceOrientation.portraitDown,
      ]);

      // Stop lock task mode
      try {
        await platform.invokeMethod('stopLockTask');
      } catch (e) {
        debugPrint('Lock task stop error: $e');
      }

      // Enable gesture navigation
      try {
        await platform.invokeMethod('enableGestureNavigation');
      } catch (e) {
        debugPrint('Enable gesture navigation error: $e');
      }

      // Remove secure flag
      try {
        await platform.invokeMethod('clearSecureFlag');
      } catch (e) {
        debugPrint('Clear secure flag error: $e');
      }

      setState(() {
        _isLockModeActive = false;
      });
    } catch (e) {
      debugPrint('Error disabling lock mode: $e');
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _submitExam();
        }
      });
    });
  }

  Future<bool?> _showConfirmationDialog() {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Start Exam'),
        content: const Text(
          'Once you start the exam:\n\n'
          '• Your device will be locked\n'
          '• You cannot exit the app\n'
          '• Screenshots will be disabled\n'
          '• All notifications will be hidden\n\n'
          'Are you ready to begin?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Start Exam'),
          ),
        ],
      ),
    );
  }

  void _handleExamViolation() {
    // Play alarm sound and auto-submit exam
    debugPrint('🚨 VIOLATION DETECTED - Playing alarm');
    _playAlarmAndSubmit();
  }

  Future<void> _playAlarmAndSubmit() async {
    debugPrint('🔊 Starting alarm playback...');
    
    try {
      // Set volume to maximum (only on mobile platforms)
      if (!kIsWeb) {
        debugPrint('📢 Setting volume to MAX');
        await platform.invokeMethod('setMaxVolume');
      } else {
        debugPrint('🌐 Running on Web - skipping volume control');
      }
      
      // Play alarm sound
      debugPrint('🎵 Playing sound from: assetsmp3/sound.mp3');
      await _audioPlayer.play(AssetSource('assetsmp3/sound.mp3'));
      
      debugPrint('⏳ Waiting 8 seconds...');
      // Wait for 8 seconds
      await Future.delayed(const Duration(seconds: 8));
      
      // Stop sound
      debugPrint('🛑 Stopping sound');
      await _audioPlayer.stop();
      
      // Restore original volume (only on mobile platforms)
      if (!kIsWeb) {
        debugPrint('🔉 Restoring volume');
        await platform.invokeMethod('restoreVolume');
      }
      
      debugPrint('✅ Alarm completed');
    } catch (e) {
      debugPrint('❌ Error playing alarm: $e');
    }
    
    // Submit exam after alarm
    debugPrint('📝 Submitting exam');
    if (mounted) {
      _submitExam(violation: true);
    }
  }

  Future<void> _showSubmitConfirmation() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Submit Exam?'),
        content: const Text('Are you sure you want to submit your exam?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Submit'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      _submitExam();
    }
  }

  Future<void> _submitExam({bool violation = false}) async {
    _timer?.cancel();
    await _disableLockMode();

    if (!mounted) return;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(violation ? 'Exam Violation' : 'Exam Submitted'),
        content: Text(
          violation
              ? 'You attempted to leave the exam. Your answers have been auto-submitted.'
              : 'Your exam has been submitted successfully.',
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.go('/exam/result/${widget.examId}');
            },
            child: const Text('View Results'),
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (!_isExamStarted) {
      return _buildExamInstructions();
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (_isLockModeActive) {
          _handleExamViolation();
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: const Color(0xFF7C7CFF),
          automaticallyImplyLeading: false,
          elevation: 0,
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Color(0xFF7C7CFF),
            statusBarIconBrightness: Brightness.light,
          ),
          title: Row(
            children: [
              const Icon(Icons.timer, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                _formatTime(_remainingSeconds),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: _showSubmitConfirmation,
              child: const Text(
                'Submit',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),

        body: Column(
          children: [
            // Progress Indicator
            LinearProgressIndicator(
              value: (_currentQuestionIndex + 1) / _questions.length,
              backgroundColor: AppTheme.lightPurple,
              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryPurple),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: _buildQuestion(_questions[_currentQuestionIndex]),
              ),
            ),
            // Navigation Buttons
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF2D2D44) : Colors.white,
              ),
              child: Row(
                children: [
                  if (_currentQuestionIndex > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() {
                            _currentQuestionIndex--;
                          });
                        },
                        child: const Text('Previous'),
                      ),
                    ),
                  if (_currentQuestionIndex > 0) const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (_currentQuestionIndex < _questions.length - 1) {
                          setState(() {
                            _currentQuestionIndex++;
                          });
                        }
                      },
                      child: Text(
                        _currentQuestionIndex < _questions.length - 1 ? 'Next' : 'Review',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExamInstructions() {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : AppTheme.textDark),
          onPressed: () => context.pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Exam Instructions',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).brightness == Brightness.dark ? Colors.white : AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 24),
            _buildInstructionItem(Icons.timer, 'Duration: 90 minutes'),
            _buildInstructionItem(Icons.quiz, 'Total Questions: ${_questions.length}'),
            _buildInstructionItem(Icons.lock, 'Device will be locked during exam'),
            _buildInstructionItem(Icons.screenshot_outlined, 'Screenshots disabled'),
            _buildInstructionItem(Icons.warning_amber, 'Leaving app will auto-submit'),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _startExam,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Start Exam'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionItem(IconData icon, String text) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF7C7CFF).withOpacity(0.2) : AppTheme.lightPurple,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: const Color(0xFF7C7CFF), size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.white : AppTheme.textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestion(Map<String, dynamic> question) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2D2D44) : Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Question ${_currentQuestionIndex + 1}',
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textGrey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            question['question'],
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 24),
          if (question['type'] == 'multiple_choice')
            ...List.generate(
              question['options'].length,
              (index) => _buildOption(
                question['options'][index],
                index,
              ),
            )
          else
            TextField(
              maxLines: 8,
              decoration: InputDecoration(
                hintText: 'Type your answer here...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                _answers[_currentQuestionIndex] = value;
              },
            ),
        ],
      ),
    );
  }

  Widget _buildOption(String option, int index) {
    final isSelected = _answers[_currentQuestionIndex] == option;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () {
        setState(() {
          _answers[_currentQuestionIndex] = option;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected 
              ? const Color(0xFF7C7CFF).withOpacity(0.2) 
              : (isDark ? const Color(0xFF1E1E2C) : Colors.grey[100]),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF7C7CFF) : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? const Color(0xFF7C7CFF) : (isDark ? const Color(0xFF2D2D44) : Colors.white),
                border: Border.all(
                  color: isSelected ? const Color(0xFF7C7CFF) : Colors.grey,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                option,
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? Colors.white : AppTheme.textDark,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioPlayer.dispose();
    _disableLockMode();
    super.dispose();
  }
}
