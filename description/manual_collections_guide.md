# Manual Collections Guide

## Welcome

Manual Collections are designed to become the primary way knowledge enters Hermes.

Unlike traditional note-taking applications, Hermes is not intended to be filled manually every morning.

Instead, you gradually build collections of knowledge that Hermes intelligently schedules into your daily workflow.

Think of Manual Collections as building your own personal curriculum.

You decide what enters.

Hermes decides when it appears.

---

## The Knowledge Pipeline

Every piece of imported knowledge follows the same journey.

Collection

↓

Import

↓

Validation

↓

Local Database

↓

Daily Scheduler

↓

Today's Pursuit

↓

Understanding

↓

Reflection

↓

Evolution

The goal is simple.

Collect once.

Learn gradually.

---

## Supported Collection Types

Hermes currently supports two primary collection types.

### Questions

Questions are ideal for active learning.

Examples include:

- Mathematics
- Probability
- Algorithms
- Operating Systems
- Machine Learning
- Interview Preparation

Questions encourage you to think before revealing the solution.

---

### Articles

Articles are designed for intentional reading.

Examples include:

- Research Papers
- Blog Posts
- Documentation
- Tutorials
- Essays

Instead of overwhelming yourself with hundreds of unread bookmarks, Hermes gradually introduces them according to your Daily Limit.

---

## Creating Collections

When creating a Manual Collection, you configure:

- Collection Name
- Domain
- Block
- Collection Type
- Daily Limit

Example:

Collection

Probability Questions

↓

Domain

Mathematics

↓

Block

Probability

↓

Daily Limit

2 Questions per Day

Once imported, Hermes automatically schedules questions according to these settings.

---

## Importing JSON

Hermes imports knowledge using structured JSON.

This allows hundreds or even thousands of items to be imported in seconds.

A valid JSON file contains an array of supported items.

Example:

Questions

```json
[
  {
    "title": "Why does Binary Search require sorted data?",
    "answer": "Because..."
  }
]
```

Articles

```json
[
  {
    "title": "Understanding SQLite",
    "content": "...",
    "sourceUrl": "https://..."
  }
]
```

Hermes validates every file before importing.

If the format is invalid, the import is rejected instead of corrupting your knowledge base.

---

## Using AI

One of the easiest ways to build a collection is with AI.

For example:

"Generate 300 conceptual Probability questions in Hermes JSON format."

or

"Generate 200 Operating System interview questions."

or

"Convert these research papers into Hermes Article JSON."

Once generated, simply import the file into your chosen collection.

Hermes handles the scheduling automatically.

---

## Daily Limits

Daily Limits are one of the most important concepts inside Hermes.

Without limits:

1000 Questions

↓

Overwhelming

With limits:

2 Questions Today

↓

2 Tomorrow

↓

2 Next Week

↓

Continuous Progress

Learning should be sustainable.

Not exhausting.

---

## Why Manual Collections?

Most applications ask you to decide what to study every day.

Hermes removes that decision.

Instead, you prepare knowledge once.

After that, Hermes quietly guides you through your own curriculum.

The result is less planning and more learning.

---

## Best Practices

For the best experience:

• Keep Questions and Articles in separate collections.

• Organize collections by subject rather than difficulty.

• Use realistic Daily Limits.

• Continuously expand collections instead of replacing them.

• Review completed Questions and Articles periodically.

Small daily progress compounds into significant understanding over time.

---

## You're Ready

Once your collections are imported, Hermes begins working automatically.

Every morning, Today's Pursuit will present carefully selected knowledge from your own collections.

No feeds.

No recommendations.

No endless scrolling.

Only the knowledge you intentionally chose to learn.

That is the philosophy behind Manual Collections.