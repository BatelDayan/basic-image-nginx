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
                sh '''
                    if[ ! -f "$FILE" ]; then
                        LAST_SHA=$(docker pull "$IMAGE" | grep "Digest:" | awk '{print $2}')
                        echo "$LAST_SHA" > "$FILE"
                        echo "Created $FILE with default value"
                    else
                        LAST_SHA=$(cat "$FILE")
                        echo "Read $LAST_SHA from $FILE"
                    fi
                '''
            }
        }

        stage('Get Image Digest') {
            steps {
                sh '''
                    CURRENT_SHA=$(docker pull "$IMAGE" | grep "Digest:" | awk '{print $2}')
                    echo "Current SHA: $CURRENT_SHA"
                    if [ "$CURRENT_SHA" != "$LAST_SHA" ]; then
                        echo "Image has changed, updating $FILE"
                        echo "$CURRENT_SHA" > "$FILE"
                        LAST_SHA=$CURRENT_SHA
                        CHANGED="true"                              
                    else
                        echo "Image has not changed, no update needed"
                        CHANGED="false"
                    fi
                '''
            }
        }

        stage('CONNECT TO AWS') {
            steps {
                script {
                    if (CHANGED == "true") {
                        sh '''
                            aws configure set aws_access_key_id $Access-Key-ID-Bynat-AWS
                            aws configure set aws_secret_access_key $Secret-Access-Key-Bynat-AWS
                            aws configure set default.region $Region-Bynat-Aws
                        '''
                    } else {
                        echo "No changes detected, skipping AWS configuration."
                    }
                }
            }
        }

        stage('Update CloudFormation') {
            steps {
                script {
                    if (CHANGED == "true") {
                        sh '''
                            aws cloudformation update-stack --stack-name $STACK_NAME --template-body file://$CLOUD_FORMATION
                        '''
                    } else {
                        echo "No changes detected, skipping CloudFormation update."
                    }
                }
            }
        }
    }
}

