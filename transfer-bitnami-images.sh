#!/bin/bash

# Check for global or local skopeo, download if missing
if command -v skopeo &> /dev/null; then
    SCOPEO="skopeo"
elif [ -x "./skopeo" ]; then
    SCOPEO="./skopeo"
else
    echo "Skopeo not found globally or locally. Downloading..."
    curl -L -o skopeo "https://github.com/vaggeliskls/skopeo/releases/download/1.16.1/skopeo.linux.amd64"
    chmod +x skopeo
    SCOPEO="./skopeo"
fi

SOURCE_REGISTRY="${SOURCE_REGISTRY:-docker.io/bitnamisecure}"
TARGET_REGISTRY="${TARGET_REGISTRY:-ghcr.io/vaggeliskls}"
SOURCE_IMAGES="${SOURCE_IMAGES:-gitea,postgresql,redis,kafka,mongodb,rabbitmq,redis,minio,nginx-ingress-controller,nginx,cainjector,cert-manager,cert-manager-webhook}"

if [ -z "$TARGET_REGISTRY" ]; then
    echo "TARGET_REGISTRY environment variable not set."
    exit 1
fi
if [ -z "$SOURCE_IMAGES" ]; then
    echo "SOURCE_IMAGES environment variable not set."
    exit 1
fi

# Determine tag field to use
TAG_FIELD="${SOURCE_TAG_FIELD:-APP_VERSION}"


IFS=',' read -ra ADDR <<< "$SOURCE_IMAGES"

echo "Source images count: ${#ADDR[@]}"
TRANSFERRED=0


# Parse arguments: --debug triggers debug mode, all others are passed to skopeo copy
DEBUG=false
# Allow SKOPEO_ARGS to be set from environment variable (space-separated)
if [ -n "$SKOPEO_ARGS_ENV" ]; then
    # Split SKOPEO_ARGS_ENV into array
    read -r -a SKOPEO_ARGS <<< "$SKOPEO_ARGS_ENV"
else
    SKOPEO_ARGS=()
fi
# Also parse command-line arguments
for arg in "$@"; do
    if [ "$arg" == "--debug" ]; then
        DEBUG=true
    else
        SKOPEO_ARGS+=("$arg")
    fi
done

for NAME in "${ADDR[@]}"; do
    NAME=$(echo $NAME | xargs)
    if [ -n "$NAME" ]; then
        INSPECT_JSON=$($SCOPEO inspect docker://$SOURCE_REGISTRY/$NAME:latest 2>&1)
        if echo "$INSPECT_JSON" | grep -q "requested access to the resource is denied"; then
            echo "Image $SOURCE_REGISTRY/$NAME:latest does not exist or access denied. Skipping."
            continue
        fi
        # Extract tag from Config.Env using grep and sed
        TAG=$(echo "$INSPECT_JSON" | grep -o "${TAG_FIELD}=[^\" ]*" | head -n1 | sed "s/${TAG_FIELD}=//")
        if [ -z "$TAG" ]; then
            echo "Could not find $TAG_FIELD in $NAME:latest. Skipping."
            continue
        fi
        SRC_IMAGE="$SOURCE_REGISTRY/$NAME:$TAG"
        DEST_IMAGE="$TARGET_REGISTRY/$NAME:$TAG"
        if [ "$DEBUG" = true ]; then
            echo "[DEBUG] Would transfer: $SRC_IMAGE -> $DEST_IMAGE"
            TRANSFERRED=$((TRANSFERRED+1))
        else
            echo "Transferring $SRC_IMAGE to $DEST_IMAGE"
            $SCOPEO copy "${SKOPEO_ARGS[@]}" docker://$SRC_IMAGE docker://$DEST_IMAGE && TRANSFERRED=$((TRANSFERRED+1))
        fi
    fi
done

echo "Transfer complete. $TRANSFERRED/${#ADDR[@]} images transferred."
