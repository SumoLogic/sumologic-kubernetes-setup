BUILD_TAG ?= latest
IMAGE_NAME = kubernetes-setup
ECR_URL = public.ecr.aws/sumologic
REPO_URL = $(ECR_URL)/$(IMAGE_NAME)
DOCKERFILE = Dockerfile
TAG_SUFFIX = ""

build:
	DOCKER_BUILDKIT=1 docker build \
		-f $(DOCKERFILE) \
		--build-arg BUILD_TAG=$(BUILD_TAG)$(TAG_SUFFIX) \
		--build-arg BUILDKIT_INLINE_CACHE=1 \
		--cache-from $(REPO_URL):latest \
		--tag $(IMAGE_NAME):$(BUILD_TAG)$(TAG_SUFFIX) \
		.

push:
	docker tag $(IMAGE_NAME):$(BUILD_TAG)$(TAG_SUFFIX) $(REPO_URL):$(BUILD_TAG)$(TAG_SUFFIX)
	docker push $(REPO_URL):$(BUILD_TAG)$(TAG_SUFFIX)

login:
	aws ecr-public get-login-password --region us-east-1 \
	| docker login --username AWS --password-stdin $(ECR_URL)

build-push-multiplatform:
	docker buildx build \
		-f $(DOCKERFILE) \
		--push \
		--platform linux/amd64,linux/arm/v7,linux/arm64 \
		--build-arg BUILD_TAG=$(BUILD_TAG)$(TAG_SUFFIX) \
		--tag $(REPO_URL):$(BUILD_TAG)$(TAG_SUFFIX) \
		.

