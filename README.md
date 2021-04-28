# sumologic-kubernetes-setup

Setup image for the [Sumologic Kubernetes Collection](https://github.com/SumoLogic/sumologic-kubernetes-collection)

The images are pushed to [public.ecr.aws/sumologic/kubernetes-setup](https://gallery.ecr.aws/sumologic/kubernetes-setup).

The images are built for the following architectures:

- `linux/amd64`
- `linux/arm/v7`
- `linux/arm64/v8`

## Build

To build image only for the build host's architecture:

```shell
make build
```

To build multi-platform image and push it to a registry:

```shell
make build-push-multiplatform REPO_URL=my-repo/setup BUILD_TAG=custom-tag
```
