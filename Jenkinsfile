pipeline {
    agent any

    environment {
        APP_VERSION = '1.0.$BUILD_NUMBER'
    }

    stages {
        
        
        stage('DePloy to AWS') {
            agent{
                docker{
                    image 'amazon/aws-cli'
                    reuseNode true
                    args "--entrypoint=''"
                }
            }
            
            steps {
                withCredentials([usernamePassword(credentialsId: 'aws-s3', passwordVariable: 'AWS_SECRET_ACCESS_KEY', usernameVariable: 'AWS_ACCESS_KEY_ID')]) {
                    sh '''
                        aws --version
                        aws ecs register-task-definition --cli-input-json file://aws/task-defination-prod.json
                    '''                    
                }
                
            }
        }
        
        stage('Build') {
            agent {
                docker {
                    image 'node:18-alpine'
                    reuseNode true
                }
            }
            steps {
                sh '''
                    echo 'small changes'
                    ls -la
                    node --version
                    npm --version
                    npm ci
                    npm run build
                    ls -la
                '''
            }
        }

        
 
 
       
        
    }

    
}
