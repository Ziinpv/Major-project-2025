@echo off
echo ========================================
echo Getting SHA-1 Fingerprint for Android
echo ========================================
echo.

echo Method 1: Using Gradle
echo ------------------------
call gradlew signingReport
echo.

echo Method 2: Using keytool (Debug keystore)
echo ----------------------------------------
keytool -list -v -keystore "%USERPROFILE%\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android
echo.

echo ========================================
echo Instructions:
echo 1. Copy the SHA1 value from above
echo 2. Go to Firebase Console
echo 3. Project Settings > Your apps > Android app
echo 4. Add fingerprint > Paste SHA1 > Save
echo 5. Download new google-services.json
echo 6. Replace android/app/google-services.json
echo ========================================
pause

