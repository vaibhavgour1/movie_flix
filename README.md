# movie_flix

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
# movie_flix

# Install all packages
flutter pub get

# Verify installation
flutter pub deps
   bash# Generate JSON serialization and Retrofit code
   flutter pub run build_runner build --delete-conflicting-outputs

# This creates movie.g.dart and tmdb_api.g.dart

Test Features

Home Screen

Launch app
Verify trending movies load
Verify now playing movies load
Test pull-to-refresh


Movie Details

Tap any movie card
Verify details page opens
Check all information displays


Search

Go to Search tab
Type movie name
Verify results update as you type
Wait 500ms to confirm debouncing


Bookmarks

Bookmark a movie from details
Go to Saved tab
Verify movie appears
Remove bookmark and verify removal


Deep Links

Share a movie
Click the shared link
Verify app opens to that movie


Offline Mode

Turn off WiFi/data
Close and reopen app
Verify cached data shows
Try navigation