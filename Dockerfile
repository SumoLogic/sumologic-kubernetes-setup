FROM alpine:3.15

ENV TERRAFORM_VERSION=1.1.4
ENV COLLECTION_VERSION=cccc73323e15be876a14b41db0b51183b7a029ea
ARG TARGETPLATFORM

RUN apk add --no-cache \
        bash \
        curl \
        jq \
 && apk upgrade \
 && if [ "${TARGETPLATFORM}" = "linux/amd64" ]; then TERRAFORM_PLATFORM="linux_amd64"; fi; \
    if [ "${TARGETPLATFORM}" = "linux/arm/v7" ]; then TERRAFORM_PLATFORM="linux_arm"; fi; \
    if [ "${TARGETPLATFORM}" = "linux/arm64" ]; then TERRAFORM_PLATFORM="linux_arm64"; fi; \
    if [ "${TERRAFORM_PLATFORM}" = "" ]; then TERRAFORM_PLATFORM="${TARGETPLATFORM}"; fi \
 && curl -o terraform.zip https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_${TERRAFORM_PLATFORM}.zip \
 && unzip terraform.zip \
 && mv terraform /usr/local/bin/ \
 && rm terraform.zip \
 # ping group has a conflicting id: 999 so delete it
 && delgroup ping \
 && addgroup -g 999 setup \
 && adduser -u 999 -D -G setup setup \
 && mkdir /terraform /scripts \
 && chown -R setup:setup /terraform /scripts

USER setup
RUN cd /terraform/ \
 && curl -O https://raw.githubusercontent.com/SumoLogic/sumologic-kubernetes-collection/${COLLECTION_VERSION}/deploy/helm/sumologic/conf/setup/main.tf \
 && terraform init \
 && rm main.tf

ARG BUILD_TAG=latest
ENV TAG=$BUILD_TAG

WORKDIR /terraform/
