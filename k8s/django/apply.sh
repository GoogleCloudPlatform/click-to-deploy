#!/bin/bash

# Base parameters
export APP_INSTANCE_NAME=django-1
export NAMESPACE=default
export TAG="4.1"

# Django settings
export DJANGO_REPLICAS=1

# Disk settings
export DEFAULT_STORAGE_CLASS="standard" # provide your StorageClass name if not "standard"
export DJANGO_DISK_SIZE="2Gi"
export NGINX_DISK_SIZE="1Gi"
export NFS_PERSISTENT_DISK_SIZE="5Gi"

# Nginx settings
export NGINX_REPLICAS=1

# Images
export NFS_TRACK=1.3
export IMAGE_DJANGO="marketplace.gcr.io/google/django"
export IMAGE_DJANGO="gcr.io/ccm-ops-test-adhoc/django"
export IMAGE_NGINX="${IMAGE_DJANGO}/nginx"
export IMAGE_NGINX_INIT="${IMAGE_DJANGO}/debian:${TAG}"
export IMAGE_NGINX_EXPORTER="${IMAGE_DJANGO}/nginx-exporter:${TAG}"
export IMAGE_NFS=marketplace.gcr.io/google/nfs-server1
export IMAGE_METRICS_EXPORTER="${IMAGE_DJANGO}/prometheus-to-sd:${TAG}"
export IMAGE_POSTGRESQL="marketplace.gcr.io/google/postgresql13:13.8"
export IMAGE_POSTGRESQL_EXPORTER="marketplace.gcr.io/google/postgresql-exporter0:0.8.0"

# Passwords
export POSTGRES_PASSWORD="$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 20 | head -n 1 | tr -d '\n')"

# Certificates
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /tmp/tls.key \
    -out /tmp/tls.crt \
    -subj "/CN=nginx/O=nginx"
export TLS_CERTIFICATE_KEY="$(cat /tmp/tls.key | base64)"
export TLS_CERTIFICATE_CRT="$(cat /tmp/tls.crt | base64)"

# Metrics to Stackdriver
export METRICS_EXPORTER_ENABLED=false

export DJANGO_SITE_NAME="mysite"

# Generate template
helm template "${APP_INSTANCE_NAME}" chart/django \
  --set django.image.repo="${IMAGE_DJANGO}4" \
  --set django.image.tag="${TAG}" \
  --set django.replicas="${DJANGO_REPLICAS}" \
  --set django.persistence.storageClass="${DEFAULT_STORAGE_CLASS}" \
  --set django.persistence.size="${DJANGO_DISK_SIZE}" \
  --set django.site_name="${DJANGO_SITE_NAME}" \
  --set nginx.image.repo="${IMAGE_NGINX}" \
  --set nginx.image.tag="${TAG}" \
  --set nginx.exporter.image="${IMAGE_NGINX_EXPORTER}" \
  --set nginx.initImage="${IMAGE_NGINX_INIT}" \
  --set nginx.replicas="${NGINX_REPLICAS}" \
  --set nginx.persistence.storageClass="${DEFAULT_STORAGE_CLASS}" \
  --set nginx.persistence.size="${NGINX_DISK_SIZE}" \
  --set nginx.tls.base64EncodedPrivateKey="${TLS_CERTIFICATE_KEY}" \
  --set nginx.tls.base64EncodedCertificate="${TLS_CERTIFICATE_CRT}" \
  --set nfs.image.repo="${IMAGE_NFS}" \
  --set nfs.image.tag="${NFS_TRACK}" \
  --set nfs.persistence.storageClass="${DEFAULT_STORAGE_CLASS}" \
  --set nfs.persistence.size="${NFS_PERSISTENT_DISK_SIZE}" \
  --set metrics.image="${IMAGE_METRICS_EXPORTER}" \
  --set metrics.exporter.enabled="${METRICS_EXPORTER_ENABLED}" \
  --set postgresql.image="${IMAGE_POSTGRESQL}" \
  --set postgresql.exporter.image="${IMAGE_POSTGRESQL_EXPORTER}" \
  --set postgresql.user="${DJANGO_SITE_NAME}" \
  --set postgresql.password="${POSTGRES_PASSWORD}" \
  --set postgresql.postgresDatabase="${DJANGO_SITE_NAME}" \
  > django-1_manifest.yaml

echo "Template generated!"

kubectl apply -f django-1_manifest.yaml
