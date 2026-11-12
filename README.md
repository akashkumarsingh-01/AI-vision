# Vision AI – Advanced All-in-One AI Assistant

Vision AI is an intelligent, full-stack, multimodal AI assistant designed for software development, technical education, career guidance, multimodal analysis, and real-time knowledge.

---

## 🌟 Key Features

### 1. Home Dashboard
- **Personalized Experience:** Displays user greeting, current time-based context, and live AI engine status.
- **Quick-Access Feature Cards:** 1-click launchpad for AI Chat, Multimodal Perception, Courses, Quizzes, Learning Hub, and History.
- **Global Search:** Search technical topics, courses, documentation, and saved discussions.
- **Trending AI Inquiries:** Pre-configured prompt chips for instant exploration.

### 2. Real-Time Multimodal AI Chat
- **Google Gemini API Integration:** Multi-turn conversational context with temperature control, streaming, and error handling.
- **Multimodal Uploads:**
  - 📷 **Image Analysis:** High-resolution image understanding, OCR, layout extraction, and diagram problem solving.
  - 📄 **Document & PDF Analysis:** Ingests PDFs, Markdown, and text files to extract key findings and executive summaries.
  - 🎥 **Video Analysis:** Timestamped breakdown, core narrative detection, and key scene insights.
- **Voice Input (Speech-to-Text):** Native microphone speech recognition via Web Speech API.
- **Text-to-Speech (TTS):** Audio narration with play/stop toggle.
- **Markdown & Code Studio:** Full syntax highlighting, language badges, and 1-click clipboard copy.
- **Conversation Controls:** New Chat, Clear History, and Regenerate Response.

### 3. Courses & Technical Curriculum
- **7 Comprehensive Roadmaps:**
  - 📱 **Flutter & Dart:** Cross-Platform Mastery
  - 🐍 **Python for AI:** Data Science & Gemini Generative AI
  - ⚛️ **Modern React 19:** State Management & Full-Stack Systems
  - 🟨 **JavaScript:** Zero to ESNext Hero
  - ☕ **Java 21:** Enterprise Architecture & Concurrency
  - 🌐 **HTML5 & CSS3:** Modern Flexbox, Grid, and Animations
- **Interactive Syllabus:** Module breakdowns, checklist lesson tracking, real-time progress percentages, and built-in "Ask AI Mentor" on every lesson.

### 4. AI Quiz Master
- **Dynamic Quiz Generator:** Instant question creation for any programming language or topic.
- **Multiple-Choice Engine:** Randomized answer options, instant evaluation, and score calculation.
- **Pedagogical Explanations:** Deep explanations for both correct and incorrect choices.
- **Performance Analytics:** Historical score logs, pass/fail badges, and difficulty tracking.

### 5. Learning Hub & AI Mentor
- **ELI5 Concept Explanations:** Tailored learning levels (*Beginner/10yo*, *Intermediate Architecture*, *Advanced Internal Mechanics*).
- **Study Notes Generator:** High-yield reference sheets, cheat sheets, and interview prep guides.
- **Code Assistant:** Paste any snippet to detect race conditions, bugs, or generate refactored code.

### 6. Profile & User Preferences
- **Learning Statistics:** Completed conversations, quizzes taken, average score, and finished lessons.
- **Customizable Goals:** Track active learning milestones.
- **Theme Modes:** Seamless toggle between sleek dark mode (`#0A0E1A`) and crisp light mode (`#F8FAFC`).

---

## 🛠️ Technology Stack

| Layer | Technologies |
|---|---|
| **Frontend (Flutter)** | Flutter 3.47, Dart 3.13, Provider, Material 3, Flutter Markdown, File Picker |
| **Frontend (Web Portal)** | HTML5, Tailwind CSS, FontAwesome 6, Marked.js, Highlight.js, Web Speech API, SpeechSynthesis |
| **Backend** | Node.js (v24), Express.js (v5), Multer, Helmet, CORS, Express-Rate-Limit |
| **AI Engine** | Google Gemini API (`@google/generative-ai`), Multimodal Vision & Document Engine |
| **Database** | Persistent JSON store (`backend/data/db.json`) with MongoDB adapter support |
| **Security** | BCrypt password hashing, JWT authentication, backend API key isolation |

---

## 🚀 Quick Start Instructions

### Prerequisites
- **Node.js** (v18 or higher)
- *(Optional for Flutter native development)* **Flutter SDK** (v3.20+)

### Method 1: Instant Web Portal (Recommended)
1. Double-click `run.bat` or run:
   ```powershell
   cd backend
   npm install
   npm start
   ```
2. Open your browser at **[http://localhost:5000](http://localhost:5000)**.
3. Everything is fully functional immediately!

### Method 2: Flutter Web / Desktop Client
1. To run the Flutter development server:
   ```powershell
   cd frontend
   flutter run -d chrome
   ```
2. Or open the pre-compiled Flutter Web build served directly by the backend at:
   **[http://localhost:5000/flutter](http://localhost:5000/flutter)**.

---

## 🔑 Gemini API Key Configuration

Vision AI operates in **Local Intelligent Mode** out-of-the-box so you can test all features without an external key. To connect directly to Google's cloud Gemini quota:

1. **Option A (In-App Settings):** Open the **Settings** view in the application, paste your API key (`AIzaSy...`), and click **Verify & Save**.
2. **Option B (.env File):** Edit `backend/.env`:
   ```env
   GEMINI_API_KEY=your_actual_gemini_api_key_here
   GEMINI_MODEL=gemini-1.5-flash
   ```

---

## 📡 REST API Endpoints

- `POST /api/chat` – Multi-turn conversational chat with history
- `GET /api/chat/conversations` – List recent discussions
- `POST /api/multimodal/image` – Upload and analyze image files
- `POST /api/multimodal/document` – Upload and analyze PDF/text documents
- `POST /api/multimodal/video` – Upload and analyze video files
- `POST /api/learn/explain` – Educational topic breakdown
- `POST /api/learn/notes` – Generate study notes and cheat sheets
- `POST /api/learn/code-assist` – Code refactoring and bug inspection
- `GET /api/courses` – List courses and user syllabus progress
- `POST /api/courses/:id/progress` – Toggle lesson completion state
- `POST /api/quiz/generate` – Dynamic AI quiz creation
- `POST /api/quiz/evaluate` – Score evaluation with explanations
- `GET /api/quiz/history` – Past quiz performance analytics
- `GET /api/config/status` – Server health & Gemini API key status
- `POST /api/config/update-key` – Runtime Gemini API key update

