Curso Intensivo de Kubernetes para quem já manja de Docker
Módulo 1 - Fundamentos e Arquitetura do Kubernetes
Aula 1 - Conceitos Fundamentais
Nesta aula, você aprenderá os principais conceitos do Kubernetes:
- **Pod**: Unidade mínima de execução no Kubernetes. Um Pod pode conter um ou mais containers.
- **ReplicaSet**: Garante que um número específico de réplicas de um Pod esteja rodando a qualquer
momento.
- **Deployment**: Fornece atualizações declarativas para Pods e ReplicaSets.
- **Service**: Abstração que define um conjunto lógico de Pods e uma política para acessá-los.
- **Namespace**: Permite isolar recursos dentro do cluster.
Todos esses recursos são definidos em arquivos YAML e gerenciados com `kubectl`.
Aula 2 - Arquitetura do Cluster Kubernetes
O cluster Kubernetes é composto por dois planos:
1. **Plano de Controle (Control Plane)**:
- **kube-apiserver**: Ponto de entrada para todas as requisições de gerenciamento.
- **etcd**: Banco de dados chave-valor usado para armazenar todo o estado do cluster.
- **kube-scheduler**: Atribui Pods aos nodes com base em recursos disponíveis.
- **kube-controller-manager**: Controla o estado dos recursos.
2. **Plano de Execução (Nodes)**:
- **kubelet**: Agente que roda em cada node, garantindo que os containers estejam rodando.
- **kube-proxy**: Gerencia regras de rede para permitir comunicação entre Pods.
A comunicação entre os componentes ocorre via certificados e portas seguras.
Aula 3 - Prática: Criando um Cluster Local
Vamos usar o Minikube para criar um cluster local:
1. **Instalar o Minikube**:
Curso Intensivo de Kubernetes para quem já manja de Docker
```bash
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
```
2. **Iniciar o cluster**:
```bash
minikube start
```
3. **Criar seu primeiro Pod**:
```bash
kubectl run nginx --image=nginx --port=80
kubectl expose pod nginx --type=NodePort
```
4. **Acessar o serviço**:
```bash
minikube service nginx
```
5. **Verificar o estado**:
```bash
kubectl get pods
kubectl describe pod nginx
```
Curso Intensivo de Kubernetes para quem já manja de Docker
Módulo 2 - Implantação, Auto-recuperação e Scaling
Aula 1 - Deployments e ReplicaSets
Nesta aula você aprenderá a usar os principais controladores de aplicação do Kubernetes:
- **ReplicaSet**: Garante que um número fixo de réplicas de um pod esteja rodando.
- **Deployment**: Camada superior ao ReplicaSet, permite atualizações e rollbacks.
Exemplo:
```bash
kubectl create deployment meu-app --image=nginx
kubectl scale deployment meu-app --replicas=3
kubectl rollout status deployment meu-app
```
Rollback:
```bash
kubectl rollout undo deployment meu-app
```
Aula 2 - Probes: Liveness e Readiness
Você aprenderá a usar **health checks** para monitorar o estado dos containers:
- **Liveness Probe**: Verifica se o container está vivo.
- **Readiness Probe**: Verifica se o container está pronto para receber tráfego.
YAML exemplo:
```yaml
livenessProbe:
httpGet:
path: /health
port: 8080
Curso Intensivo de Kubernetes para quem já manja de Docker
initialDelaySeconds: 5
periodSeconds: 10
```
Aula 3 - Autoescalonamento com HPA
O Horizontal Pod Autoscaler (HPA) ajusta o número de réplicas com base em métricas.
Pré-requisitos:
```bash
minikube addons enable metrics-server
```
Criando HPA:
```bash
kubectl autoscale deployment meu-app --cpu-percent=50 --min=2 --max=5
kubectl get hpa
```
Visualize uso de CPU com:
```bash
kubectl top pod
```
Aula 4 - Prática Final: App Resiliente
Objetivo: criar um app web com 3 réplicas e simular falhas.
1. Criar deployment:
```bash
kubectl create deployment web-app --image=httpd
kubectl scale deployment web-app --replicas=3
```
Curso Intensivo de Kubernetes para quem já manja de Docker
2. Expor serviço:
```bash
kubectl expose deployment web-app --type=NodePort --port=80
```
3. Simular falhas:
```bash
kubectl delete pod <nome-do-pod>
```
O ReplicaSet recriará o pod automaticamente.
Curso Intensivo de Kubernetes para quem já manja de Docker
Módulo 3 - Serviços, Rede e Ingress
Aula 1 - Serviços no Kubernetes
No Kubernetes, os Pods são efêmeros e seus IPs mudam. Para resolver isso, usamos **Services**.
Tipos de Service:
- **ClusterIP** (padrão): acessível somente dentro do cluster.
- **NodePort**: acessível via IP do node e uma porta estática.
- **LoadBalancer**: usado em clouds públicas, expõe serviço externamente.
Criando serviços:
```bash
kubectl expose deployment meu-app --port=80 --type=NodePort
kubectl get svc
```
Aula 2 - DNS e Descoberta de Serviços
O Kubernetes usa **CoreDNS** para que Pods localizem serviços via nome.
Exemplo:
- Um Service chamado `backend` no namespace `default` pode ser acessado via:
```
http://backend.default.svc.cluster.local
```
Verificando:
```bash
kubectl exec -it <pod> -- nslookup backend
```
Aula 3 - Ingress Controller
Ingress permite rotear tráfego HTTP/S externo para serviços internos.
Curso Intensivo de Kubernetes para quem já manja de Docker
1. Instalar o nginx ingress controller:
```bash
minikube addons enable ingress
```
2. Criar Ingress:
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
name: meu-ingress
spec:
rules:
- host: exemplo.local
http:
paths:
- path: /
pathType: Prefix
backend:
service:
name: meu-servico
port:
number: 80
```
3. Atualizar /etc/hosts com IP do minikube:
```
192.168.49.2 exemplo.local
```
Curso Intensivo de Kubernetes para quem já manja de Docker
Aula 4 - TLS com cert-manager
O cert-manager automatiza a emissão de certificados TLS via Let's Encrypt.
1. Instalar cert-manager via Helm:
```bash
helm repo add jetstack https://charts.jetstack.io
helm install cert-manager jetstack/cert-manager --namespace cert-manager --create-namespace --set
installCRDs=true
```
2. Criar ClusterIssuer:
```yaml
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
name: letsencrypt-prod
spec:
acme:
server: https://acme-v02.api.letsencrypt.org/directory
email: seu-email@dominio.com
privateKeySecretRef:
name: letsencrypt-prod
solvers:
- http01:
ingress:
class: nginx
```
Curso Intensivo de Kubernetes para quem já manja de Docker
Módulo 4 - Configuração e Armazenamento
Aula 1 - ConfigMaps e Secrets
O Kubernetes permite gerenciar configurações via objetos:
- **ConfigMap**: Armazena dados de configuração não sensíveis.
- **Secret**: Armazena dados sensíveis como senhas ou tokens.
Exemplo:
```bash
kubectl create configmap app-config --from-literal=APP_MODE=production
kubectl create secret generic db-secret --from-literal=DB_PASSWORD=123456
```
Referência no Pod:
```yaml
env:
- name: APP_MODE
valueFrom:
configMapKeyRef:
name: app-config
key: APP_MODE
```
Aula 2 - Volumes e Persistência de Dados
Containers são efêmeros, por isso usamos volumes para persistência.
Tipos principais:
- `emptyDir`: Apagado com o Pod.
- `hostPath`: Usa diretório do host.
- `PersistentVolume` (PV) e `PersistentVolumeClaim` (PVC): Abstração para volumes dinâmicos.
Curso Intensivo de Kubernetes para quem já manja de Docker
Criando PVC:
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
name: meu-pvc
spec:
accessModes:
- ReadWriteOnce
resources:
requests:
storage: 1Gi
```
Aula 3 - Storage Classes e Provisionamento Dinâmico
Com StorageClasses é possível criar volumes automaticamente com base em um provisionador.
Verificar classes:
```bash
kubectl get storageclass
```
PVC com classe específica:
```yaml
spec:
storageClassName: standard
```
Em nuvem (como GKE, EKS), o provisionamento automático de discos ocorre conforme a `StorageClass`.
Aula 4 - Prática Final com Banco de Dados
Curso Intensivo de Kubernetes para quem já manja de Docker
Vamos implantar um banco de dados com armazenamento persistente e variáveis seguras.
1. Criar Secret:
```bash
kubectl create secret generic pg-secret --from-literal=POSTGRES_PASSWORD=meusegredo
```
2. Criar PVC (arquivo YAML).
3. Implantar PostgreSQL:
```yaml
env:
- name: POSTGRES_PASSWORD
valueFrom:
secretKeyRef:
name: pg-secret
key: POSTGRES_PASSWORD
volumeMounts:
- mountPath: "/var/lib/postgresql/data"
name: pgdata
```
Curso Intensivo de Kubernetes para quem já manja de Docker
Módulo 5 - Gerenciamento de Clusters e Nodes
Aula 1 - Gerenciamento de Nós
Você pode controlar o agendamento de Pods em Nodes com os seguintes comandos:
- `kubectl cordon <node>`: marca o node como indisponível para novos pods.
- `kubectl drain <node>`: remove todos os pods de um node (exceto DaemonSets).
- `kubectl uncordon <node>`: reativa o node para agendamento.
Exemplo:
```bash
kubectl cordon node01
kubectl drain node01 --ignore-daemonsets
kubectl uncordon node01
```
Aula 2 - Affinity e Tolerations
Affinity define regras de **preferência ou obrigatoriedade** para agendamento.
Node Affinity:
```yaml
affinity:
nodeAffinity:
requiredDuringSchedulingIgnoredDuringExecution:
nodeSelectorTerms:
- matchExpressions:
- key: disktype
operator: In
values:
- ssd
```
Curso Intensivo de Kubernetes para quem já manja de Docker
Tolerations permitem que pods sejam agendados em nodes com `taints`.
```yaml
tolerations:
- key: "dedicated"
operator: "Equal"
value: "gpu"
effect: "NoSchedule"
```
Aula 3 - Requests e Limits
Para garantir estabilidade do cluster, defina:
- **requests**: quantidade mínima de CPU/memória.
- **limits**: valor máximo permitido.
Exemplo:
```yaml
resources:
requests:
memory: "64Mi"
cpu: "250m"
limits:
memory: "128Mi"
cpu: "500m"
```
O scheduler usa `requests` para alocar pods em nodes.
Aula 4 - Atualização e Rolling Upgrade
Você pode atualizar os nós do cluster e garantir que os pods sejam realocados corretamente.
Curso Intensivo de Kubernetes para quem já manja de Docker
Passos:
1. `cordon` o node.
2. `drain` os pods.
3. Aplicar updates.
4. `uncordon` após reboot.
Atualizar deployment:
```bash
kubectl set image deployment meu-app nginx=nginx:1.25
kubectl rollout status deployment meu-app
```
Rollback:
```bash
kubectl rollout undo deployment meu-app
```
Curso Intensivo de Kubernetes para quem já manja de Docker
Módulo 6 - Kubernetes em Produção (Alta Disponibilidade, RBAC e Logging)
Aula 1 - Criando Clusters com kubeadm
Para ambientes reais, usamos `kubeadm` para configurar clusters.
Passos:
1. Preparar hosts (swap off, container runtime, etc).
2. No master:
```bash
kubeadm init --pod-network-cidr=10.244.0.0/16
```
3. Configurar kubeconfig:
```bash
mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
```
4. Adicionar nodes:
```bash
kubeadm join <ip-master>:6443 --token <token> --discovery-token-ca-cert-hash sha256:<hash>
```
Aula 2 - Alta Disponibilidade com Múltiplos Masters
Para HA:
- Use 3 masters com etcd em cluster.
- Coloque um load balancer na frente dos control planes.
Componentes:
- etcd em modo cluster (externo ou embutido)
- HAProxy ou keepalived para balanceamento
- Flags adicionais no kubeadm para cluster etcd
Curso Intensivo de Kubernetes para quem já manja de Docker
Documentação
[https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/high-availability/]
Aula 3 - RBAC: Controle de Acesso
RBAC permite definir permissões finas via Roles e Bindings.
Criar ServiceAccount:
```bash
kubectl create serviceaccount viewer
```
Criar Role + RoleBinding:
```yaml
kind: Role
apiVersion: rbac.authorization.k8s.io/v1
metadata:
namespace: default
name: visualizador
rules:
- apiGroups: [""]
resources: ["pods"]
verbs: ["get", "list"]
---
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
name: bind-visualizador
namespace: default
subjects:
- kind: ServiceAccount
oficial:
Curso Intensivo de Kubernetes para quem já manja de Docker
name: viewer
namespace: default
roleRef:
kind: Role
name: visualizador
apiGroup: rbac.authorization.k8s.io
```
Verificar acesso:
```bash
kubectl auth can-i list pods --as=system:serviceaccount:default:viewer
```
Aula 4 - Logging e Observabilidade
Ferramentas populares:
- **Prometheus**: métricas.
- **Grafana**: dashboards.
- **Loki**: logs.
Logs:
```bash
kubectl logs <pod>
kubectl logs <pod> -c <container>
```
Instalar stack Prometheus/Grafana via Helm:
```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm install kube-prometheus prometheus-community/kube-prometheus-stack
```
Curso Intensivo de Kubernetes para quem já manja de Docker
Ver dashboards:
```bash
kubectl port-forward svc/kube-prometheus-stack-grafana 3000:80
```
Login padrão do Grafana:
- Usuário: admin
- Senha: admin
