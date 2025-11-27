# Safe Exam App

A secure e-learning and examination application built with Flutter for students and teachers.

## Features

### Student Features
- 📚 **Learning Dashboard**: Browse courses by category with modern UI
- 📖 **Course Materials**: Access videos, PDFs, images, and text content
- 📝 **Exams**: Take multiple choice and essay exams
- 🔒 **Secure Exam Mode**: Device locks during exams to prevent cheating
- 📊 **Progress Tracking**: View course progress and exam results

### Teacher Features
- 📊 **Dashboard**: View statistics and recent activity
- 📤 **Upload Materials**: Add videos, PDFs, images, and text content
- ✏️ **Create Exams**: Build exams with multiple choice and essay questions
- ⚙️ **Exam Settings**: Configure duration, lock mode, and security options
- 👥 **Student Management**: Monitor student progress and exam results

### Secure Exam Lock Mode
When a student starts an exam, the app activates a secure lock mode that:
- 🔐 Locks the device using Android's Lock Task Mode
- 🚫 Prevents exiting the app (blocks Home, Back, Recent Apps)
- 📵 Hides notifications and status bar
- 🖼️ Disables screenshots and screen recording
- ⏰ Auto-submits if the user attempts to leave
- 🔋 Keeps screen awake during exam

## Tech Stack

- **Framework**: Flutter 3.10+
- **State Management**: flutter_bloc
- **Navigation**: go_router
- **UI**: Material Design 3 with custom purple theme
- **Fonts**: Google Fonts (Poppins)
- **Platform**: Android (Lock Task Mode requires Android 5.0+)

## Dependencies

```yaml
flutter_bloc: ^8.1.3
go_router: ^12.0.0
shared_preferences: ^2.2.2
video_player: ^2.8.1
chewie: ^1.7.1
flutter_pdfview: ^1.3.2
wakelock_plus: ^1.1.4
flutter_windowmanager: ^0.2.0
google_fonts: ^6.1.0
```

## Getting Started

### Prerequisites
- Flutter SDK 3.10 or higher
- Android Studio / VS Code
- Android device or emulator (API 21+)

### Installation

1. Clone the repository
```bash
git clone <repository-url>
cd safe_exam_app
```

2. Install dependencies
```bash
flutter pub get
```

3. Run the app
```bash
flutter run
```

### Building APK

```bash
flutter build apk --release
```

## Project Structure

```
lib/
├── core/
│   ├── app_theme.dart          # App theme and colors
│   └── app_router.dart         # Navigation configuration
├── features/
│   ├── auth/
│   │   └── login_screen.dart   # Login with role selection
│   ├── student/
│   │   ├── student_home_screen.dart
│   │   ├── courses_screen.dart
│   │   ├── exams_screen.dart
│   │   └── profile_screen.dart
│   ├── teacher/
│   │   ├── teacher_dashboard_screen.dart
│   │   ├── materials_management_screen.dart
│   │   └── create_exam_screen.dart
│   └── exam/
│       └── exam_detail_screen.dart  # Secure exam mode
└── main.dart
```

## Usage

### For Students

1. **Login**: Select "Student" role and enter credentials
2. **Browse Courses**: Explore available courses on the home screen
3. **Take Exam**: 
   - Navigate to Exams tab
   - Select an available exam
   - Read instructions carefully
   - Click "Start Exam" to enter lock mode
   - Answer questions
   - Submit when finished

### For Teachers

1. **Login**: Select "Teacher" role and enter credentials
2. **Upload Materials**: 
   - Go to Materials tab
   - Click + button
   - Select material type (Video/PDF/Image/Text)
3. **Create Exam**:
   - Go to Create Exam tab
   - Fill in exam details
   - Configure security settings
   - Add questions
   - Save exam

## Security Features

The app implements multiple layers of security for exams:

1. **Lock Task Mode**: Uses Android's `startLockTask()` API to prevent app switching
2. **Immersive Mode**: Hides system UI (status bar, navigation bar)
3. **Secure Flag**: Prevents screenshots and screen recording
4. **Wakelock**: Keeps screen on during exam
5. **Lifecycle Monitoring**: Detects and handles app backgrounding attempts
6. **Auto-Submit**: Automatically submits exam if violation detected

## Known Limitations

- Lock Task Mode requires Android 5.0+ (API 21)
- On some devices, users can still exit by holding power button
- For maximum security, consider using Device Owner mode (requires MDM setup)
- iOS support not yet implemented

## Future Enhancements

- [ ] Real-time exam monitoring
- [ ] Face detection for cheating prevention
- [ ] Offline exam support
- [ ] iOS support
- [ ] Advanced analytics dashboard
- [ ] Multi-language support

## License

This project is licensed under the MIT License.

## Support

For issues and questions, please create an issue in the repository.
