# AAP Restore

Published image: [quay.io/redhatt/oc-psql](https://quay.io/repository/redhatt/oc-psql).

## Build

Name the image when you build (`-t …`); no separate `podman tag` is required.

```bash
podman build --platform linux/amd64 -f Containerfile -t quay.io/redhatt/oc-psql:latest .
```

## Push

Push the image to [quay.io/redhatt/oc-psql](https://quay.io/repository/redhatt/oc-psql) so OpenShift or other runtimes can pull it.

```bash
podman push quay.io/redhatt/oc-psql:latest
```
