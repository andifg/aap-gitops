#!/usr/bin/env bash
set -euo pipefail

scale_up() {
  oc scale deployment "${controller_deployment}" -n "${NAMESPACE}" --replicas=1 --wait
  oc scale deployment "${controller_web_deployment}" -n "${NAMESPACE}" --replicas=1 --wait
}

trap scale_up EXIT INT TERM

echo "oc whoami: $(oc whoami)"

# --- scale down (inline; not a function) ---
oc scale deployment "${controller_deployment}" -n "${NAMESPACE}" --replicas=0 --wait
oc scale deployment "${controller_web_deployment}" -n "${NAMESPACE}" --replicas=0 --wait

DUMP_PATH="./$(date +%d-%m-%Y-%H-%M)"

# pg_dump (directory format; restore with pg_restore -d ... "${DUMP_PATH}")
pg_dump \
  --verbose \
  --format=d \
  --clean \
  --create \
  --exit-on-error \
  --jobs=1 \
  --host="${PGHOST}" \
  --port="${PGPORT:-5432}" \
  --username="${PGUSER}" \
  --dbname="${PGDATABASE}" \
  --file="${DUMP_PATH}"

echo "Backup completed: ${DUMP_PATH}"
