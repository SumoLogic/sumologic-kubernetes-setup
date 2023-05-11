FROM alpine:3.18.0

ENV TERRAFORM_VERSION=1.4.5
ENV COLLECTION_VERSION=c251098963278e02c012cf8471d0b7a162efcb74
ENV MONITORS_VERSION=v1.2.1
ARG TARGETPLATFORM

RUN apk add --no-cache \
        bash \
        curl \
        jq \
        git \
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
 && mkdir /terraform /scripts /monitors \
 && chown -R setup:setup /terraform /scripts /monitors

USER setup
RUN cd /terraform/ \
 && curl -O https://raw.githubusercontent.com/SumoLogic/sumologic-kubernetes-collection/${COLLECTION_VERSION}/deploy/helm/sumologic/conf/setup/main.tf \
 && terraform init \
 && rm main.tf
RUN cd /monitors/ \
 && git clone https://github.com/SumoLogic/terraform-sumologic-sumo-logic-monitor.git \
 && cd terraform-sumologic-sumo-logic-monitor \
 && git checkout ${MONITORS_VERSION} \
 && cd .. \
 && cp terraform-sumologic-sumo-logic-monitor/monitor_packages/kubernetes/* . \
 && terraform init -input=false || terraform init -input=false -upgrade \
 && rm -rf terraform-sumologic-sumo-logic-monitor

ARG BUILD_TAG=latest
ENV TAG=$BUILD_TAG

WORKDIR /terraform/
