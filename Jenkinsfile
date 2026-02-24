pipeline {
    agent any

    parameters {
        choice(
            name: 'DEPLOY_ENV',
            choices: ['dev', 'val', 'prod'],
            description: 'Choisir l’environnement'
        )

        string(
            name: 'CLIENT',
            defaultValue: '',
            description: 'Nom du client (texte libre)'
        )
    }

    environment {
        TF_IN_AUTOMATION = "true"
        ENVIRONMENT      = "${params.DEPLOY_ENV}"
        CLIENT_NAME      = "${params.CLIENT}"
    }

    options {
        ansiColor('xterm')
    }

    stages {

        stage('Afficher paramètres') {
            steps {
                echo "Environnement : ${ENVIRONMENT}"
                echo "Client : ${CLIENT_NAME}"
            }
        }

        stage('Validation paramètres') {
             steps {
        script {
            if (!CLIENT_NAME?.trim()) {
                error("Le champ CLIENT est obligatoire.")
                    }
                }
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
}