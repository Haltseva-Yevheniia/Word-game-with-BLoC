# word_game_bloc

# Word Game

A Flutter word search game where players create words by swiping through letters in a grid. Get instant feedback through
vibrations of the devise and shaking letters for incorrect words and celebratory sounds with encourage message for
correct ones!

## Features

- Interactive letter grid for word formation
- Real-time word validation
- Haptic feedback (vibration and shake) for incorrect words
- Sound effects for correct word matches
- Clean architecture with BLoC pattern

## Dependencies

dependencies:
flutter:
sdk: flutter
flutter_bloc: ^8.1.6 # State management
vibration: ^2.0.1 # Haptic feedback
audioplayers: ^6.0.0 # Sound effects

## Project Structure

```
lib/
├── blocs/           # BLoC related files
│   ├── game_bloc.dart
│   ├── game_event.dart
│   └── game_state.dart
├── models/         # Data models
├── ui/             # UI screens
│   ├── components/
│   │   ├── line_painter.dart
│   ├── screens/
│   │    ├── word_game_screen.dart
│   ├── widgets/
│   │    ├── letter_cell.dart

```

## Usage

1. Launch the app
2. Touch and hold any letter to start forming a word
3. Swipe through adjacent letters to create words (horizontal or vertical)
4. Get immediate feedback:
    - Correct words trigger a victory sound and text that "You are right!"
    - Incorrect words trigger a vibration and shaking letters

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

