FROM alpine:3.13

ENV TERRAFORM_VERSION=0.13.6

RUN apk add --no-cache \
        bash \
        curl \
        jq \
 && curl -o terraform.zip https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
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
 && curl -O https://raw.githubusercontent.com/SumoLogic/sumologic-kubernetes-collection/11748f1b1481db28e6e451015031bb64f43216a3/deploy/helm/sumologic/conf/setup/main.tf \
 && terraform init \
 && rm main.tf

ARG BUILD_TAG=latest
ENV TAG=$BUILD_TAG

WORKDIR /terraform/
