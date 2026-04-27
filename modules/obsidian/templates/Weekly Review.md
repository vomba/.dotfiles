---
created: "<% tp.file.creation_date() %>"
tags:
  - weekly
aliases:
  - "Week <% tp.date.now("ww", 0, tp.file.title, "YYYY-[W]ww") %> <% tp.date.now("YYYY", 0, tp.file.title, "YYYY-[W]ww") %> Review"
---

# Week <% tp.date.now("ww", 0, tp.file.title, "YYYY-[W]ww") %> <% tp.date.now("YYYY", 0, tp.file.title, "YYYY-[W]ww") %> — Weekly Review

## Review Period
**From:** <% tp.date.weekday("YYYY-MM-DD", 0, tp.file.title, "YYYY-[W]ww") %> **To:** <% tp.date.weekday("YYYY-MM-DD", 6, tp.file.title, "YYYY-[W]ww") %>

## What Got Done This Week?
```dataview
TASK
FROM ""
WHERE !completed
AND file.mtime >= date(<% tp.date.weekday("YYYY-MM-DD", 0, tp.file.title, "YYYY-[W]ww") %>)
AND file.mtime <= date(<% tp.date.weekday("YYYY-MM-DD", 6, tp.file.title, "YYYY-[W]ww") %>)
GROUP BY file.link
```

## Completed Tasks
```tasks
done
done after <% tp.date.weekday("YYYY-MM-DD", 0, tp.file.title, "YYYY-[W]ww") %>
done before <% tp.date.weekday("YYYY-MM-DD", 6, tp.file.title, "YYYY-[W]ww") %>
```

## Incomplete Tasks (Carry Over)
```tasks
not done
due before <% tp.date.weekday("YYYY-MM-DD", 6, tp.file.title, "YYYY-[W]ww") %>
```

## Resources Saved This Week
```dataview
TABLE created AS "Created", tags AS "Tags"
FROM #resource
WHERE created >= date(<% tp.date.weekday("YYYY-MM-DD", 0, tp.file.title, "YYYY-[W]ww") %>)
SORT created DESC
```

## Snippets Added This Week
```dataview
TABLE created AS "Created", language AS "Language"
FROM #snippet
WHERE created >= date(<% tp.date.weekday("YYYY-MM-DD", 0, tp.file.title, "YYYY-[W]ww") %>)
SORT created DESC
```

## Reflections

### Wins
- 

### Challenges
- 

### Lessons Learned
- 

## Next Week's Focus
- [ ] 
- [ ] 
- [ ] 

## Orphaned Notes (No Tags)
```dataview
TABLE file.mtime AS "Modified"
FROM ""
WHERE length(file.tags) = 0
AND file.name != this.file.name
SORT file.mtime DESC
LIMIT 20
```
