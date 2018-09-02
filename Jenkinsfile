node {
  stage("Build"){
  checkout scm
		sh('./build.sh')
  }
  sh('rm -rf ${BUILD_NUMBER}')
}