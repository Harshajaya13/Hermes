# 🌌 Hermes OS

> **A Personal Development Operating System.** Distraction-free, offline-first, portable, and built to capture your long-term personal evolution.

---

[![License: MIT](https://img.shields.io/badge/License-MIT-black.svg?style=flat-square)](https://opensource.org/licenses/MIT)
[![Flutter](https://img.shields.io/badge/Flutter-3.44+-02569B.svg?style=flat-square&logo=flutter)](https://flutter.dev)
[![Platform: Linux & Android](https://img.shields.io/badge/Platform-Linux%20%7C%20Android-black.svg?style=flat-square)](#)

Hermes is not a task manager, a habit tracker, or a gamified productivity app. It is a premium **Personal Development Operating System** designed strictly around the **Hermes Codex** philosophy. Hermes exists to catalog your intellectual and emotional growth, completely offline, with zero subscription gates, zero notifications, and absolute data portability.

---

## 👁️ The Codex Philosophy

Hermes operates on a set of core laws defined in the original Codex specifications:

*   **Mindfulness over Gamification:** You will find no streaks, arbitrary level-ups, points, or leaderboards here. Hermes tracks progress through **Evolutios**—meaningful, self-reflected milestones—and **Veritas**—private, daily check-ins that are completely unjudged by the system.
*   **Offline-First & Local-First:** Your data never leaves your device unless you choose to export it. There are no cloud servers, no user accounts, and no sync locks. 
*   **Zero Noise, Maximum Focus:** High-fidelity, distraction-free OLED dark theme. Designed to let you sit, think, read, and write in silence.
*   **FOSS Portability:** Every workspace can be packed into a community-shareable format so you can pass entire knowledge bases, lore systems, or learning tracks to anyone in the world.

---

## 🏛️ Information Architecture

Hermes organizes your life into a strict, self-healing hierarchical cascade:

```mermaid
graph TD
    Workspace[1. Workspace] --> Domains[2. Domains]
    Domains --> Blocks[3. Blocks]
    Blocks --> Items[4. Items]
    Items --> Reflections[5. Reflections]
    Reflections --> Evolutios[6. Evolutios]
```

1.  **Workspace:** The top-level container to isolate entirely different "lores" of your life (e.g., *Startup Lore*, *College Lore*, *Stoicism*).
2.  **Domain:** Represents one intentional area of long-term growth (e.g., *Computer Science*, *Physical Health*).
3.  **Block:** Dedicated interactive environments containing specific subsets of knowledge or action.
4.  **Item:** Individual points of focus. Can be **Questions** to trigger reflection, or **Articles** to read.
5.  **Reflection:** Your active thoughts, observations, or answers associated with an Item.
6.  **Evolutio:** Self-driven evidence of meaningful cognitive shifts or milestones.

---

## ⚡ Key Features

### 1. Self-Healing Archive Engine ("Felix" Fallbacks)
Like a true Unix filesystem, deleting a parent object (like a Domain or Block) does not permanently destroy its child elements; it safely moves them to the **Archive**. 

If you restore an orphaned Item or Block whose parent has been permanently deleted, the storage engine self-heals by redirecting them into the **Felix Domain** and **Felix Block** fallback zones, preventing data loss or database crashes.

### 2. Distraction-Free Article Fetcher & Reader
Hermes features a built-in clean scraping pipeline. Paste any web URL (such as a Medium post, blog, or Wikipedia article), and Hermes:
*   Strips away all ads, tracking scripts, cookie prompts, and navigation menus.
*   Extracts the raw article HTML and uses `html2md` to convert it into structured Markdown.
*   Renders it locally in a beautiful, customizable OLED black reader using native Markdown styling.

### 3. FOSS Community Ecosystem (`.hermes` File Format)
Your entire workspace is packaged as a proprietary `.hermes` file. 
*   **Under the hood:** A `.hermes` file is a ZIP container containing a manifest (`metadata.json`), your raw SQLite/JSON database (`database.json`), and local attachments/images.
*   **Export/Import:** Easily package a learning track (e.g., `Stoicism.hermes`) and share it. Anyone can import it directly into their Hermes instance.

---

## 🛠️ Technical Stack

*   **Framework:** [Flutter](https://flutter.dev) (built for Linux Desktop and Android Mobile)
*   **State Management:** [Riverpod](https://riverpod.dev)
*   **Storage Engine:** Offline-first JSON Local Storage Engine
*   **HTML Parsing & Markdown:** [html2md](https://pub.dev/packages/html2md) & [flutter_markdown](https://pub.dev/packages/flutter_markdown)
*   **Archive Engine:** [archive](https://pub.dev/packages/archive) zip utility

---

## 🚀 Getting Started

### Prerequisites

You need **Flutter** and **Java 17** installed on your system.

```bash
# Verify your installations
java -version
flutter doctor
```

### Manual Android SDK Setup (No Android Studio required)

If you prefer a clean Linux environment without Snaps or the heavy Android Studio IDE:

1.  **Download Command Line Tools:**
    Get the Linux cmdline tools from Google:
    ```bash
    wget https://dl.google.com/android/repository/commandlinetools-linux-14742923_latest.zip -O ~/cmdline-tools.zip
    ```
2.  **Extract to the Sdk Directory:**
    ```bash
    mkdir -p ~/Android/Sdk/cmdline-tools
    unzip ~/cmdline-tools.zip -d ~/cmdline-tools-extracted
    mv ~/cmdline-tools-extracted/cmdline-tools ~/Android/Sdk/cmdline-tools/latest
    rm -rf ~/cmdline-tools.zip ~/cmdline-tools-extracted
    ```
3.  **Install SDK Components:**
    Using the local `sdkmanager`, download the required platform and compiler tools:
    ```bash
    # Android SDK 36 (Android 16) is target version for Flutter 3.44+
    ~/Android/Sdk/cmdline-tools/latest/bin/sdkmanager "platform-tools" "platforms;android-36" "build-tools;28.0.3"
    ```
4.  **Link and Accept Licenses:**
    ```bash
    flutter config --android-sdk ~/Android/Sdk
    yes | flutter doctor --android-licenses
    ```

---

## 📦 Building the Application

### Run on Linux Desktop
```bash
flutter run -d linux
```

### Build Android Release APK
```bash
flutter build apk --release
```
The compiled APK will be generated at:
📁 `build/app/outputs/flutter-apk/app-release.apk`

---

## 📱 Installation via Obtainium

To keep Hermes updated directly on your Android phone without using Google Play Store:
1. Open **Obtainium** on your phone.
2. Click **Add App**.
3. Paste the link to your GitHub repository:
   `https://github.com/Harshajaya13/Hermes`
4. Tap **Add**. Obtainium will automatically pull your latest uploaded release APK!

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
