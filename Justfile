set dotenv-filename := "image-template.env"
set dotenv-load

export image_name := env_var("IMAGE_NAME")
export repo_organization := env_var("REPO_ORGANIZATION")
export image_desc := env_var("IMAGE_DESC")
export default_tag := env_var("DEFAULT_TAG")

# Build the image using the specified parameters
build:
    #!/usr/bin/env bash
    set -euox pipefail

    # Image metadata
    LABELS=()
    LABELS+=("--label" "io.artifacthub.package.deprecated=false")
    LABELS+=("--label" "org.opencontainers.image.title=${image_name}")
    LABELS+=("--label" "org.opencontainers.image.description=${image_desc}")
    LABELS+=("--label" "org.opencontainers.image.vendor=${repo_organization}")
    LABELS+=("--label" "org.opencontainers.image.version=${default_tag}")

    # This actually builds the image!
    PODMAN_BUILD_ARGS=("${LABELS[@]}" --pull=newer --tag "${IMAGE_NAME}:${DEFAULT_TAG}" --file Containerfile)

    podman build "${PODMAN_BUILD_ARGS[@]}" .

# Generate Default Tag
generate-default-tag:
    #!/usr/bin/env bash
    set -eoux pipefail
    echo "${DEFAULT_TAG}"

# Generate Tags
generate-build-tags:
    #!/usr/bin/env bash
    set -eoux pipefail
    DATE=$(date +%Y%m%d)
    echo "${DEFAULT_TAG}"
    echo "${DEFAULT_TAG}-${DATE}"

# Tag Images
tag-images:
    #!/usr/bin/env bash
    set -eoux pipefail
    # Get Image, and untag
    IMAGE=$(podman inspect "${IMAGE_NAME}:${DEFAULT_TAG}" | jq -r .[].Id)
    podman untag "${IMAGE}"
    podman tag "${IMAGE}" "${IMAGE_NAME}:${DEFAULT_TAG}"
    podman images

# Image Name
image-name:
    #!/usr/bin/env bash
    set -eoux pipefail
    echo "${IMAGE_NAME}"
