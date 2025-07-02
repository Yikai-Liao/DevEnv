#!/bin/bash

# Parse command line arguments
REMOVE_IMAGE=false
for arg in "$@"; do
    case $arg in
        --rmi)
            REMOVE_IMAGE=true
            shift
            ;;
        *)
            # Unknown option
            ;;
    esac
done

docker build -t ai-dev-env:latest .
# docker save -o ai-dev-env.tar ai-dev-env:latest

# # Remove Docker image if --rmi flag is provided
# if [ "$REMOVE_IMAGE" = true ]; then
#     echo "Removing Docker image ai-dev-env:latest..."
#     docker rmi ai-dev-env:latest
# fi

TMP_BUILD_DIR="$(pwd)/tmp"

# 确保临时目录存在
mkdir -p "$TMP_BUILD_DIR"

# 使用 --tmpdir 参数直接从 Docker 守护进程构建 SIF
apptainer build --tmpdir "$TMP_BUILD_DIR" ai-dev-env.sif config/ai-dev-env.def

echo "Apptainer image ai-dev-env.sif built successfully."

# 根据标志删除 Docker 镜像
if [ "$REMOVE_IMAGE" = true ]; then
    echo "Removing Docker image ai-dev-env:latest..."
    docker rmi ai-dev-env:latest
fi

rm -rf "$TMP_BUILD_DIR"

# rm ai-dev-env.tar