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
        success {
            slackSend(
                channel: "#terraform",
                color: "good",
                message: "Apply réussi - ${env.JOB_NAME} #${env.BUILD_NUMBER}"
            )
        }

        failure {
            slackSend(
                channel: "#terraform",
                color: "danger",
                message: "Pipeline échoué - ${env.JOB_NAME} #${env.BUILD_NUMBER}"
            )
        }
}