pipeline {
    agent any

    environment {
        FILE = "/var/jenkins_home/shared/global_version.txt"
        CLOUD_FORMATION = "/var/jenkins_home/shared/cloudformation.yaml"
        IMAGE = "batel123d/static-web"
        LAST_SHA = "gibberish"
        CHANGED = "false"
        STACK_NAME = "batel-stack"
        ECR_REPO = "batel-repo"
        Access_Key_ID_Bynat_AWS = credentials('Access-Key-ID-Bynat-AWS')
        Secret_Access_Key_Bynat_AWS = credentials('Secret-Access-Key-Bynat-AWS')
        Region_Bynat_AWS = credentials('Region-Bynat-Aws')
        ECS_ID_Bynat = credentials('ECS-ID-Bynat')
    }

    stages {

        stage('initialize') {
            steps {
                script {
                    if (!fileExists(env.FILE)) {
                        env.LAST_SHA = sh(script: "sudo docker pull \"$IMAGE\" | grep 'Digest:' | awk '{print \$2}'", returnStdout: true).trim()
                        writeFile file: env.FILE, text: env.LAST_SHA
                        echo "Created $FILE with default value: ${env.LAST_SHA}"
                    } else {
                        env.LAST_SHA = readFile(env.FILE).trim()
                        echo "Read ${env.LAST_SHA} from $FILE"
                    }
                }
            }
        }

        stage('Get Image Digest') {
            steps {
                script {
                    def currentSha = sh(script: "sudo docker pull \"$IMAGE\" | grep 'Digest:' | awk '{print \$2}'", returnStdout: true).trim()
                    echo "Current SHA: $currentSha"
                    echo "Last SHA: ${env.LAST_SHA}"
                    
                    if (currentSha != env.LAST_SHA) {
                        echo "Image has changed, updating $FILE"
                        writeFile file: env.FILE, text: currentSha
                        env.LAST_SHA = currentSha
                        env.CHANGED = "true"
                        echo "Setting CHANGED to: ${env.CHANGED}"
                    } else {
                        echo "Image has not changed, no update needed"
                        env.CHANGED = "false"
                        echo "Setting CHANGED to: ${env.CHANGED}"
                    }
                }
            }
        }

        stage('CONNECT TO AWS') {
            when {
                expression { 
                    echo "Checking CHANGED value: ${env.CHANGED}"
                    return env.CHANGED == "true" 
                }
            }
            steps {
                sh """
                    aws configure set aws_access_key_id $Access_Key_ID_Bynat_AWS
                    aws configure set aws_secret_access_key $Secret_Access_Key_Bynat_AWS
                    aws configure set default.region $Region_Bynat_AWS
                """
            }
        }

        stage('Update ECR Repository') {
            when {
                expression { return env.CHANGED == "true" }
            }
            steps {
                sh """
                    aws ecr get-login-password --region $Region_Bynat_AWS | sudo docker login --username AWS --password-stdin $ECS_ID_Bynat.dkr.ecr.$Region_Bynat_AWS.amazonaws.com
                    sudo docker tag $IMAGE $ECS_ID_Bynat.dkr.ecr.$Region_Bynat_AWS.amazonaws.com/$ECR_REPO:static-web
                    sudo docker push $ECS_ID_Bynat.dkr.ecr.$Region_Bynat_AWS.amazonaws.com/$ECR_REPO:static-web
                """
            }
        }

        stage('Update CloudFormation') {
            when {
                expression { return env.CHANGED == "true" }
            }
            steps {
                sh """
                    aws cloudformation update-stack --stack-name $STACK_NAME --template-body file://$CLOUD_FORMATION --capabilities CAPABILITY_IAM
                """
            }
        }
    }
}