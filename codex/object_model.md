# 🧩 The Hermes Object Model

This document defines the core entities (or "things") that compose Hermes. Rather than thinking in terms of screens or databases, Hermes operates on a strict model of interactive, independent objects.

---

## 🏛️ 1. Workspace
An isolated environment that encapsulates all data. Workspaces allow the user to separate completely different loras/realms of their life.

*   **Purpose:** Allows isolated organization of unrelated domains (e.g., *College Lore* vs. *Startup Lore* vs. *Personal Development*).
*   **Encapsulation:** Deleting a workspace moves all its child entities to the Archive.
*   **Privacy Locker:** Private workspaces can be hidden from the home screen, requiring a PIN or pattern to access, and optionally using client-side encryption.
*   **Portability:** Exportable and importable via the `.hermes` format.

---

## 🗺️ 2. Domain
A high-level area of intentional direction that groups related Blocks together.

*   **Purpose:** Keeps the top-level interface decluttered by clustering topics under conceptual umbrellas (e.g., *Engineering*, *Thinking*, *Business*, *Life*).
*   **Not a Folder:** A folder is merely passive storage; a Domain represents a conceptual focus direction.
*   **Relationships:** A Domain maps blocks together to help build cognitive connections.
*   **Customizability:** Users can create custom domains, reorder them, and assign colors/icons.

---

## 🌲 3. Block
An interactive environment dedicated to one specific growth topic.

*   **Purpose:** Houses all practice exercises, questions, and articles for a single topic (e.g., *Mathematics*, *Psychology*, *Python*).
*   **Not a File:** A file is passive text. A Block is active; it evaluates math inputs, renders LaTeX equations, records user reflections, and drives Evolutios.
*   **Flexibility:** A Block can mix different item types (e.g., a single Block can contain both *Expected Value Questions* and *Risk Management Articles*).
*   **Customizability:** Supports custom icons, naming, colors, and home-screen pinning.

---

## 📄 4. Item
The fundamental unit of knowledge inside Hermes.

*   **Supported Types:** `question`, `article`, `reflection_note`, `quote`, `observation`, `idea`.
*   **Excluded Media:** Heavy media like PDFs and video streams are kept out of the local DB; they remain external references.
*   **Capabilities:** Items can be read, edited, duplicated, archived, shared, and re-parented (moved between blocks).

---

## ✍️ 5. Reflection
The user's active processing of an Item.

*   **Purpose:** Represents the core mechanism of change. A user cannot grow without active reflection.
*   **Properties:** Multiple reflections are allowed per item. They are editable, time-stamped, and chronological.
*   **Connection:** A reflection belongs directly to an item.

---

## 🧠 6. Insight
A user-driven realization extracted from reflection history.

*   **Purpose:** Hermes never uses AI to automatically extract insights from user data (preserving absolute privacy). Instead, it displays reflection outlines and links them together, helping the user manually connect the dots and trace their cognitive patterns.

---

## 🌱 7. Evolutio
A recorded shift in the user's cognitive state or behavior.

*   **Not a Score:** An Evolutio is a record of understanding, not a game score.
*   **No Gamification:** There are no percentages or level bars (e.g. *78% Evolution*), which creates pressure to "grind" the system. 
*   **The Log:** Evolutios are tracked as written changes in understanding (e.g., *"Expected value finally clicked"*, *"Understood why consistency beats streaks"*). Users chase real understanding rather than statistical points.

---

## 👁️ 8. Evolution
A dynamic view representing the sum of your growth.

*   **Dynamic Generation:** Evolution is never stored as a database record. It is calculated dynamically at runtime by combining all recorded **Evolutios** across your history.

---

## 🕵️‍♂️ 9. Veritas (Truth Log)
An independent truth-documenting object.

*   **Purpose:** Logs the honest context behind missed days.
*   **Usage:** Triggered when the user taps an empty day on the activity calendar. 
*   **Privacy:** Veritas entries are excluded from search results by default, unless the user explicitly enables them in search preferences.

---

## 🗃️ 10. Archive
A filesystem-like archive vault.

*   **Purpose:** Safe caching area for deleted items.
*   **Cascading Archive:** Deleting a Workspace or Domain archives all of its child elements. Restoring the parent restores the entire hierarchy.
*   **Permanent Deletion:** E-erasing files can only be done manually from inside the Archive interface.
