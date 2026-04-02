# aap-operator-gitops

## Install the root Argo CD Application (bootstrap)

The **root application** is an Argo CD `Application` that points at this repository and syncs your cluster GitOps path (for example `clusters/overlays/prod-cluster`). Apply it once so Argo CD owns the rest of the tree.

### Prerequisites

- `oc` configured for the target OpenShift cluster.
- Argo CD installed and the Argo CD namespace available (this repo’s `bootstrap/prod-cluster` overlay sets the app to namespace `argocd`).
- **Sensitive configuration** — several `Secret` objects are expected to exist in the cluster but are **not** shipped with real credentials in Git. Create them yourself (see [Secrets outside this repository](#secrets-outside-this-repository)); you can keep working copies under **`.idea/`** (already listed in `.gitignore`).
- [Kustomize](https://kubectl.docs.kubernetes.io/installation/kustomize/) **or** use `kubectl` / `oc` with built-in kustomize support.

### Secrets outside this repository

These secrets are **external to the tracked GitOps manifests** (or only exist as local templates). Apply them with `oc apply -f …` (or your secrets operator) **before** or **after** bootstrap, depending on when Argo CD and the workloads need them. Align namespaces with your ApplicationSet destinations (for example `aap-db` for the database app, `aap` for AAP).

| Secret name | Namespace | Referenced by | Role | Example template in `.idea/` |
|-------------|-----------|----------------|------|------------------------------|
| `aap-install-gitops` | Argo CD control plane (e.g. `openshift-gitops` or `argocd`) | Argo CD | Declarative **repository** credentials so Argo CD can clone the Git remote (`url`, `type`, SSH key or HTTPS credentials). Label: `argocd.argoproj.io/secret-type: repository`. See [declarative setup](https://argo-cd.readthedocs.io/en/stable/operator-manual/declarative-setup/#repositories). | `secret.yml` |
| `aap-db-secret` | `aap-db` | `apps/cloud-native-pg-ressources/base/cluster.yml` | CloudNativePG **`bootstrap.initdb.secret`**: database owner **`username`** and **`password`** (must match `spec.bootstrap.initdb.owner`). | `aap-db-secret.yml` |
| `aap-db-connection` | `aap` | `apps/aap-resources/base/automation-controller.yml` | **`spec.postgres_configuration_secret`**: external Postgres connection for automation controller (`host`, `port`, `database`, `username`, `password`, `sslmode`, `type`, etc.). | `aap-db-connection.yml` |

**`password` / `sshPrivateKey` values** must be strong, unique secrets in real environments—never rely on `change-me` or committed keys.
prev
**Not a bootstrap secret:** `.idea/sub.yml` is an exported `Subscription` (including `status`) from a live cluster. Use the versioned Subscription under `apps/aap-operator/` in Git instead of treating `sub.yml` as something to apply.

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