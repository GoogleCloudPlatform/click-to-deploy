argo submit \
  --output json \
  --wait https://raw.githubusercontent.com/argoproj/argo-workflows/master/examples/hello-world.yaml \
  | jq -r '.metadata.name'

argo get hello-world-g7d7x --output json | jq '.status.phase'
