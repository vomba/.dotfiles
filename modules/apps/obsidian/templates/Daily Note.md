---
created: "<% tp.date.now("YYYY-MM-DD HH:mm") %>"
tags:
  - daily
aliases:
  - "<% tp.date.now("YYYY-MM-DD") %> Daily Note"
---

# <% tp.date.now("YYYY-MM-DD") %> — Daily Note

## Tasks

### Overdue
```tasks
not done
due before <% tp.date.now("YYYY-MM-DD") %>
```

### Due Today
```tasks
not done
due on <% tp.date.now("YYYY-MM-DD") %>
```

### Rich Tasks (Task-as-a-Note)
```dataview
LIST FROM #task
WHERE due = date(<% tp.date.now("YYYY-MM-DD") %>)
OR (status = "active" AND !due)
```

## Today's Tasks
<%*
// Rollover unfinished tasks from yesterday
const yesterday = tp.date.now("YYYY-MM-DD", -1);
const previousNote = tp.file.find_tfile(yesterday);

if (previousNote) {
    const content = await app.vault.read(previousNote);
    const unfinishedTasks = content.split("\n")
        .filter(line => line.trim().startsWith("- [ ]") && !line.includes("#task"))
        .join("\n");

    if (unfinishedTasks) {
        tR += unfinishedTasks + "\n";
    }
}
%>
<!-- Add simple tasks via QuickAdd or manually below -->

## Notes
-

## Semantic Discoveries (On this day...)
```dataview
LIST FROM ""
WHERE file.day.month = date(<% tp.date.now("YYYY-MM-DD") %>).month
AND file.day.day = date(<% tp.date.now("YYYY-MM-DD") %>).day
AND file.name != this.file.name
```

## Activity Summary (Auto-Generated)
<%*
const summary = await tp.system.execute("~/.dotfiles/scripts/git-daily-summary.sh");
tR += summary;
%>

## End of Day Review
### What got done?
```tasks
done on <% tp.date.now("YYYY-MM-DD") %>
```

### What didn't get done?
```tasks
not done
due on <% tp.date.now("YYYY-MM-DD") %>
```

### Notes for tomorrow
-

## Dataview: Recently Modified Notes
```dataview
TABLE file.mtime AS "Modified"
FROM ""
WHERE file.mtime >= date(<% tp.date.now("YYYY-MM-DD") %>)
SORT file.mtime DESC
LIMIT 10
```
