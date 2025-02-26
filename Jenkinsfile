pipeline {
    agent any
    
    stages {
        stage('Checkout') {
            steps {
                // Checkout the code from GitHub
                checkout scm
                
                // Print the current branch for debugging
                sh 'echo "Building branch: $(git rev-parse --abbrev-ref HEAD)"'
            }
        }
        
        stage('Build Docker Image') {
            steps {
                // Create the Docker image with Apache
                sh '''
                docker build -t apache-website:latest -f Dockerfile .
                '''
            }
        }
        
        stage('Deploy') {
            steps {
                script {
                    def branchName = sh(script: 'git rev-parse --abbrev-ref HEAD', returnStdout: true).trim()
                    
                    if (branchName == 'master') {
                        echo "Deploying to production (master branch)"
                        
                        sh '''
                        # Stop any existing master containers
                        docker stop apache-master || true
                        docker rm apache-master || true
                        
                        # Start the new container with the website mounted
                        docker run -d --name apache-master -p 82:82 -v "$(pwd)":/var/www/html apache-website:latest
                        
                        echo "Website deployed and available at port 82"
                        '''
                    } else if (branchName == 'develop') {
                        echo "Building only (develop branch)"
                    }
                }
            }
        }
    }
    
    post {
        success {
            echo "Pipeline executed successfully!"
        }
        failure {
            echo "Pipeline failed!"
        }
    }
}