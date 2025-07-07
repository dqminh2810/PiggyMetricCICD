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

## Reference
- CICD workflow described as the link bellow

[DIAGRAM](https://viewer.diagrams.net/?tags=%7B%7D&lightbox=1&highlight=0000ff&edit=_blank&layers=1&nav=1&title=PM.drawio#Uhttps%3A%2F%2Fdrive.google.com%2Fuc%3Fid%3D1nmZasrVd5d0Cm0rj1czmavtlG8exHV45%26export%3Ddownload)
