---
name: helmfile-contribution
description: Patterns extracted from 200+ commits to helmfile/helmfile covering commit conventions, concurrency safety, PR review workflow, Helm 3/4 dual support, and test patterns.
origin: git-history-analysis
---

# Helmfile Contribution Patterns

Patterns extracted from the helmfile/helmfile project's commit history.

## When to Activate

- Submitting a PR to helmfile/helmfile
- Reviewing a helmfile PR
- Debugging race conditions or concurrency issues
- Adding Helm 3/4 compatible features

## Commit Conventions

All commits follow: `type: description (#PR)`

Valid types: `feat`, `fix`, `build(deps)`, `build`, `chore`, `docs`, `test`, `refactor`

```
fix: pass --timeout flag through to helm for sync and apply (#2495)
feat: support HELMFILE_NAMESPACE env var for default namespace (#2592)
chore: Deduplicate preparation code of sync and apply (#2523)
```

Every commit references the PR number in parentheses. Dependabot auto-generates `build(deps)` commits.

## Concurrency Safety

Race conditions are a recurring theme. Always protect shared state:

```go
// Known race: concurrent rewriteChartDependencies access
var mu sync.Mutex
mu.Lock()
// ... critical section ...
mu.Unlock()

// Known race: shared cache paths
// Fix: skip cache refresh for shared cache paths
// Known race: os.Chdir in sequential helmfiles
// Fix: eliminate os.Chdir, use absolute paths instead
```

When modifying code that involves:
- File system operations in sequential file processing
- Shared cache or dependency resolution paths
- Concurrent goroutine access to helm state

Add mutex protection or eliminate shared mutable state.

## Helm 3/4 Dual Support

Many features need version-conditional behavior. The standard pattern:

```go
// Feature detection at runtime
if h.isHelm4() {
    // Helm 4 path
} else {
    // Helm 3 path (backward compatible)
}
```

Flag mapping examples:
| Helm 3 | Helm 4 |
|--------|--------|
| `--force` | `--force-replace` |
| CRDs handled differently | Separate CRD support |
| Template args: `--post-renderer-args VALUE` | Same format hygiene |

When adding a new feature, check if Helm 4 needs a different flag or behavior path.

## PR Review Workflow

The typical PR cycle:

1. **Feature/fix commit** — single commit with the core change
2. **Review comments** — inline feedback on the PR
3. **Fix commits** — incremental commits addressing each comment
4. **Squash merge** — into main with clean message

Common review categories:
- **Edge cases**: "What happens when the value is empty/zero/missing?"
- **Consistency**: "This doesn't match how `apply` does it"
- **Error messages**: Match existing style exactly
- **Flag semantics**: Ensure flags behave the same across `sync`, `apply`, `template`

## Values Merging Semantics

Array handling is a chronic issue. The convention:

- **Releases**: arrays should **replace**, not merge element-by-element
- **Nested helmfile values**: replace arrays
- **State values files**: `strategy: replace` for arrays (not merge)

When handling values arrays, default to replacement unless there's an explicit semantic reason to merge.

## Test Patterns

Tests use table-driven style with testify:

```go
func TestFeature(t *testing.T) {
    tests := []struct {
        name    string
        input   string
        want    string
        wantErr bool
    }{
        {name: "valid input", input: "foo", want: "bar"},
        {name: "rejects empty", input: "", wantErr: true},
    }
    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            got, err := Feature(tt.input)
            if tt.wantErr {
                assert.Error(t, err)
                return
            }
            assert.NoError(t, err)
            assert.Equal(t, tt.want, got)
        })
    }
}
```

Integration tests live in `test/`, unit tests alongside source in `_test.go`.
Use `--count=1` to disable test caching during development.

## Best Practices

1. **Reference PR numbers** in all commit messages
2. **Use `-count=1`** when running Go tests to bypass cache
3. **Prefer absolute paths** over `os.Chdir` for sequential file processing
4. **Make flags consistent** across `sync`, `apply`, and `template` commands
5. **Test interactive prompts** via `run.Ask` function injection (not public API wrappers)
6. **Keep interface changes minimal** — prefer type assertions over adding methods to providers
7. **Sign off commits** when contributing to the main repo (DCO requirement)

## Common Mistakes

1. **Missing `--kube-context` pass-through** — `flagsForDiff` must include connection flags
2. **Helm version detection order** — check Helm 4 path first, fall back to Helm 3
3. **Ignoring race conditions** — test with `-race` flag; cache/shared state is suspect
4. **Inconsistent error messages** — match existing style: lowercase, no trailing punctuation, `fmt.Errorf` with `%w`
5. **Array merging vs replacement** — default to replacement unless explicit merge is intended
6. **Forgetting `-count=1`** — stale test cache causes false passes

## Examples

### Good: Flag consistency across commands

```go
// sync.go and apply.go use identical flag definitions
cmd.Flags().Bool("detailed-exitcode", false, "return exit code 2 when releases are synced (interactive preview only)")
```

### Good: Concurrency-safe file processing

```go
var mu sync.Mutex

func processWithLock(path string) error {
    mu.Lock()
    defer mu.Unlock()
    // file operations that were previously racy
}
```

### Anti-pattern: Interface bloat

```go
// BAD: Adding methods to a provider interface for every new feature
type ConfigProvider interface {
    DetailedExitcode() bool  // don't add this
    TracksFailOnError() bool // or this
}

// GOOD: Type assertion at the call site
if dc, ok := c.(interface{ DetailedExitcode() bool }); ok {
    detailedExitcode = dc.DetailedExitcode()
}
```
