#  Sonora

Sonora is a beautiful, offline-first local music player built with Flutter. Designed for audiophiles who want a pure music experience without interruptions, ads, or distractions.



## 📱 Screenshots

<img width="720" height="1600" alt="photo_5825617469509407320_w" src="https://github.com/user-attachments/assets/10e8150d-029c-4f48-93c8-39986045c3d6" />
<img width="720" height="1600" alt="photo_5825617469509407319_w" src="https://github.com/user-attachments/assets/ebcd22c8-2034-4b3e-ac40-4094b87d85f4" />
<img width="720" height="1600" alt="photo_5825617469509407318_w" src="https://github.com/user-attachments/assets/137f5990-e95b-4091-9f2b-f3fc959c65a0" />
<img width="720" height="1600" alt="photo_5825617469509407317_w" src="https://github.com/user-attachments/assets/43f44ec6-dad4-4899-9ac2-fcd5bcc95bf4" />
<img width="720" height="1600" alt="photo_5825617469509407321_w" src="https://github.com/user-attachments/assets/ab94243d-8118-4ae8-937b-d30d16db2893" />
<img width="720" height="1600" alt="photo_5825617469509407323_w" src="https://github.com/user-attachments/assets/42e74bc2-57ad-4f20-a08e-19a3c3926b00" />
<img width="720" height="1600" alt="photo_5825617469509407325_w" src="https://github.com/user-attachments/assets/06336b13-37f7-4c4b-8547-e05857a72814" />
<img width="720" height="1600" alt="photo_5825617469509407324_w" src="https://github.com/user-attachments/assets/706217d0-2d47-4c08-a099-655f9800155a" />




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
