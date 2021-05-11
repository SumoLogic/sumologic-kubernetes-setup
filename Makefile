BUILD_TAG ?= latest
IMAGE_NAME = kubernetes-setup
ECR_URL = public.ecr.aws/u5z5f8z6
REPO_URL = $(ECR_URL)/$(IMAGE_NAME)
OPENSOURCE_ECR_URL = public.ecr.aws/a4t4y2n3
OPENSOURCE_REPO_URL = $(OPENSOURCE_ECR_URL)/$(IMAGE_NAME)

build:
	DOCKER_BUILDKIT=1 docker build \
		--build-arg BUILD_TAG=$(BUILD_TAG) \
		--build-arg BUILDKIT_INLINE_CACHE=1 \
		--cache-from $(REPO_URL):latest \
		--tag $(IMAGE_NAME):$(BUILD_TAG) \
		.

push:
	docker tag $(IMAGE_NAME):$(BUILD_TAG) $(REPO_URL):$(BUILD_TAG)
	docker push $(REPO_URL):$(BUILD_TAG)

login:
	aws ecr-public get-login-password --region us-east-1 \
	| docker login --username AWS --password-stdin $(ECR_URL)

build-push-multiplatform:
	docker buildx build \
		--push \
		--platform linux/amd64,linux/arm/v7,linux/arm64 \
		--build-arg BUILD_TAG=$(BUILD_TAG) \
		--tag $(REPO_URL):$(BUILD_TAG) \
		.

login-opensource:
	aws ecr-public get-login-password --region us-east-1 \
	| docker login --username AWS --password-stdin $(OPENSOURCE_ECR_URL)

build-push-multiplatform-opensource:
	docker buildx build \
		--push \
		--platform linux/amd64,linux/arm/v7,linux/arm64 \
		--build-arg BUILD_TAG=$(BUILD_TAG) \
		--tag $(OPENSOURCE_REPO_URL):$(BUILD_TAG) \
		.

