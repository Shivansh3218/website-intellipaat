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
                        
                        # Create a directory for website content
                        mkdir -p website_content
                        
                        # Copy all website files to this directory
                        cp -r * website_content/ || true
                        
                        # Start the new container with the website mounted
                        docker run -d --name apache-master -p 82:80 -v "$(pwd)/website_content":/var/www/html apache-website:latest
                        
                        # Add an index.html file if it doesn't exist
                        if [ ! -f website_content/index.html ]; then
                            echo "<html><body><h1>Welcome to my website!</h1><p>This site is hosted on port 82</p></body></html>" > website_content/index.html
                        fi
                        
                        echo "Website deployed and available at http://$(curl -s ifconfig.me):82"
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