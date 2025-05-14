pipeline {
    agent any

    environment {
        Access_Key_ID_Bynat_AWS = credentials('Access-Key-ID-Bynat-AWS')
        Secret_Access_Key_Bynat_AWS = credentials('Secret-Access-Key-Bynat-AWS')
        Region_Bynat_AWS = credentials('Region-Bynat-Aws')
        ECS_ID_Bynat = credentials('ECS-ID-Bynat')
    }

    stages {
        stage('initialize') {
            steps {
                sh """
                    # Variables
                    # -----------------
                    FILE="/var/jenkins_home/shared/global_version.txt"
                    CLOUD_FORMATION="/var/jenkins_home/shared/cloudformation.yaml"
                    IMAGE="batel123d/static-web"
                    LAST_SHA="gibberish"
                    CHANGED="false"
                    STACK_NAME="batel-stack"
                    ECR_REPO="batel-repo"

                    # Stage Initialize
                    # -----------------
                    echo "Stage Initialize"
                    if [ ! -f "\$FILE" ]; then
                        LAST_SHA=\$(sudo docker pull "\$IMAGE" | grep "Digest:" | awk '{print \$2}')
                        echo "\$LAST_SHA" > "\$FILE"
                        echo "Created \$FILE with default value"
                    else
                        LAST_SHA=\$(cat "\$FILE")
                        echo "Read \$LAST_SHA from \$FILE"
                    fi

                    # Stage Get image sha
                    # -----------------
                    CURRENT_SHA=\$(sudo docker pull "\$IMAGE" | grep "Digest:" | awk '{print \$2}')
                    echo "Current SHA: \$CURRENT_SHA"
                    if [ "\$CURRENT_SHA" != "\$LAST_SHA" ]; then
                        echo "Image has changed, updating \$FILE"
                        echo "\$CURRENT_SHA" > "\$FILE"
                        LAST_SHA="\$CURRENT_SHA"
                        CHANGED="true"
                    else
                        echo "Image has not changed, no update needed"
                        CHANGED="false"
                    fi

                    # Stage CONNECT TO AWS
                    # -----------------
                    echo "Stage CONNECT TO AWS"
                    if [ "\$CHANGED" == "true" ]; then
                        aws configure set aws_access_key_id "$Access_Key_ID_Bynat_AWS"
                        aws configure set aws_secret_access_key "$Secret_Access_Key_Bynat_AWS"
                        aws configure set default.region "$Region_Bynat_AWS"
                    else
                        echo "Image has not changed, no update needed"
                    fi

                    # Stage Update ECR REPO
                    # -----------------
                    echo "Stage Update ECR REPO"
                    if [ "\$CHANGED" == "true" ]; then
                        aws ecr get-login-password | sudo docker login --username AWS --password-stdin "$ECS_ID_Bynat.dkr.ecr.$Region_Bynat_AWS.amazonaws.com"
                        sudo docker tag nginx:latest "$ECS_ID_Bynat.dkr.ecr.$Region_Bynat_AWS.amazonaws.com/\$ECR_REPO:batel-nginx"
                        sudo docker push "$ECS_ID_Bynat.dkr.ecr.$Region_Bynat_AWS.amazonaws.com/\$ECR_REPO:batel-nginx"
                    else
                        echo "Image has not changed, no update needed"
                    fi

                    # Stage Update CloudFormation
                    # -----------------
                    echo "Stage Update CloudFormation"
                    if [ "\$CHANGED" == "true" ]; then
                        aws cloudformation update-stack --stack-name "\$STACK_NAME" --template-body file://"\$CLOUD_FORMATION"
                    else
                        echo "Image has not changed, no update needed"
                    fi
                """
            }
        }
    }
}