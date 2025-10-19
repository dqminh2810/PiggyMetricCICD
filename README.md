# PiggyMetric CICD
CICD for PiggyMetric microservices

## INFRASTRUCTURE - SYSTEM LEVEL
### On-premise
**Jenkins**

`ssh-keygen -t ed25519 -f ./docker-compose-cicd/jenkins-agent/ssh/jenkins-agent`

`docker-compose -f ./docker-compose-cicd/docker-compose.cicd.yaml`

**Prometheus + Grafana**

*Modify Jenkins controller + agent IP address ./docker-compose-metric/prometheus/prometheus.yaml*

`docker-compose -f ./docker-compose-metric/docker-compose.metric.yaml`

**K3S Cluster**

`https://github.com/dqminh2810/explorement-k3s`

### Terraform - AWS EC2
*Create IAM account then update ~/.aws/credentials profile*

**Generate SSH key to connect aws ec2**

`ssh-keygen -t ed25519 -f ./terraform-k3s/ssh/k3s-cluster-key`

`ssh-keygen -t ed25519 -f ./terraform-jenkins/ssh/jenkins-cluster-key`

`ssh-keygen -t ed25519 -f ./terraform-metric/ssh/metric-cluster-key`

**Terraform**

`terraform init`

`terraform plan`

`terraform apply -auto-approve`

`terraform destroy -auto-approve`

**Connect to ec2**

`ssh -i ./ssh/k3s-cluster-key.pem admin@<hostname-ec2>`

## SETUP CONNECTIONS - APPLICATION LEVEL
### JENKINS
##### Jenkins & Github 
2 main flows between Jenkins & Github

`Jenkins --send build status for commit (1)--> Github`

`Github webhook --notify changes--> Jenkins --pull code (2)--> Github`

**(1) Setup Github Access Token**
- GITHUB - Create a Github access token & select relevant permissions
- JENKINS (**Controller**) - Create credentials & update github server config, then setup ngrok to expose jenkins &  update jenkins url

**(2) Setup SSH key for Github & Jenkins**
*Github (public key) --- Jenkins Agent (**private** key)*
- GITHUB - Add ssh public key & Add Jenkins webhook url
- JENKINS (*Agent*) - Init ssh agent then Add ssh private key 

##### Jenkins Shared Library
- JENKINS (**Controller**) - Check Global Trusted Pipeline Libraries with correct library alias & github project repository url

##### Jenkins & Docker repository
- Create credential with docker repository username/password

##### Jenkins & K3S
- Install Kubernetes plugin
- Create new cloud connection (type Kubernetes)
- Create SA for k3s (1)
- Get kubeconfig file /etc/rancher/k3s/k3s.yaml & generate jwt token for connect to k3s api server (2) `only if select HTTP type connection, if Websocket type connection bypass step`
- Create credential by k3s file for connect to K3s api server

*K3S master*
- *(1)* `kubectl apply -f k8s/jenkins-sa.yaml`
- *(2)* `kubectl create token jenkins-sa --namespace=jenkins-ns --duration=24h`

### K3S
#### K3s & Docker repository
- Create k3s secret

```
kubectl create secret docker-registry docker-reg-creds-secret \
      --docker-server=<your-registry-server> \
      --docker-username=<your-username> \
      --docker-password=<your-password> \
      --docker-email=<your-email> \
      --namespace=jenkins-ns 
```

- Read the contents of a K3S secret file

`kubectl --namespace jenkins-ns get secret docker-reg-creds-secret -o jsonpath='{.data.\.dockerconfigjson}' | base64 --decode`

## ARCHITECTURE DIAGRAM

![CICD_Architecture](https://github.com/dqminh2810/PiggyMetricCICD/blob/master/docs/PM-cicd.jpg)