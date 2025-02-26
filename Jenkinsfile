pipeline {
    agent any
    
    parameters {
        string(name: 'BRANCH', defaultValue: 'develop', description: 'Branch to build')
        booleanParam(name: 'DEPLOY', defaultValue: false, description: 'Deploy to production')
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout([$class: 'GitSCM', 
                    branches: [[name: "*/${params.BRANCH}"]], 
                    userRemoteConfigs: [[url: 'https://github.com/hshar/website.git']]])
            }
        }
        
        stage('Build Docker Image') {
            steps {
                sh 'docker build -t xyz-company/website:${params.BRANCH} .'
            }
        }
        
        stage('Deploy') {
            when {
                expression { return params.DEPLOY == true }
            }
            steps {
                // Deploy only if BRANCH is master and DEPLOY is true
                sh '''
                    # Stop and remove existing container if it exists
                    docker stop website-container || true
                    docker rm website-container || true
                    
                    # Run the container on port 82
                    docker run -d --name website-container -p 82:80 xyz-company/website:${params.BRANCH}
                    
                    # Copy website files to the container
                    docker cp ./ website-container:/var/www/html/
                    
                    echo "Website deployed successfully on port 82"
                '''
            }
        }
    }
    
    post {
        success {
            echo "Pipeline completed successfully!"
        }
        failure {
            echo "Pipeline failed!"
        }
    }
}