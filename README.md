# Autonomous SE Agent — Phase 1: Project Setup and Foundations

This is Phase 1 of building an autonomous AI Software Engineering Agent capable of repository analysis, code-aware RAG, patch generation, and Docker sandbox test execution.

---

## 1. Project Directory Structure

```
.
├── .env.example              # Environment variables template
├── .gitignore                # Git untracked files pattern
├── pyproject.toml            # Dependencies and lint/test configurations
├── Dockerfile                # Multi-stage production-ready container definition
├── docker-compose.yml        # Orchestration layer for backend and databases
├── README.md                 # Project guide
├── src/                      # Source code root
│   ├── __init__.py           # Package marker
│   ├── config.py             # Type-safe configuration management
│   └── main.py               # FastAPI application entrypoint
└── tests/                    # Testing suite root
    ├── __init__.py           # Package marker
    ├── conftest.py           # Pytest fixtures and mock async clients
    └── unit/                 # Unit tests
        ├── __init__.py       # Package marker
        ├── test_config.py    # Config validation test cases
        └── test_main.py      # Health endpoint test cases
```

---

## 2. Technical Decisions & Architectural Choices

### Config Management via Pydantic Settings
- **Why?** It ensures type-safety. If an environment variable is supposed to be an integer (e.g. `PORT`), Pydantic will cast it automatically or throw a clear validation error at startup.
- **Benefits**: Prevention of silent failures due to type mismatches.
- **Local Fallback**: The default database configuration uses SQLite with the `aiosqlite` driver (`sqlite+aiosqlite:///./agent.db`) to enable friction-free local execution without requiring database setup. When running in Docker Compose, it is overridden by PostgreSQL.

### Multi-stage Docker Builds
- **Why?** Production images should be as small and secure as possible.
- **How it works**: 
  1. **Builder Stage**: Installs development utilities, compilers, and packages.
  2. **Runner Stage**: Copies only the pre-compiled packages (`site-packages`) and binary files. This keeps git and core libraries active without shipping heavy compile-time tools (like GCC) in the final runtime container.

---

## 3. How to Run Locally

### Prerequisites
- Python 3.12+ installed
- Docker installed (required for running databases and the sandboxed execution environment)

### Setup Instructions

1. **Clone and Navigate to Directory**
   ```powershell
   cd c:\Users\ASUS\OneDrive\Documents\engineering
   ```

2. **Set up Virtual Environment**
   ```powershell
   python -m venv .venv
   .venv\Scripts\activate
   ```

3. **Install Dependencies**
   Install the project and development dependencies in editable mode:
   ```powershell
   pip install -e .[dev]
   ```

4. **Prepare Environment File**
   ```powershell
   copy .env.example .env
   ```

5. **Run Linting & Formatting Checks**
   Ensure formatting and typing standards are clean:
   ```powershell
   ruff check src tests
   mypy src tests
   ```

6. **Run Pytest Suite**
   Ensure tests pass out-of-the-box:
   ```powershell
   pytest
   ```

7. **Start FastAPI Application Locally**
   ```powershell
   python src/main.py
   ```
   The API will be available at `http://localhost:8000`. You can test the health endpoint:
   - Request: `GET http://localhost:8000/health`
   - Response: `{"status":"healthy","environment":"development","version":"0.1.0"}`

---

## 4. How to Run in Docker

To spin up the entire ecosystem (FastAPI Backend, PostgreSQL Database, Redis Cache, Qdrant Vector DB) with a single command:

1. **Build and Run Docker Compose**
   ```powershell
   docker compose up --build
   ```

2. **Access the Health Check and Swagger API Docs**
   - Health Endpoint: `http://localhost:8000/health`
   - Interactive Docs (Swagger UI): `http://localhost:8000/docs`
   - Alternative Docs (ReDoc): `http://localhost:8000/redoc`

To shut down and remove the volumes:
```powershell
docker compose down -v
```
