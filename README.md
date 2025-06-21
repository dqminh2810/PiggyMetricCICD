## Jenkins (Controller & Agent)
### Setup SSH key for Jenkins 
`ssh-keygen -t ed25519 -f jenkins-agent`

**Jenkins Controller (ssh client - private key) --- Jenkins Agent (ssh server - public key)**

*JENKINS - Create credentials with ssh private key & Setup agent node* 

## Jenkins & Github
**Github webhook --notify changes--> Jenkins --pull code--> Github**

*Jenkins --send build status for commit--> Github*

### Setup SSH key for Github-Jenkins-agent
**Jenkins Agent (ssh client - private key) --- Github (ssh server - public key)**

### Setup Github Access Token 
*GITHUB - Generate a Github access token & select permissions*
*JENKINS - Create credentials & update github server config*
*JENKINS - Setup ngrok to expose jenkins then update jenkins url*

## Setup Jenkins Shared Library
**Check Global Trusted Pipeline Libraries with correct library name & github project repository url**

## Build & Run Docker containers
`docker-compose up`
