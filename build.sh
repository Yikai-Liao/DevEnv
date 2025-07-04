#!/bin/bash

# ==============================================================================
# Script Function: Build Docker image and Apptainer (Singularity) image
# ==============================================================================

# --- Argument Parsing ---
REMOVE_IMAGE=false
IMAGE_TAG="ai-dev-env:latest"
PUSH_IMAGE=false
BUILD_SIF=false

while [[ "$#" -gt 0 ]]; do
    case "$1" in
        --rmi)
            REMOVE_IMAGE=true
            ;;
        --tag=*)
            IMAGE_TAG="${1#*=}"
            ;;
        --push)
            PUSH_IMAGE=true
            ;;
        --sif)
            BUILD_SIF=true
            ;;
        *)
            # 忽略未知选项
            ;;
    esac
    shift
done

# --- Build Docker Image ---
echo "DEBUG: IMAGE_TAG before docker build: $IMAGE_TAG"
DOCKER_BUILDKIT=1 docker build -t "$IMAGE_TAG" .
# docker save -o "$IMAGE_TAG.tar" "$IMAGE_TAG" # 如果需要，取消注释以保存 Docker 镜像

# --- Cleanup Operations ---
# 如果提供了 --push 标志，则推送 Docker 镜像
echo "DEBUG: IMAGE_TAG before docker push: $IMAGE_TAG"
if [ "$PUSH_IMAGE" = true ]; then
    echo "Pushing Docker image $IMAGE_TAG..."
    docker push "$IMAGE_TAG"
fi

# Remove Docker image based on flag
if [ "$REMOVE_IMAGE" = true ]; then
    echo "Removing Docker image $IMAGE_TAG..."
    docker rmi "$IMAGE_TAG"
fi

# --- Set Apptainer Temporary Build Directory ---
TMP_BUILD_DIR="$(pwd)/tmp"

# --- Build Apptainer (Singularity) Image (Optional) ---
if [ "$BUILD_SIF" = true ]; then
    mkdir -p "$TMP_BUILD_DIR" # 确保临时目录存在
    # 直接从 Docker daemon 构建 SIF，使用 --tmpdir 参数
    echo "Building Apptainer image ai-dev-env.sif from Docker image $IMAGE_TAG..."
    apptainer build --tmpdir "$TMP_BUILD_DIR" ai-dev-env.sif docker-daemon://"$IMAGE_TAG"
    echo "Apptainer image ai-dev-env.sif built successfully."
fi


# Remove temporary build directory if SIF was built
if [ "$BUILD_SIF" = true ]; then
    rm -rf "$TMP_BUILD_DIR"
fi

# rm ai-dev-env.tar # Uncomment to remove tar file if Docker image was saved previously