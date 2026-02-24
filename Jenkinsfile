pipeline {
    agent any

    parameters {
        choice(
            name: 'DEPLOY_ENV',
            choices: ['dev', 'val', 'prod'],
            description: 'Choisir l’environnement de déploiement'
        )

        choice(
            name: 'CLIENT',
            choices: ['client1', 'client2', 'client3'],
            description: 'Choisir le client'
        )
    }

    
    environment {
        ENVIRONMENT      = "${params.DEPLOY_ENV}"
        CLIENT_NAME      = "${params.CLIENT}"
    }

    options {
        ansiColor('xterm')
    }

    stages {

        stage('Afficher paramètres') {
            steps {
                echo "Environnement sélectionné : ${ENVIRONMENT}"
                echo "Client sélectionné : ${CLIENT_NAME}"
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
                sh "terraform plan -out=tfplan -var='environment=${ENVIRONMENT}' -var='client=${CLIENT_NAME}'"
            }
        }

        stage('Manual Approval') {
            steps {
                input message: "Valider le déploiement ${ENVIRONMENT} pour ${CLIENT_NAME} ?", ok: 'Appliquer'
            }
        }

        stage('Terraform Apply') {
            steps {
                sh "terraform apply -input=false tfplan"
            }
        }
    }

    post {
        success {
            slackSend(
                channel: "#terraform",
                color: "good",
                message: "Deploy ${ENVIRONMENT} - ${CLIENT_NAME} réussi"
            )
        }

        failure {
            slackSend(
                channel: "#terraform",
                color: "danger",
                message: "Deploy ${ENVIRONMENT} - ${CLIENT_NAME} échoué"
            )
        }
    }
}