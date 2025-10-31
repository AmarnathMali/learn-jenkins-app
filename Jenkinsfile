pipeline {
    agent any

    environment {
        APP_VERSION = '1.0.$BUILD_NUMBER'
        APP_NAME = 'myjenkinsapp'
        AWS_DEFAULT_REGION = 'us-east-1'
        AWS_ECS_CLUSTER = 'learnJenkinsApp-Cluster-Prod'
        AWS_ECS_SERVICE = 'learnJenkinsApp-Service-Prod'
        AWS_ECS_TASK_DEFINITION = 'learnJenkinsApp-TaskDefination-Prod'
    }

    stages {

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

        stage("Build-Docker-image") {
            agent{
                docker{
                    image 'my-aws-cli'
                    reuseNode true
                    args "-u root -v /var/run/docker.sock:/var/run/docker.sock --entrypoint=''"
                }
            }
            
            steps {
                sh '''
                    docker version  # sanity check
                    docker build -t $APP_NAME:$APP_VERSION .
                '''
            }
        }

        stage('Deploy to AWS') {
            agent{
                docker{
                    image 'my-aws-cli'
                    reuseNode true
                    args "-u root --entrypoint=''"
                }
            }
            
            steps {
                withCredentials([usernamePassword(credentialsId: 'aws-s3', passwordVariable: 'AWS_SECRET_ACCESS_KEY', usernameVariable: 'AWS_ACCESS_KEY_ID')]) {
                    sh '''
                        aws --version
                        LATEST_TASK_REVISION=$(aws ecs register-task-definition --cli-input-json file://aws/task-defination-prod.json | jq '.taskDefinition.revision')
                        aws ecs update-service --cluster $AWS_ECS_CLUSTER --service $AWS_ECS_SERVICE --task-definition $AWS_ECS_TASK_DEFINITION:$LATEST_TASK_REVISION
                        aws ecs wait services-stable --cluster $AWS_ECS_CLUSTER --services $AWS_ECS_SERVICE
                    '''                    
                }
                
            }
        }
    }   
}
