# Hermes System Architecture

## The Felix Fallback (Self-Healing Archive Engine)

Like a true Unix filesystem, deleting a parent object (like a Domain or Block) does not permanently destroy its child elements; it safely moves them to the **Archive**. 

If you restore an orphaned Item or Block whose parent has been permanently deleted, the storage engine self-heals by redirecting them into the **Felix Domain** and **Felix Block** fallback zones. This strict handling prevents data loss and ensures the database never crashes due to dangling foreign keys.

## Distraction-Free Article Pipeline

Hermes features a built-in clean scraping pipeline. Paste any web URL, and Hermes:
1. Strips away all ads, tracking scripts, cookie prompts, and navigation menus.
2. Extracts the raw article HTML.
3. Uses `html2md` to convert it into structured Markdown.
4. Renders it locally in a customizable OLED black reader using native Markdown styling.

## FOSS Community Ecosystem (`.hermes`)

Your entire workspace is packaged as a proprietary `.hermes` file. 
* **Under the hood:** A `.hermes` file is a ZIP container containing a manifest (`metadata.json`), your raw SQLite/JSON database (`database.json`), and local attachments/images.
* **Portability:** This guarantees the user truly owns their data forever and can seamlessly transfer learning tracks across the community.
