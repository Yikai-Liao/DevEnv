#!/bin/bash

set -e

# Default values
TAG_NAME="v0.0.0"
REPO_OWNER="owner"
REPO_NAME="repo"
BUILD_SIF="false"
OUTPUT_FILE="release_body.md"

# Parse command-line arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --tag) TAG_NAME="$2"; shift ;;
        --repo-owner) REPO_OWNER="$2"; shift ;;
        --repo-name) REPO_NAME="$2"; shift ;;
        --build-sif) BUILD_SIF="$2"; shift ;;
        --output) OUTPUT_FILE="$2"; shift ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

# Start writing the release notes
{
    if [ "$BUILD_SIF" = "true" ]; then
        echo "This release contains the AI development environment SIF file, split into multiple parts due to GitHub's file size limitations."
        echo ""
        echo "## Quick Download and Setup"
        echo ""
        echo "### Method 1: Download all parts and reassemble"
        echo '```bash'
        echo "# Download all split files"
        
        # Get list of split files and generate wget commands
        SPLIT_FILES=$(ls ai-dev-env.sif.part.* | sort)
        for file in $SPLIT_FILES; do
            echo "wget https://github.com/${REPO_OWNER}/${REPO_NAME}/releases/download/${TAG_NAME}/${file}"
        done
        
        echo ""
        echo "# Reassemble the SIF file"
        echo "cat ai-dev-env.sif.part.* > ai-dev-env.sif"
        echo ""
        echo "# Clean up split files (optional)"
        echo "rm ai-dev-env.sif.part.*"
        echo '```'
        echo ""
        echo "## Usage"
        echo "After reassembling the SIF file, you can use it with Apptainer/Singularity:"
        echo '```bash'
        echo "# Run interactive shell"
        echo "apptainer shell ai-dev-env.sif"
        echo ""
        echo "# Execute specific command"
        echo "apptainer exec ai-dev-env.sif <your-command>"
        echo '```'
        echo ""
        echo "## File Information"
        echo "- **Original file**: ai-dev-env.sif"
        echo "- **Split into**: $(echo "$SPLIT_FILES" | wc -l) parts"
    else
        echo "This release is for the AI development environment Docker image."
    fi
    echo ""
    echo "- **Repository**: ${REPO_OWNER}/${REPO_NAME}"
    echo "- **Version**: ${TAG_NAME}"
} > "$OUTPUT_FILE"

echo "✅ Release notes generated at ${OUTPUT_FILE}"
