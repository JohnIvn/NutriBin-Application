# Contributing to NutriBin Application

Thank you for your interest in contributing to NutriBin Application! We welcome improvements, bug reports, and new feature ideas.

## Project Overview

NutriBin Application is a platform designed to bridge the gap between household waste management and sustainable agriculture. It allows users to monitor waste levels, manage composting processes, and track fertilizer analytics via a mobile and web application.

### Tech Stack

- **Framework**: [Flutter](https://flutter.dev/) (Dart)
- **Backend Services**: Hosted on Railway (Node.js/NestJS API) and [Supabase](https://supabase.com/).
- **Maps**: [Google Maps](https://pub.dev/packages/google_maps_flutter) and [Flutter Map](https://pub.dev/packages/flutter_map).
- **Authentication**: Google Sign-In and Supabase Auth.
- **Other Key Packages**: `flutter_dotenv`, `http`, `jwt_decoder`, `geolocator`, `fl_chart`.

## Project Structure

The project follows a standard Flutter directory structure:

- `lib/`: Contains the core source code of the application.
  - `models/`: Data models for the application.
  - `pages/`: Individual screens and page widgets.
  - `services/`: API and third-party service integration logic.
  - `utils/`: Helper functions and utilities.
  - `widgets/`: Reusable UI components.
- `assets/`: Images, icons, and configuration files.
- `android/`, `ios/`, `web/`, etc.: Platform-specific code and configurations.
- `test/`: Unit and widget tests.

## How to Contribute

- Discuss big changes or feature ideas by opening an issue first.
- For bug reports, please include:
  - Steps to reproduce the issue.
  - Expected vs. actual behavior.
  - Device info (OS version, screen size) and logs if applicable.
- When you're ready to contribute code, open a Pull Request (PR) with a clear title and description.

## Development Setup

### Prerequisites

- **Flutter SDK**: [Install Flutter](https://docs.flutter.dev/get-started/install) (Stable channel recommended).
- **Dart SDK**: Included with Flutter.
- **Android Studio / Xcode**: For mobile development and emulators/simulators.
- **VS Code**: Recommended editor with Flutter and Dart extensions.

### Local Setup

1. **Clone the repository**:

   ```bash
   git clone https://github.com/JohnIvn/NutriBin-Application.git
   cd NutriBin-Application
   ```

2. **Install dependencies**:

   ```bash
   flutter pub get
   ```

3. **Environment Variables**:
   Create a `.env` file in the root directory based on the variables used in the project (reach out to maintainers for the necessary keys):
   - `RAILWAY_USER`: Backend API URL.
   - `RAILWAY_SERVER`: Alternative Backend API URL.
   - `GOOGLE_CLIENT_ID`: Google OAuth Client ID.
   - `SUPABASE_URL`: Your Supabase project URL.
   - `SUPABASE_ANON`: Your Supabase anonymous key.

4. **Run the application**:
   - To run on a connected device or emulator:
     ```bash
     flutter run
     ```
   - To run on the web:
     ```bash
     flutter run -d chrome
     ```

## Branching & PR Guidelines

- Create a feature branch from `main`: `feature/short-description` or `fix/short-description`.
- Follow the [Conventional Commits](https://www.conventionalcommits.org/) specification for commit messages.
- Ensure your changes follow the existing code style and pass static analysis.

## Code Quality

- **Linting**:
  Check for linting issues using the command:
  ```bash
  flutter analyze
  ```
- **Formatting**:
  Format your code according to Dart guidelines:
  ```bash
  dart format .
  ```
- **Testing**:
  Run unit and widget tests:
  ```bash
  flutter test
  ```

## Code of Conduct

Please follow our [Code of Conduct](CODE_OF_CONDUCT.md). Respectful, inclusive behavior is expected.

---

## Pull Request Checklist

Before opening a PR, please make sure your changes meet the checklist below:

- [ ] I have tested my changes on at least one platform (Android, iOS, or Web).
- [ ] My code follows the project's code style (run `dart format`).
- [ ] I have updated documentation if necessary.
- [ ] All tests pass (run `flutter test`).

Suggested PR description template:

```markdown
### Description

- What changed and why.

### How to test

- Steps to verify the changes.

### Screenshots (if applicable)

- Add any relevant screenshots for frontend changes.
```
