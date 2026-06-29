# 🗄️ The Hermes Knowledge Model

The Knowledge Model defines how every object inside Hermes is stored, connected, backed up, restored, and moved between devices. Its primary responsibility is preserving the user's journey, not just raw application state.

---

## 🏛️ Core Principles

*   **Offline First:** The application functions fully without any network resources.
*   **User Ownership:** Every part of the journey is owned by the user. It can be moved, backed up, and restored without relying on online services.
*   **Portability:** Standardized exchange files ensure workspaces are portable across different platforms.
*   **Reversibility:** Safe archiving and cascade restores prevent accidental deletion.
*   **Privacy by Choice:** Local secure lockers and optional zkp/encryption.
*   **Future Compatibility:** Standard schema versions prevent breakages on major client updates.

---

## 🔗 Object Relationships

```text
Workspace [1]
   └── Domains [Many]
          └── Blocks [Many]
                 └── Items [Many]
                        ├── Reflections [Many] (Created from Items)
                        └── Evolutios [Many] (Generated from reflections)
```

*Note: **Evolution** is not stored as a database record. It is calculated dynamically in real-time as the sum of all recorded **Evolutios** over time.*

---

## 🏷️ Unique Identification & Common Metadata

Every database entity uses a permanent, unique identifier (UUID/string):
*   `workspace_id`, `domain_id`, `block_id`, `item_id`, `reflection_id`, `evolutio_id`, `veritas_id`.

Every object stores these common metadata parameters:
```json
{
  "id": "uuid-string",
  "created_at": "ISO-8601 Timestamp",
  "modified_at": "ISO-8601 Timestamp",
  "archived": false,
  "deleted": false,
  "version": 1
}
```

---

## 🏛️ Object Schema & Property Matrix

### 1. Workspace
The top-level execution boundary.
*   **Properties:** Name, Description, Icon, Visibility (Public/Private), Privacy Lock (PIN/Pattern/Optional Encryption), Theme Override.
*   **Capabilities:** Rename, Export, Import, Backup, Restore, Lock, Hide, Archive.

### 2. Domain
Represents an intentional area of long-term development (e.g., *Engineering*, *Thinking*).
*   **Properties:** Name, Icon, Color.
*   **Capabilities:** Rename, Reorder, Color, Icon, Archive, Delete.

### 3. Block
An environment dedicated to a single growth topic (e.g., *Mathematics*, *Psychology*).
*   **Properties:** Name, Icon, Color, Pinned status, Favorite status.
*   **Capabilities:** Rename, Reorder, Color, Icon, Pin, Favorite, Duplicate, Export, Import, Delete.

### 4. Item
An individual point of focus.
*   **Supported Types:** `question`, `article`, `reflection_note`, `quote`, `observation`, `idea`.
*   **Excluded Media:** To keep the database fast, items do **not** embed heavy formats like PDFs or video streams directly; these remain external links.
*   **Capabilities:** Read, Edit, Move (re-parent), Duplicate, Archive, Search, Share, Delete.

### 5. Reflection
Captures the user's active thinking.
*   **Properties:** Linked Item ID, Linked Evolutio ID, Content body.
*   **Rules:** Required for growth, multiple reflections allowed per item, editable, timestamp preserved.

### 6. Evolutio
A recorded moment of meaningful growth.
*   **Rules:** Built entirely on user choice, never linked to streaks or gamified progress scores. An Evolutio is a monument of shift, not an activity count.

### 7. Veritas
A standalone truth-logger.
*   **Rules:** Appears on empty calendar days. Completely optional, never judged, and searchable only when explicitly enabled in privacy settings.

---

## 🗃️ Self-Healing Archive Engine

Deleting a parent container (e.g., a Workspace) moves all its child entities (Domains, Blocks, Items, Reflections, Evolutios) into the **Archive** in a cascade.
*   **Restoring:** Restoring a parent entity restores its entire child hierarchy cleanly.
*   **Permanent Deletion:** Items can only be permanently erased from inside the Archive interface.
*   **Dangling Keys:** If an Item or Block is restored but its original parent was permanently deleted, the Archive engine self-heals by routing the orphaned child to the default **Felix Domain** or **Felix Block** fallback areas.

---

## 📦 FOSS Portability Standard (`.hermes`)

Instead of raw, unreadable database tables, workspaces are exported as `.hermes` files.

### The `.hermes` File Structure
Under the hood, a `.hermes` package is a standard ZIP archive:

```text
Development.hermes/
├── manifest.json       # Schema version, authors, descriptions, checksums
├── database.json       # All domains, blocks, items, and reflections in JSON
├── icon.png            # Custom workspace icon
└── attachments/        # User-attached images or local assets
```

### Manifest Schema
```json
{
  "schema_version": 1,
  "hermes_version": "1.2.0",
  "created_at": "2026-06-28T12:00:00Z",
  "modified_at": "2026-06-29T08:00:00Z",
  "description": "Mathematics and Linear Algebra study tracks",
  "author": "Harsha",
  "checksum": "sha256-hash-value"
}
```
This manifest guarantees backwards compatibility, allowing future clients built years from now to parse old learning tracks without failure.
