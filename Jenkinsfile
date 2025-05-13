pipeline {
    agent any

    stages {
        stage('Get Image Digest') {
            steps {
                sh '''
                    IMAGE="batel123d/static-web"
                    DIGEST=$(docker pull "$IMAGE" | grep "Digest:" | awk '{print $2}')
                    echo "Digest is: $DIGEST"
                '''
            }
        }
    }
}
