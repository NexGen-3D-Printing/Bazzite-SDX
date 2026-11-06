set dotenv-filename := "image-template.env"
set dotenv-load

export image_name := env_var("IMAGE_NAME")
export repo_organization := env_var("REPO_ORGANIZATION")
export image_desc := env_var("IMAGE_DESC")
export default_tag := env_var("DEFAULT_TAG")
export bib_image := env_var("BIB_IMAGE")

# Build the image using the specified parameters
build $target_image="image_name" $tag="default_tag":
    #!/usr/bin/env bash

    set -euox pipefail

    # Image metadata for https://artifacthub.io/ - This is optional but is highly recommended so we all can get a index of all the custom images
    # The metadata by itself is not going to do anything, you choose if you want your image to be on ArtifactHub or not.
    LABELS=()
    LABELS+=("--label" "io.artifacthub.package.deprecated=false")
    LABELS+=("--label" "org.opencontainers.image.title={{ image_name }}")
    LABELS+=("--label" "org.opencontainers.image.description={{ image_desc }}")
    LABELS+=("--label" "org.opencontainers.image.vendor={{ repo_organization }}")
    LABELS+=("--label" "org.opencontainers.image.version={{ default_tag }}")

    # This actually builds the image!
    PODMAN_BUILD_ARGS=("${LABELS[@]}" --pull=newer --tag "${target_image}:${tag}" --file Containerfile)

    podman build "${PODMAN_BUILD_ARGS[@]}" .

# Generate Default Tag
generate-default-tag $tag="default_tag":
    #!/usr/bin/env bash
    set -eoux pipefail

    echo "${tag}"

# Generate Tags
generate-build-tags $target_image="image_name" $tag="default_tag":
    #!/usr/bin/env bash
    set -eoux pipefail

    DATE=$(date +%Y%m%d)
    BUILD_TAGS=()
    BUILD_TAGS+=("${tag}")
    BUILD_TAGS+=("${tag}-${DATE}")

    echo "${BUILD_TAGS[@]}"

# Tag Images
tag-images $target_image="image_name" $tag="default_tag" tags="":
    #!/usr/bin/env bash
    set -eoux pipefail

    # Get Image, and untag
    IMAGE=$(podman inspect ${target_image}:${tag} | jq -r .[].Id)
    podman untag ${IMAGE}

    # Tag Image
    for tag in ${tags}; do
        podman tag $IMAGE "${target_image}:${tag}"
    done

    # Show Images
    podman images

# Image Name
[private]
image_name $target_image="image_name":
    #!/usr/bin/env bash
    set -eoux pipefail

    echo "${image_name}"
