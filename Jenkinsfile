pipeline {
    agent any
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        
        stage('Deploy to Apache') {
            steps {
                script {
                    // Remove existing content in Apache document root
                    sh 'sudo rm -rf /var/www/html/*'
                    
                    // Copy new website files to Apache document root
                    sh 'sudo cp -R ${WORKSPACE}/* /var/www/html/'
                    
                    // Set correct permissions
                    sh 'sudo chown -R www-data:www-data /var/www/html'
                    sh 'sudo chmod -R 755 /var/www/html'
                }
            }
        }
        
        stage('Restart Apache') {
            steps {
                sh 'sudo systemctl restart apache2'
            }
        }
    }
    
    post {
        failure {
            echo 'Deployment failed. Reverting changes.'
            // Optional: Add rollback steps if needed
        }
    }
}