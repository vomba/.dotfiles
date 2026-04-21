---
created: "{{date}} {{time}}"
tags:
  - daily
aliases:
  - "{{date}} Daily Note"
---

# {{date}} — Daily Note

## Tasks

### Overdue
```tasks
not done
due before {{date}}
```

### Due Today
```tasks
not done
due on {{date}}
```

### Due This Week
```tasks
not done
due after {{date}}
due before {{date+7d}}
```

## Today's Tasks
<!-- Add tasks via QuickAdd or manually below -->

## Notes
- 

## Resources Captured
- 

## End of Day Review
### What got done?
- 

### What didn't get done?
- 

### Notes for tomorrow
- 

## Dataview: Recently Modified Notes
```dataview
TABLE file.mtime AS "Modified"
FROM ""
WHERE file.mtime >= date({{date}})
SORT file.mtime DESC
LIMIT 10
```
