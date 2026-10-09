#!/usr/bin/env bash
set -euo pipefail

CONTAINER_NAME="devbox-capsule"
IMAGE_NAME="ubuntu:24.04"
HOST_PORT="8080"
CONTAINER_PORT="80"

echo "[*] Розгортання середовища капсули розробника..."

docker rm -f "${CONTAINER_NAME}" >/dev/null 2>&1 || true

docker run -d \
    --name "${CONTAINER_NAME}" \
    -p "${HOST_PORT}:${CONTAINER_PORT}" \
    "${IMAGE_NAME}" \
    sleep infinity >/dev/null

docker exec "${CONTAINER_NAME}" bash -c "
    export DEBIAN_FRONTEND=noninteractive
    apt-get update -qq && \
    apt-get install -y -qq --no-install-recommends \
        curl \
        git \
        procps \
        iproute2 \
        python3 >/dev/null
"

docker exec -d "${CONTAINER_NAME}" python3 -m http.server "${CONTAINER_PORT}"
sleep 1

HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:${HOST_PORT}/" || echo "FAIL")

if [ "${HTTP_STATUS}" = "200" ]; then
    echo "[+] Успіх: середовище розгорнуто, сервер доступний (код 200 OK)."
else
    echo "[-] Помилка підключення (код: ${HTTP_STATUS})."
    exit 1
fi
