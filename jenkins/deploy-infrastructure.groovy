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
  stage('write secrets') {
    dir('terraform') {
      withCredentials([file(credentialsId: 'mentat.pem', variable: 'pem')]) {
        sh "cat ${pem} > mentat.pem"
        sh "chmod 600 mentat.pem"
      }
    }
  }
  stage('terraform') {
    try {
      dir('terraform') {
        withCredentials([string(credentialsId: 'aws_admin_key', variable: 'key'), string(credentialsId: 'aws_admin_secret', variable: 'secret')]) {
          sh 'terraform init'
          sh "terraform plan -var environment=${ENVIRONMENT} -var aws_access_key=${key} -var aws_secret_key=${secret}"
          input message: 'Confirm Terraform plan', ok: 'apply'
          sh "terraform apply -var environment=${ENVIRONMENT} -var aws_access_key=${key} -var aws_secret_key=${secret}"
          sh "cp terraform.tfstate ${JENKINS_HOME}/terraform/terraform.tfstate-${ENVIRONMENT}"
        }
      }
    } catch (e) {
      dir('terraform') {
        sh "cp terraform.tfstate ${JENKINS_HOME}/terraform/terraform.tfstate-${ENVIRONMENT}"
        sh 'rm mentat.pem'
      }
      cleanWs()
      error 'The Terraform apply failed'
    }
  }
  dir('terraform') {
    sh 'rm mentat.pem'
  }
  cleanWs()
}
