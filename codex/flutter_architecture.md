# 🛠️ Hermes Flutter Architecture

This document defines the engineering standards, folder configurations, performance budgets, and coding principles for implementation.

---

## 🏛️ Engineering Philosophy (Chapter 1 & 14)

*   **Architecture Before Features:** We never write features before establishing their architectural boundaries.
*   **Readability Over Cleverness:** Write code that is easily understandable six months later.
*   **Performance is Correctness:** If an implementation is slow or drops frames, it is incorrect.
*   **Codex Supremacy:** The Codex is the ultimate source of truth. If code conflicts with the Codex, the Codex wins.

---

## 📂 Folder Structure (Chapter 2 & 3)

We use a **feature-first** organization protocol rather than screen-first or layer-first directories.

```text
lib/
├── core/                  # Global components and shared engines
│   ├── theme/             # Design token properties
│   └── engines/           # Core engines (Reader, Search, Archive)
├── features/              # Feature modules
│   └── today/             # E.g. Today feature block
│       ├── data/          # Databases & local caching sources
│       ├── domain/        # Business logic entities & models
│       ├── presentation/  # UI Screen and custom widgets
│       └── widgets/       # Feature-specific components
└── shared/                # Global widgets shared across multiple features
```

---

## ⚖️ State & Data Flow (Chapter 4, 5, 12)

### 1. State Management Rules
*   **Predictable Changes:** State must flow unidirectionally.
*   **No UI Logic Bloat:** Business logic never belongs inside UI widgets.
*   **Reactiveness:** UI elements must be simple, stateless observers of state changes.
*   **Isolation:** Avoid global mutable states.

### 2. Database & Data Flow Rules
*   **Dependency Direction:**
    $$\text{UI Widgets} \rightarrow \text{Feature logic} \rightarrow \text{Engines} \rightarrow \text{Data Store} \rightarrow \text{Storage}$$
    *   *Rule:* The database must never know about the UI. Widgets never talk directly to storage.
*   **Autosave:** Saves are executed implicitly without blocking the UI thread.
*   **Offline First:** Lazy load resources locally.

---

## ⏱️ Performance Budget (Chapter 6)

These numbers are strict engineering constraints, not target suggestions:

| Action | Budget |
| :--- | :--- |
| **Cold Startup Time** | $< 1.0\text{ second}$ |
| **Workspace Context Switch** | $< 100\text{ ms}$ |
| **Search Queries** | Instantaneous |
| **Typing Input Lag** | $0\text{ ms}$ (No visual delays) |
| **Rendering Refresh Rate** | $\ge 60\text{ FPS}$ (120 FPS where supported) |

---

## 🔌 Decoupling & Security (Chapter 7, 8, 9, 13)

*   **Loose Coupling:** Engines communicate strictly through defined interfaces. The Reader does not know how Search works; Search does not know how the Archive is structured.
*   **Error Safe-Handling:** Auto-retry failures in background tasks. Local features failing must never bring down unrelated modules.
*   **Privacy-first Logs:** Developer logs are verbose in dev, but minimal in production. PII, PINs, and personal reflection contents are strictly prohibited from being logged.
*   **Security Lockouts:** PINs and patterns are hashed (never stored in plain text). Private workspace files are cryptographically isolated.
