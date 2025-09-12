# PiggyMetric CICD
Jenkins server (Controller & Agent) for PiggyMetric CICD

## Setup SSH key for Jenkins (Controller & Agent)
`Jenkins Controller (ssh client - private key) --- Jenkins Agent (ssh server - public key)`

- `mkdir .ssh` then `cd .ssh`
- Generate ssh public/private key on your host`ssh-keygen -t ed25519 -f jenkins-agent`
- Build & Launch `docker-compose up -d`
- JENKINS (**Agent**) - ssh public key has been added to jenkins agent
- JENKINS (**Controller**) - Create credentials with ssh private key & Setup agent node

## Setup connections for Jenkins & Github 
2 main flows between Jenkins & Github

`Jenkins --send build status for commit (1)--> Github`

`Github webhook --notify changes--> Jenkins --pull code (2)--> Github`

### (1) Setup Github Access Token 
- GITHUB - Create a Github access token & select relevant permissions
- JENKINS (**Controller**) - Create credentials & update github server config, then setup ngrok to expose jenkins &  update jenkins url

### (2) Setup SSH key for Github & Jenkins
*Github (public key) --- Jenkins Agent (**private** key)*
- GITHUB - Add ssh public key & Add Jenkins webhook url
- JENKINS (*Agent*) - Init ssh agent then Add ssh private key 

## Setup Jenkins Shared Library
- JENKINS (**Controller**) - Check Global Trusted Pipeline Libraries with correct library alias & github project repository url

## Setup connections for Jenkins & K3S
- Install Kubernetes plugin
- Create new cloud connection (type Kubernetes)
- K8s URL = `Master-IP`:6443
- Setup K3S server SSL certificate on Jenkins (1)
- Create credential text for jwt token to K3s api server (2)
- Change Jenkins connection (Master - Agent) type to WebSocket instead TCP port

*(1)*
**K3S master** 
- Get K3S server SSL certificate `cat /var/lib/rancher/k3s/server/tls/server-ca.crt`

**Jenkins master**
- Copy `server-ca.crt` -> `~/k3s-ca.cer`
- Update in jenkins SSL trust repository

`cd $JAVA_HOME/lib/security`

`keytool -import -trustcacerts -file ~/k3s-ca.cer -alias k3s-ca -keystore $JAVA_HOME/lib/security/cacerts -storepass changeit`

*(2)*
**K3S master**
- Generate jwt token to k3s api server `kubectl create token default -n default`

## ARCHITECTURE

![CICD_Architecture](https://github.com/dqminh2810/PiggyMetricCICD/blob/master/docs/PM-cicd.jpg)
