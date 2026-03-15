# basic-bootc-host

A generic [bootc](https://bootc-dev.github.io/) host image based on CentOS Stream, designed for running rootless containers in cloud VMs.

## Deployment

Initial provisioning is handled with **Terraform** and **cloud-init**. The host OS and container workloads update automatically. Further management can be handled via **GitHub Actions** / **GitLab CI/CD**

[Tailscale](https://tailscale.com/) can be used as an easy way to provid secure network access to application API endpoints for use with CI/CD workflows.