pipeline {
    agent any

    environment {
        TF_VERSION = "1.6.6"
        TF_IN_AUTOMATION = "true"
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Terraform Init') {
            steps {
                sh '''
                    terraform --version
                    terraform init -input=false
                '''
            }
        }

        stage('Terraform Validate') {
            steps {
                sh '''
                    terraform validate
                '''
            }
        }

        stage('Terraform Plan') {
            steps {
                sh '''
                    terraform plan -out=tfplan
                '''
            }
        }

        stage('Show Plan') {
            steps {
                sh '''
                    terraform show tfplan
                '''
            }
        }
    }

    post {
        always {
            archiveArtifacts artifacts: 'tfplan', fingerprint: true
        }

        success {
            echo "Terraform plan completed successfully."
        }

        failure {
            echo "Terraform pipeline failed."
        }
    }
}