ARG CENTOS_VERSION=10

FROM quay.io/centos-bootc/centos-bootc:stream${CENTOS_VERSION}
ARG CENTOS_VERSION

# Add tailscale repo
RUN dnf config-manager --add-repo https://pkgs.tailscale.com/stable/centos/${CENTOS_VERSION}/tailscale.repo

# Install basic needed packages
RUN dnf -y install firewalld tailscale qemu-guest-agent && \
    dnf clean all

# Create generic rootless user for running containers
ADD config/container-user.conf  /usr/lib/sysusers.d/container-user.conf
ADD config/container-home.conf  /usr/lib/tmpfiles.d/container-home.conf
RUN mkdir -p /var/lib/systemd/linger && touch /var/lib/systemd/linger/container


# Enable automatic podman container updates
RUN systemctl --global enable podman-auto-update.timer

# Initial firewall setup
RUN firewall-offline-cmd --add-interface=tailscale0 --zone=internal

# Enable basic services
RUN systemctl enable tailscaled qemu-guest-agent firewalld