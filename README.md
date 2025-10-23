# Requirement Document: Task Notification Flutter App

## 1. Project Overview
**App Name:** FocusTrack
**Purpose:** Flutter-based mobile app for task notifications using backend API updates.
**Target Platform:** Android (primary)
**Flutter Version:** Latest stable

---

## 2. Functional Requirements

### 2.1 User Tasks
- Connect to backend API to fetch tasks.
- Task fields:
  - `id`, `title`, `description`, `status`, `updated_at`

### 2.2 Notifications
#### 2.2.1 Hourly Notifications
- Fetch tasks hourly from API.
- Notify if new/updated tasks exist.
- Notification content example:
  - Title: "Task Update Available"
  - Body: "You have 3 tasks updated. Check now."

#### 2.2.2 Reminder Notifications
- For pending tasks, send reminders every 5 minutes.
- Notification content example:
  - Title: "Pending Task Reminder"
  - Body: "Task ‘Design UI’ is still pending. Please update."

#### 2.2.3 Notification Behavior
- Click opens app → navigates to task details.
- Channels:
  - `channel_updates`: Hourly updates
  - `channel_reminders`: 5-minute reminders

### 2.3 API Integration
- Endpoint: `/tasks` (GET)
- Authentication: Bearer token
- Response JSON:
```json
[
  {
    "id": 101,
    "title": "Design UI",
    "description": "Create main app screens",
    "status": "Pending",
    "updated_at": "2025-10-22T10:00:00Z"
  }
]
```
- Parse JSON → schedule notifications

### 2.4 Settings
- Enable/disable notifications (hourly/5-min)
- Optional: configure reminder interval

---

## 3. Non-Functional Requirements
- Offline handling: queue notifications
- Battery optimization: exact alarms only if permitted
- Performance: asynchronous background fetch
- Logging: task updates & notifications

---

## 4. Notification Architecture
| Notification Type          | Channel ID        | Repeat Interval       | Schedule Mode                    |
|----------------------------|-----------------|---------------------|---------------------------------|
| Hourly Task Updates        | `channel_updates`| Every hour           | Inexact (exact if permitted)    |
| Pending Task Reminder      | `channel_reminders` | Every 5 minutes   | Exact if permitted, otherwise inexact |

---

## 5. Flutter Packages
- `flutter_local_notifications`
- `timezone`
- `rxdart`
- `http`
- `android_intent_plus`

---

## 6. Screens
1. Home Screen: Task list & last updated timestamp
2. Task Details Screen: Title, description, status, mark complete
3. Settings Screen: Toggle notifications, configure interval

---

## 7. Future Enhancements
- Push notifications via FCM
- Daily summary notifications
- Multi-user support / authentication