ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')"
OS="$(uname | tr '[:upper:]' '[:lower:]')"

if [ "${ARCH}" = "amd64" ]; then
    echo "X64 Architecture"

    DOCKER_CE_VERSION=5:23.0.1-1~ubuntu.22.04~focal
    KUBECTL_VERSION=1.29.2
    TERRAFORM_VERSION=1.7.5-1
    AWSCLI_VERSION=2.15.19
    AWSCLI_ARCH="x86_64"
    EKSCTL_VERSION=0.142.0
    HELM_VERSION=3.10.2
    HELMFILE_VERSION=0.155.0
    HELMFILE_PLUGIN_DIFF_VERSION=3.8.1
    TFLINT_VERSION=0.47.0
fi
if [ "${ARCH}" = "arm64" ]; then 
    echo "ARM Architecture"

    DOCKER_CE_VERSION=5:23.0.1-1~ubuntu.22.04~focal
    KUBECTL_VERSION=1.29.2
    TERRAFORM_VERSION=1.7.5-1
    AWSCLI_VERSION=2.15.19
    AWSCLI_ARCH="aarch64"
    EKSCTL_VERSION=0.142.0
    HELM_VERSION=3.10.2
    HELMFILE_VERSION=0.155.0
    HELMFILE_PLUGIN_DIFF_VERSION=3.8.1
    TFLINT_VERSION=0.47.0
fi

install_docker() {
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
  echo "deb [arch=${ARCH} signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | \
    tee /etc/apt/sources.list.d/docker.list
  
  apt update
  apt-get install -y docker-ce-cli
  apt-get clean
}


install_kubectl() {
  version=${KUBECTL_VERSION}

  url="https://storage.googleapis.com/kubernetes-release/release/v${version}/bin/${OS}/${ARCH}/kubectl"
  object=${url##*/}

  curl -sSLO $url
  install $object /usr/local/bin
  rm $object
  kubectl version --client
}

download_web_object() {
  url=$1
  curl -sSLO $url
}

install_from_tarball() {
  tarball=$1
  executable_path=$2
  TMP_DIR=$(mktemp -d)
  tar -C $TMP_DIR -xzvf $tarball $executable_path
  install $TMP_DIR/$executable_path /usr/local/bin
  rm -rf $TMP_DIR $tarball
}

install_eksctl() {
  version=${EKSCTL_VERSION}

  url="https://github.com/eksctl-io/eksctl/releases/download/v${version}/eksctl_${OS}_${ARCH}.tar.gz"
  tarball=${url##*/}
  download_web_object $url
  install_from_tarball $tarball "eksctl"
}

install_helm() {
  version=${HELM_VERSION}

  url="https://get.helm.sh/helm-v${version}-${OS}-${ARCH}.tar.gz"
  tarball=${url##*/}
  download_web_object $url
  install_from_tarball $tarball "${OS}-${ARCH}/helm"
  helm version
}

install_helmfile() {
  version=${HELMFILE_VERSION}

  url="https://github.com/helmfile/helmfile/releases/download/v${version}/helmfile_${version}_${OS}_${ARCH}.tar.gz"
  tarball=${url##*/}
  download_web_object $url
  install_from_tarball $tarball "helmfile"
  helmfile --version
}

install_helmfile_plugin_diff() {
  version=${HELMFILE_PLUGIN_DIFF_VERSION}

  url="https://github.com/databus23/helm-diff/releases/download/v${version}/helm-diff-${OS}-${ARCH}.tgz"
  tarball=${url##*/}
  download_web_object $url
  PLUGIN_DIR=/home/${USER_NAME}/.local/share/helm/plugins/helm-diff
  mkdir -p ${PLUGIN_DIR}
  tar xvf $tarball -C ${PLUGIN_DIR} --strip-components=1
  rm -f $tarball
  #helm plugin list | grep ^diff
}


install_hashicorp() {
  wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
  echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
    tee /etc/apt/sources.list.d/hashicorp.list
  apt update
}

install_terraform() {
  version=${TERRAFORM_VERSION}

  apt-get install -y terraform=$version || apt-cache madison terraform
  terraform -version
}

install_awscli() {
  version=${AWSCLI_VERSION}

  curl "https://awscli.amazonaws.com/awscli-exe-${OS}-${AWSCLI_ARCH}-${version}.zip" -o "awscliv2.zip"

  unzip awscliv2.zip
  ./aws/install
  rm -rf aws*
  sudo rm -rf /usr/local/aws-cli/*/*/dist/awscli/examples
  aws --version
}

set_certificates() {
    apt-get -o "Acquire::https::Verify-Peer=false" -o "Acquire::https::Verify-Host=false" update
    apt-get -o "Acquire::https::Verify-Peer=false" -o "Acquire::https::Verify-Host=false" install -y curl software-properties-common ca-certificates
    update-ca-certificates
}

install_tflint() {
  version=${TFLINT_VERSION}

  download_path=$(mktemp -d -t tflint.XXXXXXXXXX)
  download_zip="${download_path}/tflint.zip"
  download_executable="${download_path}/tflint"

  echo "Downloading TFLint $version"
  curl --fail -sS -L -o "${download_zip}" "https://github.com/terraform-linters/tflint/releases/download/v${version}/tflint_linux_${ARCH}.zip"
  echo "Downloaded successfully"

  echo -e "\n\n===================================================="
  echo "Unpacking ${download_zip} ..."
  unzip -o "${download_zip}" -d "${download_path}"

  dest="/usr/local/bin/"
  echo "Installing ${download_executable} to ${dest} ..."

  install -c -v "${download_executable}" "$dest"
  retVal=$?
  if [ $retVal -ne 0 ]; then
    echo "Failed to install tflint"
    exit $retVal
  fi

  echo "Cleaning temporary downloaded files directory ${download_path} ..."
  rm -rf "${download_path}"

  echo -e "\n\n===================================================="
  echo "Current tflint version"
  "${dest}/tflint" -v

  ls -la /home/${USER_NAME}/

  cat <<EOF > /home/${USER_NAME}/.tflint.hcl
plugin "aws" {
    enabled = true
    version = "0.25.0"
    source  = "github.com/terraform-linters/tflint-ruleset-aws"
}
EOF
}