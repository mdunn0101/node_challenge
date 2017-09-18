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
  stage('build') {
      sh "docker build -t registry.azabu-juban.com/mongoose-${APPLICATION} -f docker/Dockerfile-${APPLICATION} ."
  }
  stage('tag') {
      sh "docker tag registry.azabu-juban.com/mongoose-${APPLICATION} registry.azabu-juban.com/mongoose-${APPLICATION}:${BUILD_NUMBER}"
  }
  stage('push') {
      sh "docker push registry.azabu-juban.com/mongoose-${APPLICATION}"
      sh "docker push registry.azabu-juban.com/mongoose-${APPLICATION}:${BUILD_NUMBER}"
  }
}
