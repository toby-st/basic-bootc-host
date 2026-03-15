ARG CENTOS_VERSION=10

FROM quay.io/centos-bootc/centos-bootc:stream${CENTOS_VERSION}
ARG CENTOS_VERSION

# Add tailscale repo
RUN dnf config-manager --add-repo https://pkgs.tailscale.com/stable/centos/${CENTOS_VERSION}/tailscale.repo

# Install basic needed packages
RUN dnf -y install firewalld tailscale qemu-guest-agent && \
    dnf clean all

# Container image signature policy and signing public key
ADD config/policy.json          /etc/containers/policy.json
ADD config/registries.d.yaml    /etc/containers/registries.d/ghcr.io-toby-st.yaml
RUN mkdir -p /usr/share/keys
ADD config/2025.11.pub          /usr/share/keys/2025.11.pub

# Add sshd config
ADD config/sshd_config /etc/ssh/sshd_config

# Enable cloud console
ADD config/05-cloud-kargs.toml /usr/lib/bootc/install/05-cloud-kargs.toml

# Create generic rootless user for running containers
ADD config/container-user.conf  /usr/lib/sysusers.d/container-user.conf
RUN systemd-sysusers && \
    install -d -m 0750 /var/home/container/.config/containers/systemd && \
    chown -R 1000:1000 /var/home/container && \
    echo 'container:100000:65536' >> /etc/subuid && \
    echo 'container:100000:65536' >> /etc/subgid && \
    mkdir -p /var/lib/systemd/linger && touch /var/lib/systemd/linger/container

# Enable automatic podman container updates
RUN systemctl --global enable podman-auto-update.timer

# Initial firewall setup
RUN firewall-offline-cmd --add-interface=tailscale0 --zone=internal && firewall-offline-cmd --remove-service-from-zone=cockpit--zone=public

# Enable basic services
RUN systemctl enable tailscaled qemu-guest-agent firewalld