kubeadm init --pod-network-cidr=10.0.0.0/16 --skip-phases=addon/kube-proxy

helm repo add cilium https://helm.cilium.io/
helm repo update

API_SERVER_IP=192.168.45.121
API_SERVER_PORT=6443

helm install cilium cilium/cilium \
  --version 1.18.0 \
  --namespace kube-system \
  --set kubeProxyReplacement=true \
  --set k8sServiceHost=${API_SERVER_IP} \
  --set k8sServicePort=${API_SERVER_PORT} \
  --set ipam.mode=cluster-pool \
  --set operator.clusterPoolIPv4PodCIDRList={10.0.0.0/16} \
  --set operator.clusterPoolIPv4MaskSize=24 \
  --set gatewayAPI.enabled=true

kubectl -n kube-system get pods -l k8s-app=cilium  

kubectl -n kube-system exec ds/cilium -- cilium-dbg status | grep KubeProxyReplacement


#######

kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.2.0/config/crd/standard/gateway.networking.k8s.io_gatewayclasses.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.2.0/config/crd/standard/gateway.networking.k8s.io_gateways.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.2.0/config/crd/standard/gateway.networking.k8s.io_httproutes.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.2.0/config/crd/standard/gateway.networking.k8s.io_referencegrants.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.2.0/config/crd/standard/gateway.networking.k8s.io_grpcroutes.yaml

########

helm upgrade cilium cilium/cilium --version 1.17.6 \
    --namespace kube-system \
    --reuse-values \
    --set kubeProxyReplacement=true \
    --set gatewayAPI.enabled=true

kubectl -n kube-system rollout restart deployment/cilium-operator
kubectl -n kube-system rollout restart ds/cilium

cilium status