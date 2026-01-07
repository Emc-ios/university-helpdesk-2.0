# Google Generative AI SDK Setup Instructions

## Step 1: Get Your API Key

1. Go to [Google AI Studio](https://aistudio.google.com/app/apikey)
2. Sign in with your Google account
3. Click "Create API Key"
4. Copy the API key (it should start with `AIza...`)

## Step 2: Add API Key to Your App

1. Open `lib/screens/student/chatbot_screen.dart`
2. Find the line: `final String _apiKey = 'YOUR_API_KEY_HERE';`
3. Replace `YOUR_API_KEY_HERE` with your actual API key from Step 1

## Step 3: Update Dependencies

Run this command in your terminal:

```bash
flutter pub get
```

## Step 4: Enable API in Google Cloud Console

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Select your project (or create one)
3. Navigate to "APIs & Services" > "Library"
4. Search for "Generative Language API"
5. Click "Enable"

## Step 5: Test the Chatbot

1. Run your app: `flutter run`
2. Navigate to the Chatbot screen
3. Try asking a question
4. Check the console for any errors

## Troubleshooting

### Error: "API key not valid"

- Make sure you copied the entire API key
- Verify the API key is active in Google AI Studio
- Check that the Generative Language API is enabled

### Error: "Model not found"

- The app uses `gemini-pro` which should be available
- If you get this error, try updating the package version

### Error: "Quota exceeded"

- Free tier has rate limits
- Wait a few minutes and try again
- Consider upgrading to a paid plan for higher limits

## Package Version

Current version: `google_generative_ai: ^0.4.0`

To check for updates:

```bash
flutter pub outdated
flutter pub upgrade
```
