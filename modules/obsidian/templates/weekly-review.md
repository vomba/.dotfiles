---
created: "{{date}} {{time}}"
tags:
  - weekly
aliases:
  - "Week {{weekNumber}} {{year}} Review"
---

# Week {{weekNumber}} {{year}} — Weekly Review

## Review Period
**From:** {{sunday}} **To:** {{saturday}}

## What Got Done This Week?
```dataview
TASK
FROM ""
WHERE !completed
AND file.mtime >= date({{sunday}})
AND file.mtime <= date({{saturday}})
GROUP BY file.link
```

## Completed Tasks
```tasks
done
done after {{sunday}}
done before {{saturday}}
```

## Incomplete Tasks (Carry Over)
```tasks
not done
due before {{saturday}}
```

## Resources Saved This Week
```dataview
TABLE created AS "Created", tags AS "Tags"
FROM #resource
WHERE created >= date({{sunday}})
SORT created DESC
```

## Snippets Added This Week
```dataview
TABLE created AS "Created", language AS "Language"
FROM #snippet
WHERE created >= date({{sunday}})
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
