FROM jenkins/ssh-agent:jdk17
RUN apt-get update -y && apt-get install -y \
maven \
curl
RUN cp ./ssh/jenkins-agent.pub /home/jenkins/.ssh/authorized_keys
RUN export JENKINS_AGENT_SSH_PUBKEY=$(cat /home/jenkins/.ssh/authorized_keys)
EXPOSE 22
ENTRYPOINT ["setup-sshd"]
