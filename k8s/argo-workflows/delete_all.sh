#!/bin/bash

export APP_INSTANCE_NAME="argo-workflow-1"
kubectl delete -f "${APP_INSTANCE_NAME}.yaml"
kubectl delete pvc --all
