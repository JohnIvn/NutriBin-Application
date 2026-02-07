# NutriBin Application

<img width="936" height="328" alt="image" src="https://github.com/user-attachments/assets/6c962171-3add-41db-a3ba-0d2597b2c2d6" />

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE) [![Project Status](https://img.shields.io/badge/status-Development-green.svg)](#)

NutriBin Application is a comprehensive mobile and web solution designed for managing and monitoring smart waste bins. This repository contains the source code for the Flutter application, which interfaces with backend services hosted on Railway and Supabase.

## Project Overview

NutriBin Application is a platform designed to bridge the gap between household waste management and sustainable agriculture. It allows users to monitor waste levels, manage composting processes, and track fertilizer analytics through an intuitive user interface.

### Tech Stack

- **Framework**: [Flutter](https://flutter.dev/) (Dart)
- **Backend Services**: Hosted on Railway (Node.js/NestJS API) and [Supabase](https://supabase.com/).
- **Maps Integration**: [Google Maps](https://pub.dev/packages/google_maps_flutter) and [Flutter Map](https://pub.dev/packages/flutter_map).
- **Authentication**: Google Sign-In and Supabase Auth.
- **Data Visualization**: [FL Chart](https://pub.dev/packages/fl_chart).

## Project Structure

The project follows the standard Flutter directory structure:

- `lib/`: Contains the core source code of the application (models, pages, services, widgets).
- `assets/`: Images, icons, and configuration files.
- `android/`, `ios/`, `web/`, etc.: Platform-specific code and configurations.
- `test/`: Unit and widget tests.

## Development Setup

### Prerequisites

- **Flutter SDK**: [Install Flutter](https://docs.flutter.dev/get-started/install) (Stable channel).
- **Dart SDK**: Included with Flutter.
- **IDEs**: VS Code (recommended) or Android Studio with Flutter/Dart extensions.

### Installation & Run

1. **Clone the repository**:

   ```bash
   git clone https://github.com/JohnIvn/NutriBin-Application.git
   cd NutriBin-Application
   ```

2. **Install dependencies**:

   ```bash
   flutter pub get
   ```

3. **Configure Environment**:
   Create a `.env` file in the root directory and add the required environment variables (Reach out to maintainers for the specific keys):
   - `RAILWAY_USER`
   - `RAILWAY_SERVER`
   - `GOOGLE_CLIENT_ID`
   - `SUPABASE_URL`
   - `SUPABASE_ANON`

4. **Run the app**:
   ```bash
   flutter run
   ```

## Branching & PR Guidelines

- Create a feature branch from `main`: `feature/short-description` or `fix/short-description`.
- Follow the [Conventional Commits](https://www.conventionalcommits.org/) specification for commit messages.
- Ensure your changes follow the existing code style and pass static analysis.

## Code Quality

- **Linting**: Run `flutter analyze` to check for issues.
- **Formatting**: Use `dart format .` to format the code.
- **Testing**: Run `flutter test` to execute unit and widget tests.

## License

This project is licensed under the MIT License — see [LICENSE](LICENSE).

---

Please refer to [.github/CONTRIBUTING.md](.github/CONTRIBUTING.md) for more details.
