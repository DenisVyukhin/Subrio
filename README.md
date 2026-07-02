# Subrio

Subrio is a local-first iOS subscription tracker built with SwiftUI and SwiftData.

## Features

- Track recurring subscriptions, payment dates, billing periods and statuses.
- Manage local payment methods for organizing subscriptions.
- View monthly spend, yearly forecast, category analytics and upcoming payments.
- Switch between English and Russian interface text.
- Use local notification reminders before upcoming payments.

## Tech Stack

- SwiftUI
- SwiftData
- UserNotifications
- Xcode project structure with file-system synchronized groups

## Project Structure

```text
Subrio/
  App/          App entry point and root view
  Components/   Reusable UI components
  Models/       SwiftData models and enums
  Services/     Analytics, haptics and notifications
  Storage/      Local storage maintenance helpers
  Theme/        App colors
  Utils/        Formatting and localization helpers
  Views/        Feature screens
```

## Getting Started

1. Open `Subrio.xcodeproj` in Xcode.
2. Select the `Subrio` scheme.
3. Build and run on an iOS simulator or device.

The app stores data locally on device. It does not require backend credentials or API keys.

## Verification

The project was checked with:

```sh
xcodebuild -project Subrio.xcodeproj -scheme Subrio -destination 'platform=iOS Simulator,name=iPhone 17' build
```

## Third-Party Notices

See `ThirdPartyNotices.md`.
