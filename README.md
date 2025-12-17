# NoteMind 🧠

A modern and intelligent Flutter Notes App focused on simplicity, smooth design, and local functionality.

## Features

### 📝 Text Notes
- Create, edit, and delete text notes
- Notes stored locally using Hive
- Smooth animations and transitions
- Each note has a title, content, and date

### ✅ Checklist Notes
- Create notes in checklist mode
- Toggle items with animated checkboxes
- Checked items show line-through + fade effect
- Add or remove checklist items dynamically
- Progress indicator showing completion percentage
- Reorderable items with drag and drop

### 🎙 Speech-to-Text Notes
- Voice-to-text functionality using `speech_to_text` package
- Microphone button inside note editor
- Live speech-to-text conversion
- Visual feedback when listening

### 🤖 AI Writing Assistant (Optional)
- **Rewrite Formally** - Transform notes into professional tone
- **Correct Grammar & Spelling** - Fix errors automatically
- **Summarize Note** - Generate concise summaries
- Powered by OpenAI GPT-3.5-turbo
- Requires OpenAI API key (see [AI_ASSISTANT_GUIDE.md](AI_ASSISTANT_GUIDE.md))

### ⚙️ Settings
- Toggle between Light / Dark mode with smooth transition
- Clear all notes option with confirmation dialog
- About section with app information

### 🎨 Design & UI
- Clean, minimal, and aesthetic UI
- Rounded corners, shadows, soft animations
- Smooth navigation transitions (Fade + Slide)
- Animated Floating Action Button (FAB)
- Light mode: Off-white background + soft blue accent
- Dark mode: Charcoal background + teal accent

## Getting Started

### Prerequisites
- Flutter SDK (3.7.2 or higher)
- Dart SDK
- Android Studio / VS Code with Flutter extensions

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd Note_Mind
```

2. Install dependencies:
```bash
flutter pub get
```

3. Generate Hive adapters:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

4. Run the app:
```bash
flutter run
```

### Android Permissions

For speech-to-text functionality, add the following to `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.RECORD_AUDIO"/>
<uses-permission android:name="android.permission.INTERNET"/>
```

### iOS Permissions

For iOS, add the following to `ios/Runner/Info.plist`:

```xml
<key>NSMicrophoneUsageDescription</key>
<string>This app needs microphone access to convert speech to text</string>
<key>NSSpeechRecognitionUsageDescription</key>
<string>This app needs speech recognition to convert your voice to text</string>
```

## Dependencies

- **flutter_animate**: ^4.5.0 - Smooth animations
- **animated_text_kit**: ^4.2.2 - Animated text effects
- **speech_to_text**: ^6.6.0 - Speech recognition
- **hive**: ^2.2.3 - Local database
- **hive_flutter**: ^1.1.0 - Hive Flutter integration
- **provider**: ^6.1.1 - State management
- **intl**: ^0.19.0 - Date formatting
- **http**: ^1.1.0 - API requests for AI features

## Project Structure

```
lib/
├── config/
│   └── api_config.dart           # AI API configuration
├── models/
│   ├── note_model.dart
│   └── note_model.g.dart          # Generated Hive adapters
├── providers/
│   ├── notes_provider.dart
│   └── theme_provider.dart
├── screens/
│   ├── splash_screen.dart
│   ├── home_screen.dart
│   ├── note_editor_screen.dart
│   ├── checklist_screen.dart
│   └── settings_screen.dart
├── services/
│   ├── speech_service.dart
│   └── ai_service.dart            # AI writing assistant
├── widgets/
│   └── ai_assistant_sheet.dart    # AI UI component
└── main.dart
```

## Features in Detail

### Splash Screen
- Animated logo with fade-in effect
- Smooth slide transition to home page

### Home Page
- Display all notes as cards
- Each card shows title, preview, and date
- Animated FAB with 3 options:
  - ✍️ Text Note
  - ✅ Checklist
  - 🎙 Voice Note
- Bottom navigation bar

### Note Editor
- Title and content fields
- Microphone button for speech-to-text
- Visual feedback when listening
- Character count display
- Auto-save functionality

### Checklist Page
- Add, edit, and delete checklist items
- Animated checkboxes
- Progress indicator
- Reorderable items
- Convert to text note option

### Settings Page
- Theme toggle with smooth transition
- Clear all notes with confirmation
- About section with app information

## App Personality

Calm. Minimal. Smart. Feels like writing in a personal digital notebook with AI assistance.
Focus on smoothness and emotional comfort for the user.

## License

This project is open source and available under the MIT License.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
