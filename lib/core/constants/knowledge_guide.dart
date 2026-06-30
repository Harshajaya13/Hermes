const String knowledgeGuideMarkdown = '''
# The Knowledge Pipeline

Hermes is not designed to be a daily to-do list where you manually type out tasks every morning. 

Instead, users build long-term **Knowledge Collections**. Hermes then gradually surfaces those collections into *Today's Pursuit*.

This guide explains how knowledge flows into your system.

---

## 1. Why Knowledge Sources Exist

Information on the internet is overwhelming. If you bookmark 100 articles, you will never read them. If you try to read them all in one day, you will not understand them.

Knowledge Sources exist to act as a buffer. You import raw knowledge into a Source, and Hermes drip-feeds it to you at a pace you can actually process.

## 2. Manual Collections

A **Manual Collection** is a localized source that you fully own. 

When you import knowledge, it is saved directly into your local database. It is not synced to a cloud, and it is not dependent on any external service. You physically own the data.

You can configure each collection to:
1. Be mapped to a specific **Domain** and **Block** (e.g., *Computer Science > Python*).
2. Flow into **Today's Pursuit**.
3. Have a **Daily Limit** (e.g., maximum 2 articles per day).

## 3. Importing Articles

If you have a reading list, you can import it as a JSON array.

```json
[
  {
    "title": "The Architecture of SQLite",
    "content": "SQLite is a C-language library that implements a small, fast, self-contained, high-reliability, full-featured, SQL database engine...",
    "sourceUrl": "https://sqlite.org/arch.html"
  }
]
```

By collecting articles over months and importing them here, reading becomes an intentional daily practice rather than an overwhelming backlog. Hermes will slowly surface these articles into Today's Pursuit.

## 4. Importing Questions

Questions are powerful. They create a void in your mind that demands to be filled.

You can use AI tools (like ChatGPT or Claude) to generate hundreds of deep, conceptual questions about a topic you want to learn, and import them directly:

```json
[
  {
    "title": "What is the primary difference between a process and a thread?",
    "content": "Think deeply about memory spaces and context switching overhead before answering."
  },
  {
    "title": "Why does a hash table have O(1) average lookup time?",
    "content": "Consider the role of the hash function and potential collisions."
  }
]
```

When you import this file, Hermes validates the format and saves it. Now, every day, your *Today's Pursuit* will automatically contain a few profound questions for you to solve.

## 5. Daily Scheduling Limits

Hermes intentionally restricts how much knowledge you see at once. 

When creating a Knowledge Source, you set a **Daily Limit**. 
For example, if you set a limit of `3` for your *Algorithms Questions* source, Hermes will only pull 3 unanswered questions from that source into Today's Pursuit each day. 

This creates sustainable, deliberate growth.

---

### Philosophy

Knowledge should not arrive by accident. It should enter Hermes because the user intentionally invited it.

Hermes provides the pipeline. You choose what flows through it.
''';
