<div align="center">

<br>

<img src="assets/readme_logo.png" width="140"/>

# Taskee

**Minimalist Notes & Pages Manager for Android & iOS**

Organize your thoughts. Build a personal knowledge space. Keep everything on your device.

![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B?style=flat-square&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?style=flat-square&logo=dart&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-10B981?style=flat-square)
![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-lightgrey?style=flat-square)

</div>

---

## Overview

Taskee is an offline-first Flutter notes application. Its notes workspace supports folders, nested pages and block-based writing while retaining the original dark visual theme.

## Features

- **Notes workspace** — Create, edit, rename and delete pages.
- **Folders** — Organize pages into folders and nested folders.
- **Nested pages** — Create subpages from inside a page.
- **Block editor** — Paragraphs, headings, subheadings, bullets and numbered lists.
- **Toggle blocks** — Expand or collapse content sections.
- **Checklists** — Interactive checkbox blocks.
- **Favorites** — Mark important pages and keep them near the top.
- **Search** — Find pages by title.
- **Offline-first storage** — Local Hive database; no account or cloud service required.
- **Legacy note support** — Existing plain-text notes remain readable and editable.

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter / Dart |
| State management | Bloc |
| Local storage | Hive |
| Navigation | GoRouter |
| Dependency injection | GetIt |
| UI | Material Design 3 |

## Build Android APK

1. Install Flutter stable and Java 17.
2. Run `flutter pub get`.
3. Run `dart run build_runner build --delete-conflicting-outputs`.
4. Run `flutter build apk --release`.

GitHub Actions also builds a release APK on pushes and manual workflow dispatch. Download the `taskee-android-release-apk` artifact from the Actions run.

## License

MIT License. See [LICENSE](LICENSE).
