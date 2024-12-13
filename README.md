# word_game_bloc

# Word Game

A Flutter word search game where players create words by swiping through letters in a grid. Get instant feedback through
vibrations of the devise and shaking letters for incorrect words and celebratory sounds with encourage message for
correct ones!

# Game demo

<video src="./app_video.mp4" width="640" height="480" controls></video>

## Features

- Interactive letter grid for word formation
- Real-time word validation
- Haptic feedback (vibration and shake) for incorrect words
- Sound effects for correct word matches
- App architecture based on BLoC pattern


## Project Structure

```
lib/
├── blocs/           # BLoC related files
│   ├── game_bloc.dart
│   ├── game_event.dart
│   └── game_state.dart
├── model/         # Data models
│   ├── position.dart
├── services/       # game services
│   ├── audio_service.dart
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

