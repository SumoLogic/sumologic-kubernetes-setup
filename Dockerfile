FROM hashicorp/terraform:1.9.5 as terraform

FROM alpine:3.20.1

ENV COLLECTION_VERSION=5577707ce153198a2dacbdfc6baa8db349cac944
ENV MONITORS_VERSION=v1.2.5
ARG TARGETPLATFORM

RUN apk add --no-cache \
        bash \
        curl \
        jq \
        git \
        && apk upgrade \
        && addgroup -g 1000 setup \
        && adduser -u 1000 -D -G setup setup \
        && mkdir /terraform /scripts /monitors \
        && chown -R setup:setup /terraform /scripts /monitors

COPY --from=terraform /bin/terraform /usr/local/bin/terraform

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
