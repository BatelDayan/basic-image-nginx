pipeline {
    agent any

    environment {
        LAST_SHA_FILE = "/var/jenkins_home/shared/global_version.txt"
        CLOUD_FORMATION = "/var/jenkins_home/shared/cloudformation.yaml"
        IMAGE = "batel123d/static-web"
        STACK_NAME = "static-web-stack"
        Access_Key_ID_Bynat_AWS = credentials('Access-Key-ID-Bynat-AWS')
        Secret_Access_Key_Bynat_AWS = credentials('Secret-Access-Key-Bynat-AWS')
        Region = credentials('Region-Bynat-Aws')
    }

    stages {
        stage('initialize') {
            steps {
                sh """
                    # Create directory if it doesn't exist
                    mkdir -p "\$(dirname "${LAST_SHA_FILE}")"
                    
                    # Check if file exists
                    if [ ! -f "${LAST_SHA_FILE}" ]; then
                        # Need to use sudo with docker
                        LAST_SHA=\$(sudo docker pull "${IMAGE}" | grep "Digest:" | awk '{print \$2}')
                        echo "\$LAST_SHA" > "${LAST_SHA_FILE}"
                        echo "Created ${LAST_SHA_FILE} with default value"
                    fi
                """
            }
        }

        stage('Update Last SHA File') {
            steps {
                sh """
                    # Need to use sudo with docker
                    CURRENT_SHA=\$(sudo docker pull "${IMAGE}" | grep "Digest:" | awk '{print \$2}')
                    echo "Current SHA: \$CURRENT_SHA"
                    
                    # Make sure file exists before reading
                    if [ -f "${LAST_SHA_FILE}" ]; then
                        LAST_SHA=\$(cat "${LAST_SHA_FILE}")
                        if [ "\$CURRENT_SHA" != "\$LAST_SHA" ]; then
                            echo "Image has changed, updating ${LAST_SHA_FILE}"
                            echo "\$CURRENT_SHA" > "${LAST_SHA_FILE}"                             
                        else
                            echo "Image has not changed, no update needed"
                            echo "stop" > stop.flag
                            exit 0
                        fi
                    else
                        echo "LAST_SHA_FILE does not exist, creating it"
                        echo "\$CURRENT_SHA" > "${LAST_SHA_FILE}"
                    fi
                """
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
                    sh """
                        aws configure set aws_access_key_id ${Access_Key_ID_Bynat_AWS}
                        aws configure set aws_secret_access_key ${Secret_Access_Key_Bynat_AWS}
                        aws configure set default.region ${Region}
                        
                        # Check if cloudformation file exists
                        if [ -f "${CLOUD_FORMATION}" ]; then
                            aws cloudformation update-stack --stack-name ${STACK_NAME} --template-body file://${CLOUD_FORMATION}
                        else
                            echo "Error: CloudFormation template not found at ${CLOUD_FORMATION}"
                            exit 1
                        fi
                    """
                } 
            }
        }
    }

    post {
        always {
            cleanWs()
        }
    }

    post {
        always {
            cleanWs()
        }
    }
}