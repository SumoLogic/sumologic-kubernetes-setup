FROM alpine:3.12

ENV TERRAFORM_VERSION=0.12.25-r0

RUN apk add --no-cache \
        bash \
        curl \
        jq \
        terraform=${TERRAFORM_VERSION} \
 # ping group has a conflicting id: 999 so delete it
 && delgroup ping \
 && addgroup -g 999 setup \
 && adduser -u 999 -D -G setup setup \
 && mkdir /terraform /scripts \
 && chown -R setup:setup /terraform /scripts

USER setup
RUN cd /terraform/ \
 && curl -O https://raw.githubusercontent.com/SumoLogic/sumologic-kubernetes-collection/v2.0.0/deploy/helm/sumologic/conf/setup/main.tf \
 && terraform init \
 && rm main.tf

ARG BUILD_TAG=latest
ENV TAG=$BUILD_TAG

WORKDIR /terraform/
