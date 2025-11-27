import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:safe_exam_app/features/splash/splash_screen.dart';
import 'package:safe_exam_app/features/auth/login_screen.dart';
import 'package:safe_exam_app/features/student/student_home_screen.dart';
import 'package:safe_exam_app/features/student/courses_screen.dart';
import 'package:safe_exam_app/features/student/exams_screen.dart';
import 'package:safe_exam_app/features/student/profile_screen.dart';
import 'package:safe_exam_app/features/teacher/teacher_dashboard_screen.dart';
import 'package:safe_exam_app/features/teacher/teacher_courses_screen.dart';
import 'package:safe_exam_app/features/teacher/teacher_exams_screen.dart';
import 'package:safe_exam_app/features/exam/exam_detail_screen.dart';
import 'package:safe_exam_app/features/exam/exam_result_screen.dart';
import 'package:safe_exam_app/features/teacher/monitoring/monitoring_dashboard_screen.dart';
import 'package:safe_exam_app/features/teacher/monitoring/exam_results_list_screen.dart';
import 'package:safe_exam_app/features/student/widgets/custom_bottom_nav_bar.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const LoginScreen(),
      ),
      
      // Student Routes
      GoRoute(
        path: '/student/home',
        builder: (context, state) => const StudentBottomNav(),
      ),
      
      // Teacher Routes
      GoRoute(
        path: '/teacher/dashboard',
        builder: (context, state) => const TeacherBottomNav(),
      ),
      GoRoute(
        path: '/teacher/monitoring/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '0';
          final examData = state.extra as Map<String, dynamic>;
          return ExamResultsListScreen(examId: id, examData: examData);
        },
      ),
      
      // Exam Routes
      GoRoute(
        path: '/exam/detail/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '0';
          return ExamDetailScreen(examId: id);
        },
      ),
      GoRoute(
        path: '/exam/result/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '0';
          return ExamResultScreen(examId: id);
        },
      ),
    ],
  );
}

// Student Bottom Navigation
class StudentBottomNav extends StatefulWidget {
  const StudentBottomNav({super.key});

  @override
  State<StudentBottomNav> createState() => _StudentBottomNavState();
}

class _StudentBottomNavState extends State<StudentBottomNav> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const StudentHomeScreen(),
    const CoursesScreen(),
    const ExamsScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        icons: const [
          Icons.home_rounded,
          Icons.book_rounded,
          Icons.assignment_rounded,
          Icons.person_rounded,
        ],
      ),
    );
  }
}

// Teacher Bottom Navigation
class TeacherBottomNav extends StatefulWidget {
  const TeacherBottomNav({super.key});

  @override
  State<TeacherBottomNav> createState() => _TeacherBottomNavState();
}

class _TeacherBottomNavState extends State<TeacherBottomNav> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const TeacherDashboardScreen(),
    const TeacherCoursesScreen(),
    const TeacherExamsScreen(),
    const MonitoringDashboardScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        icons: const [
          Icons.dashboard_rounded,
          Icons.book_rounded,
          Icons.assignment_rounded,
          Icons.analytics_rounded,
          Icons.person_rounded,
        ],
      ),
    );
  }
}
