pipeline {
    agent any

    environment {
        LAST_SHA_FILE = "/var/jenkins_home/shared/global_version.txt"
        CLOUD_FORMATION = "/var/jenkins_home/shared/cloudformation.yaml"
        IMAGE = "batel123d/static-web"
        STACK_NAME = "static-web-stack"
        Access_Key_ID_Bynat_AWS = credentials('Access-Key-ID-Bynat-AWS')
        Secret_Access_Key_Bynat_AWS = credentials('Secret-Access-Key-Bynat-AWS')
        Region= credentials('Region-Bynat-Aws')

    }

    stages {

        stage('initialize') {
            steps {
                sh '''
                    if [ ! -f "$FILE" ]; then
                        LAST_SHA=$(docker pull "$IMAGE" | grep "Digest:" | awk '{print $2}')
                        echo "$LAST_SHA" > "$FILE"
                        echo "Created $FILE with default value"
                    fi
                '''
            }
        }

        stage('Update Last SHA File') {
            steps {
                sh '''
                    CURRENT_SHA=$(docker pull "$IMAGE" | grep "Digest:" | awk '{print $2}')
                    echo "Current SHA: $CURRENT_SHA"
                    LAST_SHA=$(cat "$LAST_SHA_FILE")
                    if [ "$CURRENT_SHA" != "$LAST_SHA" ]; then
                        echo "Image has changed, updating $FILE"
                        echo "$CURRENT_SHA" > "$LAST_SHA_FILE"                             
                    else
                        echo "Image has not changed, no update needed"
                        echo "stop" > stop.flag
                        exit 0
                    fi
                '''
                script {
                    if (fileExists('stop.flag')) {
                        sh 'rm -f stop.flag'
                        return
                    }
                }
            }
        }

        stage('Update CloudFormation AWS') {
            steps {
                script {
                    sh '''
                        aws configure set aws_access_key_id $Access_Key_ID_Bynat_AWS
                        aws configure set aws_secret_access_key $Secret_Access_Key_Bynat_AWS
                        aws configure set default.region $Region
                        aws cloudformation update-stack --stack-name $STACK_NAME --template-body file://$CLOUD_FORMATION

                    '''
                } 
            }
        }
    }
}


