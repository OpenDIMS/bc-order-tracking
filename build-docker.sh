#!/usr/bin/env bash
# Compile the OpenDIMS BC extension locally using the same Docker image the GitLab
# pipeline uses. Output ends up at bc-extension/out/opendims-bc-extension.app,
# owned by your host user.
#
# Caches BcContainerHelper PowerShell module + BC platform symbols under
# ~/.cache/opendims-bc-build/ so subsequent runs skip the ~300 MB download.
#
# Usage:
#   ./build-docker.sh                # compile with the version from app.json
#   ./build-docker.sh 23.0           # compile against a specific BC platform
#   BC_BUILD_CACHE_DIR=/tmp/x ./build-docker.sh
#
# Requires: docker (or a drop-in like podman aliased to `docker`).

set -euo pipefail

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
CACHE_DIR="${BC_BUILD_CACHE_DIR:-$HOME/.cache/opendims-bc-build}"
IMAGE="${BC_BUILD_IMAGE:-mcr.microsoft.com/powershell:7.4-ubuntu-22.04}"
BC_VERSION="${1:-}"

if ! command -v docker >/dev/null 2>&1; then
    echo "ERROR: docker is not installed or not on PATH." >&2
    exit 1
fi

HOST_UID="$(id -u)"
HOST_GID="$(id -g)"

mkdir -p \
    "$CACHE_DIR/home" \
    "$CACHE_DIR/home/.local/share/powershell/Modules" \
    "$CACHE_DIR/bcartifacts" \
    "$SCRIPT_DIR/out"

# Build a minimal /etc/passwd and /etc/group so BcContainerHelper can resolve
# the running user (otherwise ~/.bccontainerhelper resolves to /home/).
PASSWD_FILE="$CACHE_DIR/etc-passwd"
GROUP_FILE="$CACHE_DIR/etc-group"
cat > "$PASSWD_FILE" <<EOF
root:x:0:0:root:/root:/bin/bash
builder:x:${HOST_UID}:${HOST_GID}:OpenDIMS BC build:/home/builder:/bin/bash
nobody:x:65534:65534:nobody:/nonexistent:/usr/sbin/nologin
EOF
cat > "$GROUP_FILE" <<EOF
root:x:0:
builder:x:${HOST_GID}:
nogroup:x:65534:
EOF

echo "==> Image:    $IMAGE"
echo "==> Cache:    $CACHE_DIR"
echo "==> Output:   $SCRIPT_DIR/out"
echo "==> User:     builder (${HOST_UID}:${HOST_GID})"
[ -n "$BC_VERSION" ] && echo "==> Version:  $BC_VERSION (override)"

PWSH_ARGS=(-NoProfile -File /work/build.ps1 -OutputFolder /work/out)
[ -n "$BC_VERSION" ] && PWSH_ARGS+=(-BcVersion "$BC_VERSION")

docker run --rm -t \
    --user "${HOST_UID}:${HOST_GID}" \
    -v "$SCRIPT_DIR:/work" \
    -v "$CACHE_DIR/home:/home/builder" \
    -v "$CACHE_DIR/bcartifacts:/home/builder/.bcartifacts.cache" \
    -v "$PASSWD_FILE:/etc/passwd:ro" \
    -v "$GROUP_FILE:/etc/group:ro" \
    -w /work \
    -e HOME=/home/builder \
    -e USER=builder \
    -e BCCONTAINERHELPER_BCARTIFACTS_CACHE_FOLDER=/home/builder/.bcartifacts.cache \
    -e POWERSHELL_TELEMETRY_OPTOUT=1 \
    -e DOTNET_CLI_TELEMETRY_OPTOUT=1 \
    "$IMAGE" \
    pwsh "${PWSH_ARGS[@]}"

OUT_FILE="$SCRIPT_DIR/out/opendims-bc-extension.app"
if [ -f "$OUT_FILE" ]; then
    echo ""
    echo "==> Success: $OUT_FILE"
    echo "    Size:    $(stat -c%s "$OUT_FILE" 2>/dev/null || stat -f%z "$OUT_FILE") bytes"
else
    echo "ERROR: expected output not found at $OUT_FILE" >&2
    exit 1
fi
