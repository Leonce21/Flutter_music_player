#  Sonora

Sonora is a beautiful, offline-first local music player built with Flutter. Designed for audiophiles who want a pure music experience without interruptions, ads, or distractions.



## 📱 Screenshots





## ✨ Features

-  Offline Playback: Seamlessly plays local audio files directly from your device storage.
- 🎨 Beautiful Dark UI: Sleek, modern interface with smooth animations and custom page transitions.
- 📂 Smart Library: Organize and browse your music by Songs, Artists, Albums, and Folders.
- ❤️ Favorites & Playlists: Create custom playlists and easily save your favorite tracks.
- 🔍 Quick Search: Find your music instantly with a fast search engine and history tracking.
- 📝 Synced Lyrics: Automatically loads and displays synchronized `.lrc` lyrics files.
- 🌙 Smooth Onboarding: Welcoming onboarding flow for new users with seamless permission handling.
- ⚙️ Data Control: Rescan media library, clear cache, and manage your data privacy easily.



## 🛠️ Tech Stack

- Framework: [Flutter](https://flutter.dev/)
- State Management: [Flutter Riverpod](https://riverpod.dev/)
- Navigation: [GoRouter](https://pub.dev/packages/go_router)
- Local Storage: [Hive](https://pub.dev/packages/hive_flutter)
- Audio Engine: [Just Audio](https://pub.dev/packages/just_audio) & [Just Audio Background](https://pub.dev/packages/just_audio_background)
- Media Query: [On Audio Query](https://pub.dev/packages/on_audio_query)
- UI & Icons: [Google Fonts](https://pub.dev/packages/google_fonts), [Iconsax](https://pub.dev/packages/iconsax_flutter)



## 📂 Project Structure

The project follows a Feature-First architecture, keeping code organized, scalable, and easy to maintain.

lib/
├── core/                   # Shared resources, utilities, and global configurations
│   ├── router/             # GoRouter configuration and custom page transitions
│   ├── services/           # Permissions, local storage (Hive), and Riverpod providers
│   ├── theme/              # App colors, typography, spacing, and global theme data
│   ├── utils/              # Helper functions (formatters, sorting, LRC parser)
│   └── widgets/            # Reusable UI components (buttons, tiles, sheets, scrollbars)
│
├── features/               # Feature-based modules
│   ├── favorites/          # Favorites screen and logic
│   ├── home/               # Home shell, bottom navigation, and suggested tab
│   ├── library/            # Media library (Songs, Artists, Albums, Folders)
│   │   ├── application/    # Riverpod notifiers and providers
│   │   ├── data/           # Repository and data sources
│   │   └── presentation/   # UI screens and widgets
│   ├── onboarding/         # Splash screen and onboarding flow
│   ├── player/             # Audio player controller and Now Playing screen
│   ├── playlists/          # Playlist management screen
│   ├── search/             # Search screen with history
│   └── settings/           # Settings screen and app info
│
└── main.dart               # Application entry point