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

        stage('Environment Validation') {
            steps {
                sh '''
                    echo "======================================"
                    echo " Environment Validation"
                    echo "======================================"

                    pwd
                    whoami

                    echo
                    echo "Latest Commit:"
                    git log -1 --oneline

                    echo
                    echo "Tool Versions:"
                    node --version
                    npm --version
                    docker --version

                    echo
                    echo "Checking Docker daemon..."
                    docker info > /dev/null

                    echo
                    echo "Environment validation completed."
                '''
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

        stage('Docker Push') {
            steps {
                sh '''
                    chmod +x scripts/docker-push.sh
                    ./scripts/docker-push.sh --ci
                '''
            }
        }
    }

    post {

        success {
            echo '''
======================================
 Pipeline Completed Successfully
======================================
'''
        }

        failure {
            echo '''
======================================
 Pipeline Failed
======================================
'''
        }

        always {
            cleanWs()
        }
    }
}
