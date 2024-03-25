ARG BASE=public.ecr.aws/ubuntu/ubuntu:22.04
FROM ${BASE}

WORKDIR /repo/infrastructure/

ARG GROUP_ID=1000
ARG USER_ID=1000
ARG USER_NAME=shell

ENV TERM=xterm
ENV TZ=EU/Amsterdam

ARG DEBIAN_FRONTEND=noninteractive
 

COPY ./helpers.sh /usr/local/bin/helpers.sh

RUN set -x && \
  . /usr/local/bin/helpers.sh  && \
set_certificates

ENV SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt
ENV CURL_CA_BUNDLE=/etc/ssl/certs/ca-certificates.crt

RUN set -x && \
    apt-get update && \
    apt-get install -y \
        build-essential \
        git \
        jq \
        bc \
        sudo \
        vim \
        wget \
        curl \
        unzip && \
    apt-get clean
  
RUN set -x && \
  . /usr/local/bin/helpers.sh && \
  install_docker && \
  install_kubectl && \
  install_eksctl && \
  install_helm && \
  install_helmfile && \
  install_helmfile_plugin_diff && \
  install_hashicorp && \
  install_terraform && \
  install_awscli && \
  install_tflint

RUN \
  ln -s $(which kubectl) /usr/local/bin/k && \
  kubectl completion bash > /etc/bash_completion.d/kubectl && \
  addgroup --gid ${GROUP_ID} ${USER_NAME} && \
  adduser --shell /bin/bash --ingroup ${USER_NAME} --disabled-password --uid ${USER_ID} ${USER_NAME} && \
  adduser ${USER_NAME} sudo && \
  cat /etc/sudoers | sed 's/^%sudo	ALL=(ALL:ALL) ALL$/%sudo   ALL=(ALL:ALL) NOPASSWD: ALL/' > tmp && \
  mv tmp /etc/sudoers && \
  mkdir /home/${USER_NAME}/.kube && \
  touch /home/${USER_NAME}/.kube/config && \
  chmod 600 /home/${USER_NAME}/.kube/config && \
  mkdir /home/${USER_NAME}/.aws && \
  mkdir -p /home/${USER_NAME}/.terraform.d/plugin-cache && \
  chown -R ${USER_NAME}:${USER_NAME} /home/${USER_NAME} && \
  git config --system --add safe.directory /repo && \
  groupadd docker && usermod -aG docker ${USER_NAME}

COPY ./.terraformrc /home/${USER_NAME}/.terraformrc
COPY ./env.sh /etc/profile.d/env.sh

RUN  chown -R ${USER_NAME}:${USER_NAME} /home/${USER_NAME} 

USER ${USER_NAME}

CMD ["/bin/bash", "--login", "-i"]


