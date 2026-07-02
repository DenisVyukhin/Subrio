# Subrio

## 🇷🇺 Русский

Subrio - iOS-трекер подписок, написанный на Swift.

<p align="center">
  <img src="demo_1.png" alt="Главный экран Subrio" width="160">
  <img src="demo_2.png" alt="Список подписок Subrio" width="160">
  <img src="demo_3.png" alt="Детали подписки Subrio" width="160">
  <img src="demo_4.png" alt="Аналитика Subrio" width="160">
  <img src="demo_5.png" alt="Способы оплаты Subrio" width="160">
</p>

## Возможности

- Отслеживание регулярных подписок, дат оплаты, периодов списания и статусов.
- Управление способами оплаты для удобной организации подписок.
- Просмотр месячных расходов, годового прогноза, аналитики по категориям и ближайших платежей.
- Переключение интерфейса между русским и английским языками.
- Уведомления с напоминаниями перед предстоящими платежами.

## Технологии/Стек

- Swift, SwiftUI
- SwiftData: локальное хранение `Subscription` и `PaymentMethod`
- UserNotifications: локальные напоминания о платежах
- UIKit bridge: haptics, Liquid Glass-навигация и системные visual effects
- CoreImage и QuartzCore: variable blur для sticky header
- `@AppStorage`/UserDefaults: язык, тема и настройки уведомлений
- Собственная локализация EN/RU через `L10n`
- SF Symbols и Asset Catalog
- Xcode-проект без внешних Swift Package зависимостей
- iOS deployment target 26.4

## Структура проекта

```text
Subrio/
  App/          Точка входа приложения и корневой экран
  Components/   Переиспользуемые UI-компоненты
  Models/       SwiftData-модели и перечисления
  Services/     Аналитика, haptics и уведомления
  Storage/      Вспомогательная логика для локального хранилища
  Theme/        Цвета приложения
  Utils/        Форматирование и локализация
  Views/        Экраны функций
```

## Запуск

1. Откройте `Subrio.xcodeproj` в Xcode.
2. Выберите схему `Subrio`.
3. Соберите и запустите приложение в iOS Simulator или на устройстве.

Приложение хранит данные локально на устройстве. Backend, API-ключи и учетные данные не требуются.

## Проверка

Проект проверялся командой:

```sh
xcodebuild -project Subrio.xcodeproj -scheme Subrio -destination 'platform=iOS Simulator,name=iPhone 17' build
```

## Сторонние лицензии

См. `ThirdPartyNotices.md`.

---

## 🇬🇧 English

Subrio is an iOS subscription tracker written in Swift.

<p align="center">
  <img src="demo_1.png" alt="Subrio overview screen" width="160">
  <img src="demo_2.png" alt="Subrio subscriptions list" width="160">
  <img src="demo_3.png" alt="Subrio subscription details" width="160">
  <img src="demo_4.png" alt="Subrio analytics screen" width="160">
  <img src="demo_5.png" alt="Subrio payment methods screen" width="160">
</p>

## Features

- Track recurring subscriptions, payment dates, billing periods and statuses.
- Manage payment methods for organizing subscriptions.
- View monthly spend, yearly forecast, category analytics and upcoming payments.
- Switch between English and Russian interface text.
- Receive notification reminders before upcoming payments.

## Tech Stack

- Swift, SwiftUI
- SwiftData: local persistence for `Subscription` and `PaymentMethod`
- UserNotifications: local payment reminders
- UIKit bridge: haptics, Liquid Glass navigation and system visual effects
- CoreImage and QuartzCore: variable blur for the sticky header
- `@AppStorage`/UserDefaults: language, theme and notification settings
- Custom EN/RU localization through `L10n`
- SF Symbols and Asset Catalog
- Xcode project with no external Swift Package dependencies
- iOS deployment target 26.4

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
