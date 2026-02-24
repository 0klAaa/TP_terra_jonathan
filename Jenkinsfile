pipeline {
    agent any

    //////////////////////////////////////////////////
    // PARAMETERS
    //////////////////////////////////////////////////

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

    //////////////////////////////////////////////////
    // ENVIRONMENT
    //////////////////////////////////////////////////

    environment {
        TF_IN_AUTOMATION = "true"
        ENVIRONMENT      = "${params.DEPLOY_ENV}"
        CLIENT_NAME      = "${params.CLIENT}"
    }

    options {
        ansiColor('xterm')
        timestamps()
    }

    stages {

        //////////////////////////////////////////////////
        // CONTEXTE
        //////////////////////////////////////////////////

        stage('Contexte') {
            steps {
                sh '''
                echo -e "\\033[1;36m==================================================\\033[0m"
                echo -e "\\033[1;36m            CONTEXTE DU DEPLOIEMENT              \\033[0m"
                echo -e "\\033[1;36m==================================================\\033[0m"
                echo -e "\\033[1;34mEnvironnement :\\033[0m ${ENVIRONMENT}"
                echo -e "\\033[1;34mClient        :\\033[0m ${CLIENT_NAME}"
                echo ""
                '''
            }
        }

        //////////////////////////////////////////////////
        // VALIDATION PARAMETRES
        //////////////////////////////////////////////////

        stage('Validation paramètres') {
            steps {
                script {
                    if (!CLIENT_NAME?.trim()) {
                        error("Le champ CLIENT est obligatoire.")
                    }
                }
            }
        }

        //////////////////////////////////////////////////
        // TERRAFORM INIT
        //////////////////////////////////////////////////

       stage('Terraform Init') {
            steps {
                sh """
                echo -e "\\033[1;34m[INIT] Initialisation backend distant\\033[0m"

                terraform init -input=false \
                -backend-config="bucket=okla-terraform-state-bucket" \
                -backend-config="key=${CLIENT_NAME}/${ENVIRONMENT}/terraform.tfstate" \
                -backend-config="region=us-east-1" \
                -backend-config="dynamodb_table=terraform-lock-table" \
                -backend-config="encrypt=true"
                """
            }
        }

        //////////////////////////////////////////////////
        // TERRAFORM VALIDATE
        //////////////////////////////////////////////////

        stage('Terraform Validate') {
            steps {
                sh '''
                echo -e "\\033[1;34m[VALIDATE] Validation configuration\\033[0m"
                terraform validate
                '''
            }
        }

        //////////////////////////////////////////////////
        // TERRAFORM PLAN
        //////////////////////////////////////////////////

        stage('Terraform Plan') {
            steps {
                sh '''
                echo -e "\\033[1;33m[PLAN] Génération du plan\\033[0m"
                terraform plan \
                  -out=tfplan \
                  -var="environment=${ENVIRONMENT}" \
                  -var="client=${CLIENT_NAME}"
                '''
            }
        }

        //////////////////////////////////////////////////
        // APPROBATION
        //////////////////////////////////////////////////

        stage('Manual Approval') {
            steps {
                input message: "Valider le déploiement ${ENVIRONMENT} pour ${CLIENT_NAME} ?", ok: 'Appliquer'
            }
        }

        //////////////////////////////////////////////////
        // TERRAFORM APPLY
        //////////////////////////////////////////////////

        stage('Terraform Apply') {
            steps {
                sh '''
                echo -e "\\033[1;32m[APPLY] Déploiement en cours\\033[0m"
                terraform apply -input=false tfplan
                echo -e "\\033[1;32m[APPLY] Déploiement terminé\\033[0m"
                '''
            }
        }
    }

    //////////////////////////////////////////////////
    // POST
    //////////////////////////////////////////////////

    post {
        success {
            sh 'echo -e "\\033[1;32mDEPLOIEMENT REUSSI\\033[0m"'
        }

        failure {
            sh 'echo -e "\\033[1;31mDEPLOIEMENT ECHOUE\\033[0m"'
        }
    }
}