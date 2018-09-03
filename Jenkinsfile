node {
  stage("Build"){
  checkout scm
    docker.image('awscli').inside {
        sh '''
        chmod +x build.sh
        ./build.sh
        '''
      }
    }
  stage("Deploy"){
  checkout scm
    docker.image('awscli').inside {
        sh '''
        chmod +x deploy.sh
        ./deploy.sh
        '''
      }
    }
 }