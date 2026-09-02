# KARSU

> AI-powered learning and productivity platform with privacy, safety, and intelligent assistance.

KARSU is a modern AI-powered platform designed to help users learn, create, solve problems, and improve productivity through intelligent assistance. The project combines AI capabilities with privacy-first design, safety guardrails, secure authentication, and a clean user experience.

## ✨ Features

- 🤖 AI-powered intelligent assistance
- 🔐 Secure user authentication
- 🔑 Password hashing with scrypt
- 🎫 Server-side expiring authentication sessions
- 🚪 Secure logout with session revocation
- 🧠 Personalized AI assistance with user control
- 🛡️ Privacy controls for AI personalization
- 🔒 AI personalization disabled by default
- 📚 Learning and productivity support
- 👤 User onboarding and profile setup
- 🗄️ PostgreSQL database
- 🔄 Automatic database migrations
- 🐳 Docker-based PostgreSQL setup
- ❤️ Health-check endpoint
- 🌐 Configurable CORS
- 📱 Flutter mobile application
- ⚙️ Environment-based configuration

## 🏗️ Project Structure

```text
KARSU/
├── backend/                 # Node.js / TypeScript API
├── mobile/                  # Flutter mobile application
├── database/                # PostgreSQL schema and migrations
├── docs/                    # Setup and product documentation
├── docker-compose.yml       # Local PostgreSQL setup
├── .env.example             # Root environment template
├── qa_check.py              # Static QA checks
└── README.md
```

## 🧰 Technology Stack

### Mobile
- Flutter
- Dart
- SharedPreferences
- REST API integration

### Backend
- Node.js
- TypeScript
- NestJS
- PostgreSQL
- OpenAI API integration
- scrypt password hashing
- Server-side authentication sessions

### Infrastructure
- Docker
- Docker Compose
- PostgreSQL
- Environment-based configuration

## 🔐 Privacy & Security

Privacy is a core part of KARSU. AI personalization is **opt-in**. When personalization is disabled, KARSU does not load user business/profile context for AI personalization, does not send personalized context to the AI service, and does not store a personalized context snapshot for that interaction.

KARSU also uses secure password hashing, expiring server-side sessions, session revocation on logout, signed authentication payloads, database-backed user accounts, and environment-based secrets.

> Never commit `.env` files, API keys, passwords, database credentials, or other secrets to GitHub.

## 🗄️ Database

KARSU uses PostgreSQL. The backend includes an automatic migration system that bootstraps the schema when required, creates the migration tracking table, and applies pending numbered migrations at startup.

```text
database/
├── schema.sql
└── migrations/
    ├── 001_v03.sql
    └── 002_privacy_and_migration_hardening.sql
```

## 🚀 Getting Started

### 1. Clone the repository

```bash
git clone https://github.com/shiva-636/Karsu.git
cd Karsu
```

### 2. Configure environment variables

From the project root:

```bash
cp .env.example .env
```

Set a strong PostgreSQL password in `.env`:

```env
POSTGRES_DB=karsu
POSTGRES_USER=karsu
POSTGRES_PASSWORD=your-secure-password
POSTGRES_PORT=5432
```

Then configure the backend:

```bash
cd backend
cp .env.example .env
```

Add the required backend configuration, including the database connection and AI configuration if AI features are enabled.

### 3. Start PostgreSQL

From the project root:

```bash
docker compose up -d
```

### 4. Install backend dependencies

```bash
cd backend
npm install
```

### 5. Start the backend

```bash
npm run dev
```

The backend automatically initializes or migrates the database when required.

### 6. Run the mobile application

Make sure Flutter is installed and configured:

```bash
cd mobile
flutter pub get
flutter run
```

For additional configuration and deployment notes, see [`docs/SETUP.md`](docs/SETUP.md).

## 🧪 Quality Assurance

The repository includes static QA checks for important application, database, privacy, and security requirements:

```bash
python qa_check.py
```

Current static QA result:

```text
27/27 static checks passed
```

## 📦 Version

**KARSU v0.3.4**

## 🗺️ Roadmap

- [ ] Advanced AI capabilities
- [ ] Expanded learning tools
- [ ] Improved personalization controls
- [ ] Push notifications
- [ ] Offline support
- [ ] Expanded automated testing
- [ ] CI/CD pipeline
- [ ] Production deployment configuration
- [ ] Accessibility improvements
- [ ] Performance optimization

## 🤝 Contributing

Contributions are welcome. Create a feature branch, make your changes, run the available QA checks, and open a Pull Request.

## ⚠️ Disclaimer

KARSU is an educational and productivity platform. AI-generated responses may contain errors and should be independently verified when accuracy is important.

---

**KARSU — Learn. Create. Solve.**
