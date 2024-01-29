# login_template_app

## Getting Started

This project is a starting point for a Flutter application that connects to a Parse Back4App project.

### Prerequisites

- Flutter SDK installed on your machine
- An IDE with Flutter SDK & Dart plugin
- A Back4App account

### Setup

1. Clone this repository to your local machine.
2. Open the project in your preferred IDE.
3. Navigate to `lib/database_service.dart`.

### Connecting to Parse Back4App

1. In `database_helper.dart`, replace `YOUR_APP_ID_HERE` and `YOUR_CLIENT_KEY_HERE` with your Back4App Application ID and Client Key respectively.
2. Replace `YOUR_SERVER_URL_HERE` with your Back4App server URL.

```dart
const String PARSE_APP_ID = 'YOUR_APP_ID_HERE';
const String PARSE_CLIENT_KEY = 'YOUR_CLIENT_KEY_HERE';
const String PARSE_SERVER_URL = 'YOUR_SERVER_URL_HERE';