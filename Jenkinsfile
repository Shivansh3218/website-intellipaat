pipeline {
    agent any
    
    environment {
        DOCKER_IMAGE = "abode-website"
        DOCKER_TAG = "${BUILD_NUMBER}"
    }
    
    options {
        buildDiscarder(logRotator(numToKeepStr: '10'))
        timeout(time: 30, unit: 'MINUTES')
        timestamps()
    }
    
    stages {
        stage('Checkout') {
            steps {
                echo "🔄 Checking out code from ${env.BRANCH_NAME} branch..."
                checkout scm
                script {
                    env.GIT_COMMIT_SHORT = sh(
                        script: 'git rev-parse --short HEAD',
                        returnStdout: true
                    ).trim()
                }
            }
        }
        
        stage('Build') {
            steps {
                echo "🔨 Building Docker image for commit ${env.GIT_COMMIT_SHORT}..."
                script {
                    def image = docker.build("${DOCKER_IMAGE}:${DOCKER_TAG}")
                    image.tag("latest")
                    image.tag("${env.GIT_COMMIT_SHORT}")
                }
            }
        }
        
        stage('Test') {
            steps {
                echo "🧪 Running comprehensive tests..."
                script {
                    sh '''
                        echo "Starting test container..."
                        docker run -d --name test-container-${BUILD_NUMBER} -p 809${BUILD_NUMBER}:80 ${DOCKER_IMAGE}:${DOCKER_TAG}
                        
                        sleep 15
                        
                        echo "Running health checks..."
                        response=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:809${BUILD_NUMBER})
                        if [ $response -eq 200 ]; then
                            echo "✅ HTTP health check passed (Status: $response)"
                        else
                            echo "❌ HTTP health check failed (Status: $response)"
                            docker logs test-container-${BUILD_NUMBER}
                            exit 1
                        fi
                        
                        content=$(curl -s http://localhost:809${BUILD_NUMBER})
                        if [[ $content == *"<html"* ]] || [[ $content == *"<HTML"* ]]; then
                            echo "✅ HTML content test passed"
                        else
                            echo "❌ HTML content test failed"
                            echo "Received content: $content"
                            exit 1
                        fi
                        
                        echo "✅ All tests passed!"
                    '''
                }
            }
            post {
                always {
                    sh '''
                        docker stop test-container-${BUILD_NUMBER} || true
                        docker rm test-container-${BUILD_NUMBER} || true
                    '''
                }
            }
        }
        
        stage('Deploy to Dev') {
            when {
                branch 'develop'
            }
            steps {
                echo "🚀 Deploying to Development environment..."
                script {
                    sh '''
                        echo "Stopping existing dev container..."
                        docker stop abode-website-dev || true
                        docker rm abode-website-dev || true
                        
                        echo "Starting new dev container..."
                        docker run -d \
                            --name abode-website-dev \
                            --restart unless-stopped \
                            -p 8081:80 \
                            ${DOCKER_IMAGE}:${DOCKER_TAG}
                        
                        sleep 10
                        
                        echo "Verifying deployment..."
                        curl -f http://localhost:8081 || exit 1
                        
                        echo "✅ Development deployment successful!"
                        echo "🌐 Dev site available at: http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):8081"
                    '''
                }
            }
        }
        
        stage('Deploy to Production') {
            when {
                branch 'master'
            }
            steps {
                input message: 'Deploy to Production?', ok: 'Deploy'
                echo "🚀 Deploying to Production environment..."
                script {
                    sh '''
                        echo "Stopping existing prod container..."
                        docker stop abode-website-prod || true
                        docker rm abode-website-prod || true
                        
                        echo "Starting new prod container..."
                        docker run -d \
                            --name abode-website-prod \
                            --restart unless-stopped \
                            -p 8082:80 \
                            ${DOCKER_IMAGE}:${DOCKER_TAG}
                        
                        sleep 10
                        
                        echo "Verifying deployment..."
                        curl -f http://localhost:8082 || exit 1
                        
                        echo "✅ Production deployment successful!"
                        echo "🌐 Prod site available at: http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):8082"
                    '''
                }
            }
        }
    }
    
    post {
        always {
            echo "🧹 Cleaning up Docker images..."
            sh '''
                docker images ${DOCKER_IMAGE} --format "table {{.Tag}}" | grep -E "^[0-9]+$" | sort -nr | tail -n +4 | xargs -r docker rmi ${DOCKER_IMAGE}: || true
                docker image prune -f
            '''
        }
        success {
            echo "✅ Pipeline completed successfully!"
        }
        failure {
            echo "❌ Pipeline failed!"
        }
    }
}
