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
            description: 'Nom du client'
        )

        choice(
            name: 'ACTION',
            choices: ['apply', 'destroy'],
            description: 'Action Terraform'
        )
    }

    //////////////////////////////////////////////////
    // ENVIRONMENT
    //////////////////////////////////////////////////

    environment {
        TF_IN_AUTOMATION = "true"
        ENVIRONMENT      = "${params.DEPLOY_ENV}"
        CLIENT_NAME      = "${params.CLIENT}"
        TF_ACTION        = "${params.ACTION}"
    }

    options {
        ansiColor('xterm')
        timestamps()
        disableConcurrentBuilds()
    }

    stages {

        //////////////////////////////////////////////////
        // BANNIERE DE LANCEMENT
        //////////////////////////////////////////////////

        stage('Contexte') {
            steps {
                sh """
                echo -e "\\033[1;36m============================================================\\033[0m"
                echo -e "\\033[1;36m                 TERRAFORM PIPELINE                         \\033[0m"
                echo -e "\\033[1;36m============================================================\\033[0m"
                echo -e "\\033[1;34mClient        :\\033[0m ${CLIENT_NAME}"
                echo -e "\\033[1;34mEnvironnement :\\033[0m ${ENVIRONMENT}"
                echo -e "\\033[1;34mAction        :\\033[0m ${TF_ACTION}"
                echo ""
                """
            }
        }

        //////////////////////////////////////////////////
        // VALIDATION
        //////////////////////////////////////////////////

        stage('Validation paramètres') {
            steps {
                script {
                    if (!CLIENT_NAME?.trim()) {
                        error("CLIENT obligatoire.")
                    }
                }
            }
        }

        //////////////////////////////////////////////////
        // INIT
        //////////////////////////////////////////////////

        stage('Terraform Init') {
            steps {
                sh """
                echo -e "\\033[1;34m[INIT] Backend S3\\033[0m"

                terraform init \
                  -input=false \
                  -migrate-state \
                  -force-copy \
                  -backend-config="bucket=okla-terraform-state-bucket" \
                  -backend-config="key=${CLIENT_NAME}/${ENVIRONMENT}/terraform.tfstate" \
                  -backend-config="region=us-east-1" \
                  -backend-config="dynamodb_table=terraform-lock-table" \
                  -backend-config="encrypt=true"
                """
            }
        }

        //////////////////////////////////////////////////
        // PLAN
        //////////////////////////////////////////////////

        stage('Terraform Plan') {
            steps {
                script {
                    if (TF_ACTION == "destroy") {
                        sh """
                        echo -e "\\033[1;31m[PLAN DESTROY]\\033[0m"
                        terraform plan -destroy \
                          -out=tfplan \
                          -var="environment=${ENVIRONMENT}" \
                          -var="client=${CLIENT_NAME}"
                        """
                    } else {
                        sh """
                        echo -e "\\033[1;33m[PLAN APPLY]\\033[0m"
                        terraform plan \
                          -out=tfplan \
                          -var="environment=${ENVIRONMENT}" \
                          -var="client=${CLIENT_NAME}"
                        """
                    }
                }
            }
        }

        //////////////////////////////////////////////////
        // APPROVAL
        //////////////////////////////////////////////////

        stage('Manual Approval') {
            steps {
                script {
                    if (TF_ACTION == "destroy") {
                        input message: "CONFIRMER LA DESTRUCTION de ${CLIENT_NAME} (${ENVIRONMENT})", ok: "Confirmer DESTROY"
                    } else {
                        input message: "Valider le déploiement ${CLIENT_NAME} (${ENVIRONMENT}) ?", ok: "Appliquer"
                    }
                }
            }
        }

        //////////////////////////////////////////////////
        // EXECUTION
        //////////////////////////////////////////////////

        stage('Terraform Execute') {
            steps {
                script {
                    if (TF_ACTION == "destroy") {
                        sh """
                        echo -e "\\033[1;31m[DESTROY EN COURS]\\033[0m"
                        terraform apply -input=false tfplan
                        """
                    } else {
                        sh """
                        echo -e "\\033[1;32m[APPLY EN COURS]\\033[0m"
                        terraform apply -input=false tfplan
                        """
                    }
                }
            }
        }
    }

    //////////////////////////////////////////////////
    // POST
    //////////////////////////////////////////////////

    post {
        success {
            sh """
            echo -e "\\033[1;32m============================================================\\033[0m"
            echo -e "\\033[1;32m                 PIPELINE SUCCES                            \\033[0m"
            echo -e "\\033[1;32m============================================================\\033[0m"
            """
        }

        failure {
            sh """
            echo -e "\\033[1;31m============================================================\\033[0m"
            echo -e "\\033[1;31m                 PIPELINE ECHEC                             \\033[0m"
            echo -e "\\033[1;31m============================================================\\033[0m"
            """
        }
    }
}