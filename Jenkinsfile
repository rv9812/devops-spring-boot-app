node {
  stage("Build"){
  checkout scm {
		sh '''
        chmod +x deploy.sh
        ./deploy.sh
        '''
	}
  }
  sh('rm -rf ${BUILD_NUMBER}')
}