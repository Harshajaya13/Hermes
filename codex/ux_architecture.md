# 🧭 Hermes UX Architecture

UX Architecture defines how interacting with Hermes feels from the first tap to the last. It acts as the bridge between information structures and raw design system visuals.

---

## 🏛️ Core UX Principles

These principles are non-negotiable and guide all interface behaviors:

1.  **One Purpose per Screen:** Do not clutter screens with secondary tasks.
2.  **Zero Urgency:** Eliminate red dots, streaks, alerts, and notifications. Hermes should feel calm.
3.  **Frictionless Ingestion:** Every interaction is optimized to reduce unnecessary taps.
4.  **Reversible Workflows:** Actions (archive, move, edit) must feel reversible.
5.  **Invisible Saving:** Content is autosaved invisibly as you type. No spinners, no loading, no save buttons.
6.  **Educative Empty States:** Empty lists should invite curiosity and explain philosophy, never look like "No Content".
7.  **The Silence Principle:** Hermes never competes for attention; it protects it.

---

## 🎛️ Navigation & Interaction Layouts

*   **Tabs:** Simple bottom tabs to clearly state where the user is.
*   **Raycast-style Search:** A single query input that aggregates across all types of entries.
*   **Guide Bot vs. Hermes Companion:** No active AI chatbots. In Settings, the **Hermes Guide** provides simple, structural explanations of Blocks, Evolutios, and Veritas.

---

## 🏡 Screen Behavior & Targets

| Screen | Purpose | What it NEVER becomes |
| :--- | :--- | :--- |
| **Today** | Guide today's growth and reflections. | A metrics dashboard. |
| **Blocks** | Directory grouping intentional learning areas. | A boring file explorer. |
| **Calendar** | Honest timeline tracking Evolutios/Veritas. | Google Calendar (event organizer). |
| **Search** | Instantly query knowledge objects. | A rigid tag/folder structure selector. |

---

## 🛡️ Sudo-Delete & The Archive Engine

Hermes treats your records as **mementos**, not disposable data. 

```text
[Delete Block] ➔ [Archive Vault (Safe)] ➔ [Delete Permanently] ➔ [Requires PIN (Sudo)]
```

*   **Moving to Archive:** Smooth, frictionless action without password challenges.
*   **The Archive Vault:** Denotes that deleted items "still matter" (unlike Trash/Bin).
*   **Permanent Deletion:** Triggering permanent removal requires entering the Workspace PIN/password (similar to Linux `sudo`). This acts as an intentional circuit breaker to protect years of personal evolution.

---

## 🌊 Motion & Delight

*   **Speed over Spectacle:** Animations must explain state changes, never act as decoration.
*   **Accessibility Controls:** Users can disable all transitions in Settings.
*   **Muted Haptics:** Tiny vibrations occur **only** during major milestones:
    *   Recording an Evolutio
    *   Successfully restoring an archived item
    *   Completing today's reflection
*   **Meaningful Copywriting:**
    *   Instead of *"Saved"* ➔ *"Your evolution continues."*
    *   Instead of *"Completed"* ➔ *"One step further."*

---

## 🧠 Emotional Matrix

Every object in Hermes corresponds to a non-guilt-inducing, positive emotional state:

| Object | Target Emotion |
| :--- | :--- |
| **Today** | Direction |
| **Block** | Focus |
| **Item** | Curiosity |
| **Reflection** | Understanding |
| **Evolutio** | Growth |
| **Evolution** | Progress |
| **Veritas** | Honesty |
| **Archive** | Safety |
| **Search** | Confidence |

> **The Trust Law:** *Every action in Hermes must leave the user with more trust than before the action began.*
