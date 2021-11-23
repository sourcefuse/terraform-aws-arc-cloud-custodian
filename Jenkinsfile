pipeline {
  agent { label 'jenkins-dynamic-slave' }
  stages {
    stage('Tag') {
      when {
        expression { env.BRANCH_NAME == 'main' }
      }
      steps {
        script {
          env.VERSION = readFile(file: '.version')
        }
        withCredentials([gitUsernamePassword(credentialsId: 'sf-reference-arch-devops',
           gitToolName: 'git-tool')]) {
           sh('''
                git config user.name 'sfdevops'
                git config user.email 'sfdevops@sourcefuse'
                git tag -a \$VERSION -m \$VERSION
                git push origin \$VERSION
            ''')
        }
      }
    }
  }
}
