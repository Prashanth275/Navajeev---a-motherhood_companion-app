# Navajeev — A Motherhood Companion App

**Navajeev** is a cross-platform Motherhood Companion designed to support women from **Day 1 of pregnancy through postpartum care and their child's early development up to 2 years of age**.

It brings pregnancy guidance, baby tracking, maternal wellbeing, appointments, and AI-powered assistance together in one application.

Available on **Web, Windows, and Android**.

---

## 🌟 Key Features

### 🤰 Pregnancy Journey
- Week-by-week **trimester and fetal development tracking**
- Baby size and length information
- Pregnancy symptoms and health guidance
- Due date and pregnancy progress
- Doctor appointment management

### 👶 Postpartum & Baby Care
- **WHO-based baby growth tracking** for weight, length, and head circumference
- 🍼 Feeding tracker
- 😴 Sleep tracker
- 💉 Vaccination tracker based on the **National Immunization Schedule (India)**
- ❤️ Maternal wellbeing and mood tracking

### 🤖 AI Motherhood Companion

Navajeev includes a **context-aware AI guidance engine** built using **Retrieval-Augmented Generation (RAG)**.

The chatbot considers relevant user context such as pregnancy/postpartum stage, trimester, and baby age instead of treating every question independently.

The AI engine includes:

- Context-aware personalization
- Knowledge retrieval with Pinecone
- Lexical reranking
- Ollama Cloud-based generation
- Response caching
- Context-isolated caching
- Streaming responses
- Graceful refusal when relevant information is unavailable

The knowledge base uses curated maternal and child-health information, including content based on materials associated with the **Ministry of Health & Family Welfare and the Rashtriya Bal Swasthya Karyakram (RBSK)**.

---

## 🏗️ Tech Stack

| Area | Technology |
|---|---|
| Frontend | Flutter / Dart |
| State Management | Provider |
| Authentication | Firebase Auth |
| Database | Cloud Firestore |
| Storage | Firebase Storage |
| AI Backend | Python / FastAPI |
| RAG | Pinecone |
| AI Generation | Ollama Cloud |
| Notifications | Flutter Local Notifications |
| Charts | fl_chart |
| Web Hosting | Firebase Hosting |

---

## 🔐 Authentication & Cloud

- Email & Password authentication
- Google Sign-In
- Persistent authentication sessions
- Cloud Firestore synchronization
- Firebase Storage
- Multi-device support

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK
- Android Studio / Xcode
- Firebase CLI
- Android/iOS device or emulator, or a browser

### Installation

```bash
git clone https://github.com/Prashanth275/Navajeev-a-motherhood_companion-app.git

cd Navajeev-a-motherhood_companion-app

flutter pub get

Configure your Firebase project and required Firebase configuration files, then run:
Web
flutter run -d chrome

Android
flutter run -d android

🧪 Testing
Run the test suite:
flutter test

Run static analysis:
flutter analyze

📦 Production Build
Android
flutter build apk --release

Web
flutter build web --release
firebase deploy --only hosting

🌐 Live Demo
https://navajeev-e3262.web.app/
👨‍💻 Built With
Flutter • Firebase • Python • FastAPI • Pinecone • Ollama
Built as a cross-platform application to bring pregnancy, motherhood, baby care, and AI-powered guidance into one connected experience.
