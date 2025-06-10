```bash
helm install istio-base istio/base -n istio-system --create-namespace --wait
kubectl get crd gateways.gateway.networking.k8s.io &> /dev/null || \
  kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.2.1/standard-install.yaml
helm install istiod istio/istiod --namespace istio-system --set profile=ambient --wait
helm install istio-cni istio/cni -n istio-system --set profile=ambient --wait
helm install ztunnel istio/ztunnel -n istio-system --wait
helm install istio-ingress istio/gateway -n istio-ingress --create-namespace --wait
```