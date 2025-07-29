helm install myminio minio-operator/tenant \
  --namespace minio-tenant \
  --create-namespace \
  --values values.yaml