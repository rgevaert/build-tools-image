FROM debian:stable-slim

ENV VAULT_VERSION 1.5.4
ENV VAULT_ZIP vault_${VAULT_VERSION}_linux_amd64.zip
ENV VAULT_URL https://releases.hashicorp.com/vault/$VAULT_VERSION/$VAULT_ZIP
ENV TERRAFORM_VERSION 0.13.4
ENV TERRAFORM_ZIP terraform_${TERRAFORM_VERSION}_linux_amd64.zip
ENV TERRAFORM_URL https://releases.hashicorp.com/terraform/$TERRAFORM_VERSION/$TERRAFORM_ZIP
ENV SHELLCHECK_URL https://github.com/koalaman/shellcheck/releases/download/stable/shellcheck-stable.linux.x86_64.tar.xz
ENV TERRAFORM_DOCS_VERSION 0.10.1

# Install prerequisites
RUN apt-get update && apt-get --no-install-recommends -y install \
    jq \
    wget \
    xz-utils \
    unzip \
    make \
    ca-certificates \
    python3-pip \
    python3-setuptools \
    git \
    curl && \
    apt-get clean && apt-get autoclean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install Vault
RUN wget $VAULT_URL && \
    unzip $VAULT_ZIP && \
    mv vault /usr/local/bin/vault && \
    rm $VAULT_ZIP

# Install Terraform
RUN wget $TERRAFORM_URL && \
    unzip $TERRAFORM_ZIP && \
    mv terraform /usr/local/bin/terraform && \
    rm $TERRAFORM_ZIP

# Install shellcheck
RUN wget -qO- $SHELLCHECK_URL | tar -xJv && \
    cp shellcheck-stable/shellcheck /usr/bin/ && \
    rm -rf shellcheck-stable shellcheck-stable.linux.x86_64.tar.xz

# Install pre-commit
RUN pip3 install pre-commit

# Install tflint
RUN curl -L "$(curl -Ls https://api.github.com/repos/terraform-linters/tflint/releases/latest | grep -o -E "https://.+?_linux_amd64.zip")" -o tflint.zip && \
    unzip tflint.zip && \
    rm tflint.zip && \
    mv tflint /usr/local/bin

RUN curl -Lo /usr/local/bin/terraform-docs "https://github.com/terraform-docs/terraform-docs/releases/download/v${TERRAFORM_DOCS_VERSION}/terraform-docs-v0.10.1-$(uname | tr '[:upper:]' '[:lower:]')-amd64" && \
    chmod +x /usr/local/bin/terraform-docs
