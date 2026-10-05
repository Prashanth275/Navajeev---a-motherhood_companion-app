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

### AI Backend

The AI backend is maintained as a separate repository:

🔗 **[Navajeev AI Engine]([YOUR_AI_BACKEND_GITHUB_LINK](https://github.com/Prashanth275/AI-Engine-for-Navajeev-))**

**Technologies:**
- FastAPI
- Python
- Pinecone
- Ollama Cloud
- RAG

---

## 🏗️ Architecture

```bash
                         Navajeev
                            │
             ┌──────────────┴──────────────┐
             │                             │
        Flutter App                  AI Engine
             │                             │
     ┌───────┼────────┐             ┌──────┴──────┐
     │       │        │             │             │
   Firebase Firestore Auth      Pinecone     Ollama Cloud
     │                │             │             │
     │                │        RAG Retrieval   AI Generation
     │                │             │             │
     └────────────────┴─────────────┴─────────────┘
```
---

## 🛠️ Tech Stack

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

Make sure you have the following installed:

- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- [Android Studio](https://developer.android.com/studio) / Xcode for iOS
- [Firebase CLI](https://firebase.google.com/docs/cli)
- Android/iOS device or emulator, or a supported browser

## 🚀 Installation

### 1. Clone the Repository

```bash
git clone https://github.com/Prashanth275/Navajeev-a-motherhood_companion-app.git
cd Navajeev-a-motherhood_companion-app
```

### 2. Flutter Setup

Install Flutter dependencies:

```bash
flutter pub get
```

### 3. Firebase Configuration

Configure Firebase for your environment and ensure the required Firebase configuration files are available.

### 4. Run the Application

**Web:**

```bash
flutter run -d chrome
```

**Android:**

```bash
flutter run -d android
```

**Windows:**

```bash
flutter run -d windows
```
---

👨‍💻 Built With
Flutter • Firebase • Python • FastAPI • Pinecone • Ollama
