---
name: crossplane-e2e
description: Patterns for writing and debugging Crossplane module e2e tests using the e2e-framework and sdk-module.
---

# Crossplane Module E2E Testing

Patterns for writing reliable e2e tests for Crossplane composition modules.

## When to Activate

- Writing new e2e tests for a Crossplane module
- Debugging XR that never becomes Available
- Setting up test infrastructure (providers, functions, pull secrets)
- Adding custom Kubernetes resource assertions

## Project Structure

```
test/e2e/
├── main_test.go          # TestMain with sdk.NewEnvironment
├── module_test.go        # Feature definitions and setup helpers
├── assertions.go         # Reusable resource assertion helpers
├── data/
│   ├── xr-minimal.yaml   # Smoke test composite resource
│   └── xr-full.yaml      # Full integration composite resource
```

## Patterns

### 1. Feature Setup Order

Setup steps must be ordered correctly to avoid race conditions:

```go
features.New("smoke-test").
    // 1. Apply XRDs first — wait for Established
    Setup(pkg.ApplyXRDs("apis/...")).
    // 2. Apply Composition
    Setup(pkg.Apply("comp/composition.yaml")).
    // 3. Apply provider runtime config, RBAC, functions
    Setup(examples.Apply("provider-rbac-helm.yaml")).
    Setup(examples.Apply("provider-runtime-helm.yaml")).
    Setup(examples.Apply("functions.yaml")).
    // 4. Upgrade provider if SDK version is older than needed
    Setup(upgradeProviderHelm(c)).
    // 5. Create ProviderConfig AFTER provider upgrade
    Setup(examples.Apply("provider-config-helm.yaml")).
    // 6. Create pull secrets for private charts
    Setup(createOrUpdateSecret("ghcr-pull-secret", "kube-system", "ghcr.io")).
    // 7. Pre-create namespaces and prerequisite CRDs
    Setup(setupNamespace("monitoring", nil)).
    // 8. Create XR and wait for Available
    Assess("XR creation", data.Timeout(5*time.Minute).ApplyComposite("xr-minimal.yaml")).
```

### 2. In-Place Provider Upgrade

Upgrade a Crossplane provider by patching `spec.package` in-place. Deleting and recreating wipes all CRD instances:

```go
func upgradeProviderHelm(c sdk.Cluster) features.Func {
    return func(ctx context.Context, t *testing.T, cfg *envconf.Config) context.Context {
        r := cfg.Client().Resources()

        patch := &unstructured.Unstructured{}
        patch.SetAPIVersion("pkg.crossplane.io/v1")
        patch.SetKind("Provider")
        patch.SetName("provider-helm")
        r.Get(ctx, "provider-helm", "", patch)
        unstructured.SetNestedField(patch.Object, "xpkg.crossplane.io/crossplane-contrib/provider-helm:v1.0.2", "spec", "package")
        r.Update(ctx, patch)

        // Wait for conditions with 8 minute timeout
        wait.For(conditions.New(r).ResourceMatch(healthyProvider, func(obj k8s.Object) bool {
            // Check status.conditions for Healthy=True
        }), wait.WithTimeout(8*time.Minute))
        return ctx
    }
}
```

### 3. Private Chart Pull Secret

Create a Kubernetes Secret with `username`/`password` keys (NOT `kubernetes.io/dockerconfigjson`) for OCI chart pulls:

```go
secret := &corev1.Secret{
    ObjectMeta: metav1.ObjectMeta{
        Name:      "ghcr-pull-secret",
        Namespace: "kube-system",
    },
    StringData: map[string]string{
        "username": username,
        "password": password,
    },
    Type: corev1.SecretTypeOpaque,
}
r := cfg.Client().Resources()
_ = r.Delete(ctx, secret)  // Delete first for idempotency
r.Create(ctx, secret)
```

### 4. Prerequisite CRD Installation

Install missing CRDs that a Helm chart depends on (e.g., HNC `HierarchyConfiguration`):

```go
crd := &unstructured.Unstructured{}
crd.SetAPIVersion("apiextensions.k8s.io/v1")
crd.SetKind("CustomResourceDefinition")
crd.SetName("hierarchyconfigurations.hnc.x-k8s.io")
crd.UnmarshalJSON([]byte(`{
    "apiVersion": "apiextensions.k8s.io/v1",
    "kind": "CustomResourceDefinition",
    "metadata": { "name": "hierarchyconfigurations.hnc.x-k8s.io" },
    "spec": {
        "group": "hnc.x-k8s.io",
        "names": { ... },
        "scope": "Namespaced",
        "versions": [{ "name": "v1alpha2", ... }]
    }
}`))
cfg.Client().Resources().Create(ctx, crd)
```

