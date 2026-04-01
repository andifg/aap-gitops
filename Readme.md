# aap-operator-gitops

## Install the root Argo CD Application (bootstrap)

The **root application** is an Argo CD `Application` that points at this repository and syncs your cluster GitOps path (for example `clusters/overlays/prod-cluster`). Apply it once so Argo CD owns the rest of the tree.

### Prerequisites

- `oc` configured for the target OpenShift cluster.
- Argo CD installed and the Argo CD namespace available (this repo’s `bootstrap/prod-cluster` overlay sets the app to namespace `argocd`).
- Argo CD **repository access** configured so it can clone the Git remote you use in the Application (for example a `Secret` of type `repository` / credentials template, SSH deploy key, or token for HTTPS private repos—see [declarative setup](https://argo-cd.readthedocs.io/en/stable/operator-manual/declarative-setup/#repositories) in the Argo CD docs).
- **Database and AAP passwords** — create the real credentials **manually** in the cluster (for example with `oc create secret` or your secrets tooling) in the **database** namespace (for example `aap-db` for the CloudNativePG app user secret) and the **AAP** namespace (`aap`) where Ansible Automation Platform expects them. Do not deploy production clusters with placeholder passwords from this repository alone.
- [Kustomize](https://kubectl.docs.kubernetes.io/installation/kustomize/) **or** use `kubectl` / `oc` with built-in kustomize support.

### Configure the Git source

Point **both** the root Application and the apps ApplicationSet at the same Git remote and revision, or child Applications will clone the wrong repo or ref.

1. **`bootstrap/base/root-application.yml`** — set on the root `Application`:
   - `spec.source.repoURL` — HTTPS or SSH URL of this repository.
   - `spec.source.targetRevision` — branch, tag, or commit (for example `main`).

2. **`clusters/base/apps-applicationset.yml`** — set on `spec.template.spec.source` (the template used for each generated `Application`):
   - `repoURL` — same URL as the root application.
   - `targetRevision` — same branch, tag, or commit as the root application.

The `path` for each app still comes from the ApplicationSet list generator (for example via cluster overlays such as `clusters/<env>/patch-app-list.yml`).

The `bootstrap/prod-cluster` overlay only patches the root app’s `spec.source.path`, `metadata.namespace`, and `spec.destination.namespace`. Add another overlay or extend the patch if you need a different path or Argo CD namespace.

### Apply with Kustomize and `oc`

From the repository root:

```bash
kustomize build bootstrap/prod-cluster | oc apply -f -
```

Preview without applying:

```bash
kustomize build bootstrap/prod-cluster
```
