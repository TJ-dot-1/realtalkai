# RealTalk AI — Firebase Setup Guide

## 1. Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click **Add Project** → Name it `realtalk-ai`
3. Enable **Google Analytics** (optional)
4. Click **Create Project**

## 2. Add Apps

### Android
1. Click **Add App** → Android
2. Package name: `com.realtalk.realtalk_ai`
3. Download `google-services.json`
4. Place it in: `android/app/google-services.json`

### iOS
1. Click **Add App** → iOS
2. Bundle ID: `com.realtalk.realtalkAi`
3. Download `GoogleService-Info.plist`
4. Place it in: `ios/Runner/GoogleService-Info.plist`

## 3. Enable Authentication

1. Go to **Build** → **Authentication**
2. Click **Get Started**
3. Enable **Email/Password** provider
4. Enable **Google** provider
5. Configure OAuth consent screen if needed

## 4. Create Firestore Database

1. Go to **Build** → **Firestore Database**
2. Click **Create Database**
3. Start in **test mode** (for development)
4. Choose your region (pick closest to your users)

### Firestore Security Rules (Production)
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Sessions — users can only access their own
    match /sessions/{sessionId} {
      allow read, write: if request.auth != null 
        && resource.data.userId == request.auth.uid;
      allow create: if request.auth != null;
    }
    
    // Feedback — users can only access their own
    match /feedback/{sessionId} {
      allow read, write: if request.auth != null;
    }
    
    // Progress — users can only access their own
    match /progress/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

## 5. Collections Schema

### `users/{userId}`
| Field | Type | Description |
|-------|------|-------------|
| email | string | User's email |
| displayName | string | User's name |
| createdAt | timestamp | Account creation date |
| totalSessions | number | Total completed sessions |
| averageFluencyScore | number | Running average |
| completedScenarios | array | IDs of completed scenarios |

### `sessions/{sessionId}`
| Field | Type | Description |
|-------|------|-------------|
| userId | string | Owner's UID |
| scenarioId | string | e.g., "job_interview" |
| characterId | string | e.g., "strict" |
| startedAt | timestamp | Session start |
| endedAt | timestamp | Session end |
| messages | array | Chat message objects |
| feedbackGenerated | boolean | Whether feedback exists |

### `feedback/{sessionId}`
| Field | Type | Description |
|-------|------|-------------|
| userId | string | Owner's UID |
| sessionId | string | Related session |
| confidenceScore | number | 0-100 |
| fluencyScore | number | 0-100 |
| grammarCorrections | array | Correction objects |
| improvedResponses | array | Suggestion objects |
| strengths | array | String list |
| areasToImprove | array | String list |
| overallFeedback | string | AI summary |

### `progress/{userId}`
| Field | Type | Description |
|-------|------|-------------|
| fluencyScores | array | History of scores |
| sessionsCompleted | number | Total count |
| scenarioProgress | map | Per-scenario stats |
| streak | number | Consecutive days |
| lastSessionDate | timestamp | Last session |

## 6. Activate Firebase in Flutter

### Uncomment in `pubspec.yaml`:
```yaml
firebase_core: ^2.24.0
firebase_auth: ^4.16.0
cloud_firestore: ^4.13.0
```

### Update `main.dart`:
```dart
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const ProviderScope(child: RealTalkApp()));
}
```

### Update `firebase_service.dart`:
Replace the placeholder implementations with actual Firebase calls.

## 7. Install Firebase CLI (Optional)
```bash
npm install -g firebase-tools
firebase login
firebase init
```

## 8. OpenAI API Setup

1. Go to [OpenAI Platform](https://platform.openai.com/)
2. Create an API key
3. Add it to `lib/config/api_config.dart`:
```dart
static const String openAiApiKey = 'sk-your-key-here';
```

> ⚠️ **Security Note**: In production, move the API key to a backend
> (Firebase Cloud Functions) to avoid exposing it in the client app.
