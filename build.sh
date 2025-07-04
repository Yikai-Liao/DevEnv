#!/bin/bash

# ==============================================================================
# Script Function: Build Docker image and Apptainer (Singularity) image
# ==============================================================================

# --- Argument Parsing ---
REMOVE_IMAGE=false
IMAGE_TAG="ai-dev-env:latest"
PUSH_IMAGE=false
BUILD_SIF=false

for arg in "$@"; do
    case $arg in
        --rmi)
            REMOVE_IMAGE=true
            shift
            ;;
        --tag=*)
            IMAGE_TAG="${arg#*=}"
            shift
            ;;
        --push)
            PUSH_IMAGE=true
            shift
            ;;
        --sif)
            BUILD_SIF=true
            shift
            ;;
        *)
            # Ignore unknown options
            ;;
    esac
done

# --- Build Docker Image ---
DOCKER_BUILDKIT=1 docker build -t "$IMAGE_TAG" .
# docker save -o "$IMAGE_TAG.tar" "$IMAGE_TAG" # Uncomment to save Docker image if needed

# --- Set Apptainer Temporary Build Directory ---
TMP_BUILD_DIR="$(pwd)/tmp"

# --- Build Apptainer (Singularity) Image (Optional) ---
if [ "$BUILD_SIF" = true ]; then
    mkdir -p "$TMP_BUILD_DIR" # Ensure temporary directory exists
    # Build SIF directly from Docker daemon using --tmpdir parameter
    apptainer build --tmpdir "$TMP_BUILD_DIR" ai-dev-env.sif config/ai-dev-env.def
    echo "Apptainer image ai-dev-env.sif built successfully."
fi

# --- Cleanup Operations ---
# Push Docker image if --push flag is provided
if [ "$PUSH_IMAGE" = true ]; then
    echo "Pushing Docker image $IMAGE_TAG..."
    docker push "$IMAGE_TAG"
fi

# Remove Docker image based on flag
if [ "$REMOVE_IMAGE" = true ]; then
    echo "Removing Docker image $IMAGE_TAG..."
    docker rmi "$IMAGE_TAG"
fi

# Remove temporary build directory if SIF was built
if [ "$BUILD_SIF" = true ]; then
    rm -rf "$TMP_BUILD_DIR"
fi

# rm ai-dev-env.tar # Uncomment to remove tar file if Docker image was saved previously