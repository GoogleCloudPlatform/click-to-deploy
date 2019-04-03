TESTER_IMAGE=gcr.io/orbitera-dev/postgresql/test
cd apptest/tester

kubectl delete job bla-test -n $NAMESPACE

gcloud docker -- build -t $TESTER_IMAGE . \
  && gcloud docker -- push $TESTER_IMAGE \
  && kubectl apply -n $NAMESPACE -f ../../bla.yaml \
  && watch kubectl logs job/bla-test -n $NAMESPACE


