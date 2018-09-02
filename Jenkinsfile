node {
  stage("Deploy"){
  checkout scm
    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: '${AWS_CRED}']]){
      sh('./build.sh')
    }
  }
  sh('rm -rf ${BUILD_NUMBER}')
}