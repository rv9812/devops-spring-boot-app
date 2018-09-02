node {
  stage("Build"){
  checkout scm
		chmod +x build.sh
		sh('./build.sh')
  }
  sh('rm -rf ${BUILD_NUMBER}')
}