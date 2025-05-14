pipeline {
    agent any

    environment {
        FILE = "/var/jenkins_home/shared/global_version.txt"
        CLOUD_FORMATION = "/var/jenkins_home/shared/cloudformation.yaml"
        IMAGE = "batel123d/static-web"
        LAST_SHA = ""
        CHANGED = "false"
    }

    stages {

        stage('initialize') {
            steps {
                script {
                    if (!fileExists(env.FILE)) {
                        env.LAST_SHA = sh(script: "docker pull \"$IMAGE\" | grep 'Digest:' | awk '{print \$2}'", returnStdout: true).trim()
                        writeFile file: env.FILE, text: env.LAST_SHA
                        echo "Created $FILE with default value: ${env.LAST_SHA}"
                    } else {
                        env.LAST_SHA = readFile(env.FILE).trim()
                        echo "Read $LAST_SHA from $FILE"
                    }
                }
            }
        }

        stage('Get Image Digest') {
            steps {
                script {
                    def currentSha = sh(script: "docker pull \"$IMAGE\" | grep 'Digest:' | awk '{print \$2}'", returnStdout: true).trim()
                    echo "Current SHA: $currentSha"
                    if (currentSha != env.LAST_SHA) {
                        echo "Image has changed, updating $FILE"
                        writeFile file: env.FILE, text: currentSha
                        env.LAST_SHA = currentSha
                        env.CHANGED = "true"
                    } else {
                        echo "Image has not changed, no update needed"
                        env.CHANGED = "false"
                    }
                }
            }
        }

        stage('CONNECT TO AWS') {
            when {
                expression { return env.CHANGED == "true" }
            }
            steps {
                sh '''
                    aws configure set aws_access_key_id $Access_Key_ID_Bynat_AWS
                    aws configure set aws_secret_access_key $Secret_Access_Key_Bynat_AWS
                    aws configure set default.region $Region_Bynat_AWS
                '''
            }
        }

        stage('Update CloudFormation') {
            when {
                expression { return env.CHANGED == "true" }
            }
            steps {
                sh '''
                    aws cloudformation update-stack --stack-name $STACK_NAME --template-body file://$CLOUD_FORMATION
                '''
            }
        }
    }
}
