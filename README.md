# 📝 NoteLuoto Backend — AI-Powered Note-Taking Platform (userver + C++)

This is the **backend** for **NoteLuoto**, an open-source, AI-integrated web application for working with interactive notes. Built in C++ using the high-performance [userver framework](https://userver.tech), the backend provides REST API and gRPC endpoints for managing notes, tags, attachments, checklists, and integrating with LLM-based services.

---

## 🚀 Key Features

- ✍️ Create, edit, search, and delete markdown-style notes
- ✅ Checklist support with interactive to-do items
- 📎 Upload and retrieve file attachments (up to 500MB)
- 🏷️ Tag system with filtering, creation, and AI-powered suggestions
- 🔍 Semantic and exact search with strategy pattern
- 🤖 AI Integration (LangChain + gRPC)
  - Semantic search, query suggestions, tag recommendations
  - Ask AI questions and save responses as notes
- 📜 History of AI queries
- 🔐 JWT-based authentication and authorization
- 🌍 Fully documented via **Swagger**
- 🐳 Dockerized deployment with PostgreSQL
- 📦 In-memory and PostgreSQL storage support
- ✅ Unit tests + functional tests with **userver::utest** and **pytest**

---

## 🧱 Architecture Overview

The backend follows a modular architecture with a focus on separation of concerns:

- **Handlers**: REST endpoints (e.g., `note::post::Handler`, `checklist::item::patch::Handler`)
- **DTOs**: Data parsing & validation (e.g., `NoteRequest`, `ChecklistRequest`, `SearchParams`)
- **Models**: Represent domain objects (e.g., `NoteWithId`, `Tag`, `User`, `Attachment`)
- **Services**:
  - `SearchService` implements the Strategy pattern for finding notes
  - `FileManager`, `JWTManager`, `DataToTextFormatter` handle utility logic
- **gRPC Clients**:
  - `LangchainClient`, `TagRecommenderClient`, `NoteSyncClient`
- **Middleware**:
  - `AuthChecker` (JWT auth), `CORSMiddleware`
- **Database**:
  - PostgreSQL with schema, triggers, cascading deletes, full-text search, and indexes

---

## 📡 API Overview

| Area            | Example Endpoints |
|-----------------|-------------------|
| Auth            | `POST /auth/register`, `POST /auth/login` |
| Notes           | `POST /notes`, `GET /notes`, `PATCH /notes/{id}` |
| Checklists      | `POST /checklist/{note_id}`, `PATCH /checklist/{id}` |
| Checklist Items | `POST /checklist/{id}/item`, `PATCH /checklist/item/{id}` |
| Tags            | `POST /tags/create`, `GET /tags/all` |
| Attachments     | `POST /attachment/{note_id}`, `GET /attachment/{id}` |
| History         | `GET /history` |
| AI Integration  | `POST /ai/answer`, `POST /suggest/tags/{note_id}` |

> 📖 Full OpenAPI specification for all REST endpoints — including authentication, notes, tags, attachments, checklists, AI features, and more — is included in the file api-1.0.6.yaml located in the root of the repository.

---

## 🧪 Testing

- ✅ **Functional tests** (REST API) via `pytest`
- ✅ **Unit tests** for key logic using `userver::utest`
- ✅ **gRPC mock servers** used in tests to simulate AI responses

---

## 🐳 Deployment

- Uses **Docker Compose** for setup
- Prebuilt image: `ghcr.io/userver-framework/ubuntu-22.04-userver-pg:v2.8`
- PostgreSQL setup and data volume mounting
- All configuration via YAML and environment variables


---


## 💡 Motivation

NoteLuoto is created for those who value **data privacy**, **local-first tools**, and **flexibility**. Unlike many commercial alternatives, it provides a powerful AI-enhanced note platform that can be fully self-hosted, adapted, and extended.


