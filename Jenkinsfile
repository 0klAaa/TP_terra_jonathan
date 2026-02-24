pipeline {
    agent any

    environment {
        TF_IN_AUTOMATION = "true"
    }

    options {
        ansiColor('xterm')
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Terraform Init') {
            steps {
                sh 'terraform init -input=false'
            }
        }

        stage('Terraform Validate') {
            steps {
                sh 'terraform validate'
            }
        }

        stage('Terraform Plan') {
            steps {
                sh 'terraform plan -out=tfplan'
                sh 'terraform show tfplan'
            }
        }

        stage('Manual Approval') {
            steps {
                input(
                    message: 'Valider le déploiement Terraform ?',
                    ok: 'Appliquer',
                )
            }
        }

        stage('Terraform Apply') {
            steps {
                sh 'terraform apply -input=false tfplan'
            }
        }
    }

    post {
        always {
            archiveArtifacts artifacts: 'tfplan', fingerprint: true
        }

        success {
            echo "Déploiement terminé avec succès."
        }

        failure {
            echo "Pipeline Terraform en échec."
        }
    }
}