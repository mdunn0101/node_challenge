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
  stage('update secrets') {
    try {
      sh "ssh -i mentat.pem ubuntu@${SWARM_IP} 'sudo docker secret rm s3_secrets_${ENVIRONMENT}'"
    } catch (e) { }
    withCredentials([file(credentialsId: "s3_secrets-${ENVIRONMENT}", variable: 's3_secrets')]) {
      sh "cat ${s3_secrets} > s3_secrets-${ENVIRONMENT}"
    }
    sh "scp -i mentat.pem s3_secrets-${ENVIRONMENT} ubuntu@${SWARM_IP}:~/s3_secrets-${ENVIRONMENT}"
    sh "ssh -i mentat.pem ubuntu@${SWARM_IP} 'cat s3_secrets-${ENVIRONMENT} | sudo docker secret create s3_secrets_${ENVIRONMENT} -'"
    sh "rm s3_secrets-${ENVIRONMENT}"
    sh "rm mentat.pem"
  }

}
