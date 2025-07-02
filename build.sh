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
docker save -o ai-dev-env.tar ai-dev-env:latest

# Remove Docker image if --rmi flag is provided
if [ "$REMOVE_IMAGE" = true ]; then
    echo "Removing Docker image ai-dev-env:latest..."
    docker rmi ai-dev-env:latest
fi

sudo apptainer build ai-dev-env.sif config/ai-dev-env.def
rm ai-dev-env.tar