### 5. Resource Assertions

Use `conditions.New(r).ResourceMatch` with a match function:

```go
func NamespaceExistsWithLabels(c sdk.Cluster, cluster, name string, expectedLabels map[string]string) features.Func {
    return func(ctx context.Context, t *testing.T, _ *envconf.Config) context.Context {
        client := c.Client(ctx, t)
        ns := &corev1.Namespace{ObjectMeta: metav1.ObjectMeta{Name: name}}

        wait.For(conditions.New(client.Resources()).ResourceMatch(ns, func(object k8s.Object) bool {
            obs := object.(*corev1.Namespace)
            for k, v := range expectedLabels {
                if obs.Labels[k] != v {
                    return false
                }
            }
            return true
        }), wait.WithTimeout(2*time.Minute))
        return ctx
    }
}
```

### 6. Inline nolint with require-specific and require-explanation

When `nolintlint` has `require-specific: true` and `require-explanation: true`, put the nolint on the same line and list all relevant linters:

```go
r.Delete(ctx, secret) //nolint:errcheck,gosec // may not exist yet, create below handles it
```

Use `_ = ...` for errcheck with `check-blank: true`, and suppress gosec G104 explicitly.

## CI / Pre-commit Configuration

### Pre-commit Hook ID Alignment

The CI workflow's `SKIP` list must match the hook `id` in `.pre-commit-config.yaml` exactly:

```yaml
# .pre-commit-config.yaml
hooks:
  - id: golangci-lint  # ← this ID

# .github/workflows/pre-commit.yml
env:
  SKIP: no-commit-to-branch,golangci-lint  # ← must match
```

Renaming a hook ID without updating the SKIP list breaks the CI skip.

### Golangci-lint Version / Go Version Alignment

The pre-commit action builds golangci-lint from source using the CI runner's Go version. Check `go.mod` in the golangci-lint repo for minimum Go requirements:

```yaml
# .github/workflows/pre-commit.yml
- uses: actions/setup-go@v6
  with:
    go-version: "1.25"  # must satisfy golangci-lint's go.mod go directive

- uses: golangci/golangci-lint-action@v8
  with:
    version: v2.10   # match the rev in .pre-commit-config.yaml
```

### Tagliatelle: Package-Level Exclusion for API Types

When API structs use intentional naming that violates `goCamel` rules (e.g., `userCRDs`), use `overrides[].ignore: true` per package instead of `initialism-overrides` (which don't handle plural initialisms like `CRDs`):

```yaml
tagliatelle:
  case:
    rules:
      json: goCamel
    overrides:
      - pkg: apis/module/v1alpha1
        ignore: true
```

## Common Issues

| Issue | Root Cause | Fix |
|-------|-----------|-----|
| XR not reaching Available | Missing `forProvider.namespace` on Release | Add namespace to Release base template in composition |
| ProviderConfig not found | Provider delete wipes CRD instances | Use in-place `spec.package` patch instead of delete+recreate |
| Chart pull fails (401) | Private OCI chart with no auth | Add `pullSecretRef` to Release and `username`/`password` Secret |
| Namespace not found | Chart creates resources before namespaces | Pre-create required namespaces as Setup steps |
| Cleanup "not found" errors | Provider deletion destroyed CRD instances | Use in-place provider upgrade |
| Pre-commit CI fails exit code 3 | golangci-lint rev requires newer Go than CI provides | Align `go-version` in CI with golangci-lint's minimum Go requirement |
| Pre-commit hook runs in CI despite SKIP | Hook ID renamed but SKIP list not updated | Keep hook `id` in sync between `.pre-commit-config.yaml` and CI workflow's `SKIP` env |
| Tagliatelle flags API struct tags | Plural initialisms (CRDs) don't match initialism-overrides | Use `overrides[].ignore: true` for the API package instead |
| nolintlint: directive is unused for linter | Listed a linter in `//nolint` that doesn't flag the line | Only list linters that actually report issues on that line |

## Related

- `sigs.k8s.io/e2e-framework` for test infrastructure
- `github.com/elastisys/sdk-module/e2e` for Crossplane module test helpers
- `golangci-lint` docs for linter configuration
- `tdd-workflow` skill for test-driven development
