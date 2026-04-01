# aap-operator-gitops

## Install the root Argo CD Application (bootstrap)

The **root application** is an Argo CD `Application` that points at this repository and syncs your cluster GitOps path (for example `clusters/overlays/prod-cluster`). Apply it once so Argo CD owns the rest of the tree.

### Prerequisites

- `oc` configured for the target OpenShift cluster.
- Argo CD installed and the Argo CD namespace available (this repo’s `bootstrap/prod-cluster` overlay sets the app to namespace `argocd`).
- Argo CD **repository access** configured so it can clone the Git remote you use in the Application (for example a `Secret` of type `repository` / credentials template, SSH deploy key, or token for HTTPS private repos—see [declarative setup](https://argo-cd.readthedocs.io/en/stable/operator-manual/declarative-setup/#repositories) in the Argo CD docs).
- [Kustomize](https://kubectl.docs.kubernetes.io/installation/kustomize/) **or** use `kubectl` / `oc` with built-in kustomize support.

### Configure the Git source

Before applying, edit `bootstrap/base/root-application.yaml` so it matches **your** Git remote and branch:

- `spec.source.repoURL` — HTTPS or SSH URL of this repository.
- `spec.source.targetRevision` — branch, tag, or commit (for example `main`).

The `bootstrap/prod-cluster` overlay only patches `spec.source.path`, `metadata.namespace`, and `spec.destination.namespace`. Add another overlay or extend the patch if you need a different path or Argo CD namespace.

### Apply with Kustomize and `oc`

From the repository root:

```bash
kustomize build bootstrap/prod-cluster | oc apply -f -
```

Preview without applying:

```bash
kustomize build bootstrap/prod-cluster
```

### Apply with `oc` / `kubectl` kustomize

If your client bundles kustomize (`oc apply -k`):

```bash
oc apply -k bootstrap/prod-cluster
```

### After apply

- Confirm the app exists: `oc get application cluster-config-app-of-apps -n argocd`
- Open the Argo CD UI and sync **cluster-config-app-of-apps**, or rely on automated sync if enabled in the manifest.

### Other environments

Copy `bootstrap/prod-cluster` to a new directory (for example `bootstrap/test-cluster`), point `resources` at `../base`, and add a JSON6902 patch (same shape as `patch-root-application.yaml`) that sets `spec.source.path` and namespaces for that environment. Then run `kustomize build bootstrap/<overlay> | oc apply -f -`.
