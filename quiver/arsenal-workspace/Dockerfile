FROM ubuntu:22.04

COPY . ./src

RUN \
apt-get update -y && \
apt-get install unzip -y && \
apt-get install wget -y && \
apt-get install curl -y && \
apt-get install vim -y

################################
# Install Terraform
################################
RUN \
wget https://releases.hashicorp.com/terraform/1.5.2/terraform_1.5.2_linux_amd64.zip && \
unzip terraform_1.5.2_linux_amd64.zip && \
mv terraform /usr/local/bin/

################################
# Install AWS CLI
################################
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
unzip awscliv2.zip && \
./aws/install

################################
# Install Docker
################################
# RUN apt-get install ca-certificates gnupg -y && \
# install -m 0755 -d /etc/apt/keyrings && \
# curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg && \
# chmod a+r /etc/apt/keyrings/docker.gpg && \
# echo "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null && \
# apt-get update && \
# apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

################################
# Install OpenVPN
################################
RUN apt-get install openvpn -y

CMD ["bash"]

