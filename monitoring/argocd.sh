echo "* Deploy and start ArgoCD ..."
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'
sleep 60

echo "* Get the ArgoCM hostIP and Pass, and login ..."
argohostip=$(kubectl get services -n argocd | awk 'NR==8 {print $4}')
argopass=$(kubectl -n argocd get secret argocd-initial-admin-secret -o=jsonpath='{.data.password}' | base64 -d)
argocd login $argohostip --username admin --password $argopass --insecure
kubectl config set-context --current --namespace=argocd

echo "* Get the projects and deploy them ..."
argocd app create monitoring --repo https://github.com/stoimenovrado/k8s-and-provisioning.git --path monitoring --dest-server https://kubernetes.default.svc
argocd app get monitoring
argocd app sync monitoring
argocd app create bgapp --repo https://github.com/stoimenovrado/k8s-and-provisioning.git --path bgapp-k8s --dest-server https://kubernetes.default.svc
argocd app get bgapp
argocd app sync bgapp

echo "This is the initial pass: $argopass"