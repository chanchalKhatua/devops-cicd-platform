pipeline {
    agent any

    options {
        timestamps()
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Show Environment') {
            steps {
                sh '''
                    echo "======================================"
                    echo " Build Information"
                    echo "======================================"

                    pwd
                    whoami

                    git log -1 --oneline

                    docker --version
                    node --version
                    npm --version
                '''
            }
        }

      stage('Install Dependencies') {
         steps {
           dir('frontend') {
            sh '''
                npm install
                npm list vite
            '''
           }
        }
      }

        stage('Build React') {
            steps {
                dir('frontend') {
                    sh 'npm run build'
                }
            }
        }

        stage('Docker Build') {
            steps {
                sh '''
                    chmod +x scripts/docker-build.sh
                    ./scripts/docker-build.sh
                '''
            }
        }

    }

    post {

        success {
            echo 'Build Successful'
        }

        failure {
            echo 'Build Failed'
        }

        always {
            cleanWs()
        }

    }
}
