# Bitnami Secure Hosting

## Overview
This repository was created in response to the recent Bitnami policy change ([see discussion](https://github.com/bitnami/containers/issues/83267)). Bitnami now restricts access to their secure container images, impacting automated workflows and deployments.

## Purpose
The goal of this repository is to:
- Check for the latest secure Bitnami images from the official secure registry.
- Inspect each image and pin it to a specific product tag using a designated field (e.g., `APP_VERSION`).
- Rehost the images to a secure, self-managed registry for reliable and policy-compliant access.

## How It Works
- The workflow fetches the latest images from `docker.io/bitnamisecure`.
- Each image is inspected and tagged according to its product version.
- Images are pushed to a custom registry (by default `ghcr.io/vaggeliskls`, but you can configure your own registry) for secure, controlled usage.
- The process is automated and runs daily, ensuring up-to-date and secure images.

## Why?
Bitnami's new policy limits direct access to secure images, which can break CI/CD pipelines and infrastructure automation. This repository provides a workaround by:
- Maintaining up-to-date, product-tagged images.
- Ensuring compliance and reliability for downstream users.

## Usage
- Clone this repository.
- Review the workflow in `.github/workflows/bitnami-secure-rehosting.yml`.
- Customize the image list or registry settings as needed.
- Trigger the workflow manually or let it run on schedule.



