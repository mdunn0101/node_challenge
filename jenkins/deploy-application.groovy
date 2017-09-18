node('master') {
  stage('git pull') {
    checkout([
      $class: 'GitSCM',
      branches: [[name: '*/master']],
      userRemoteConfigs: [[
        credentialsId: '13c9dada-a7fd-4a2a-9e37-a55dcd0da755',
        url: 'git@github.com:mentat010110/node_challenge.git'
      ]]
    ])
  }
  stage('write key') {
    withCredentials([file(credentialsId: 'mentat.pem', variable: 'pem')]) {
      sh "cat ${pem} > mentat.pem"
      sh "chmod 600 mentat.pem"
    }
  }
  stage('deploy') {
    try {
      sh "scp -i mentat.pem docker/docker-compose.yml ubuntu@${SWARM_IP}:~/docker-compose.yml"
      sh "ssh -i mentat.pem ubuntu@${SWARM_IP} 'sudo docker stack deploy -c docker-compose.yml mongoose-${ENVIRONMENT}'"
      sh "rm mentat.pem"
    } catch (e) {
      sh "rm mentat.pem"
      throw e
    }
  }
}
