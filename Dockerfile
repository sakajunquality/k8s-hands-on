FROM docker:18.06.1-ce-dind

ENV AWSCLI_VERSION=1.15.66 \
    JUPYTER_VERSION=1.0.0 \
    CLOUD_SDK_VERSION=216.0.0 \
    AWSCLI_VERSION=1.15.66 \
    K8S_VERSION=1.11.0 \
    KUSTOMIZE_VERSION=1.0.8 \
    PATH=/google-cloud-sdk/bin:$PATH

RUN apk --no-cache add \
    git \
    curl \
    python \
    python3 \
    py-crcmod \
    bash \
    libc6-compat \
    openssh-client \
    git \
    gnupg

# AWS CLI
RUN apk --no-cache add groff less jq \
    && apk --no-cache add --virtual build-deps py3-pip \
    && pip3 install "awscli == ${AWSCLI_VERSION}" \
    && pip3 install yq \
    && find / -type d -name \__pycache__ -depth -exec rm -rf {} \; \
    && rm -rf /root/.cache \
    && apk del --purge -r build-deps

# Goole Cloud SDK
RUN curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-${CLOUD_SDK_VERSION}-linux-x86_64.tar.gz && \
    tar xzf google-cloud-sdk-${CLOUD_SDK_VERSION}-linux-x86_64.tar.gz && \
    rm google-cloud-sdk-${CLOUD_SDK_VERSION}-linux-x86_64.tar.gz && \
    ln -s /lib /lib64 && \
    gcloud config set core/disable_usage_reporting true && \
    gcloud config set component_manager/disable_update_check true && \
    gcloud config set metrics/environment github_docker_image && \
    gcloud --version

# Install Jupyter notebook
RUN apk --no-cache add bash tini \
    && apk --no-cache add --virtual build-deps build-base python3-dev \
    && pip3 install "jupyter == ${JUPYTER_VERSION}" \
    && pip3 install backcall bash_kernel \
    && python3 -m bash_kernel.install \
    && find / -type d -name tests -depth -exec rm -rf {} \; \
    && find / -type d -name \__pycache__ -depth -exec rm -rf {} \; \
    && rm -rf /root/.cache

# Install Kubernets CLI
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/v${K8S_VERSION}/bin/linux/amd64/kubectl \
    && chmod +x ./kubectl \
    && mv ./kubectl /usr/local/bin/kubectl

# Install Kustomize
RUN curl -LO https://github.com/kubernetes-sigs/kustomize/releases/download/v${KUSTOMIZE_VERSION}/kustomize_${KUSTOMIZE_VERSION}_linux_amd64 \
    && mv kustomize_${KUSTOMIZE_VERSION}_linux_amd64 kustomize \
    && chmod +x ./kustomize \
    && mv kustomize /usr/local/bin/kustomize

WORKDIR /root/notebook

ADD config/notebooks/jupyter_notebook.py /root/.jupyter/jupyter_notebook_config.py
ADD notebooks /root/notebook
ADD app /root/notebook/app
ADD k8s /root/notebook/k8s

VOLUME /root/config
CMD ["tini", "--", "jupyter", "notebook"]
