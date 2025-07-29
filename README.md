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
To manually transfer and tag images, run:
```bash
./transfer-bitnami-images.sh
```
This will process all images listed in your workflow or environment and push them to your configured registry.

To preview the actions without making any changes, use the debug mode:
```bash
./transfer-bitnami-images.sh --debug
```
You can also pass additional arguments to control `skopeo` behavior (e.g., `--all`, `--insecure-policy`). For example:
```bash
./transfer-bitnami-images.sh --all --insecure-policy
```
Any input except `--debug` will be passed as arguments to `skopeo`.



