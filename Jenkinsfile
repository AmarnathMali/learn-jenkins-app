pipeline {
    agent any

    environment {
        NETLIFY_SITE_ID = '3f12b300-2dac-4701-b76f-6efe0297f2f2'
        NETLIFY_AUTH_TOKEN = credentials('netlify-token')
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
        
        stage('Run Tests') {
            parallel {
                stage('unit Test') {
                    agent {
                        docker {
                            image 'node:18-alpine'
                            reuseNode true
                        }
                    }

                    steps {
                        sh '''
                            #test -f build/index.html
                            npm test
                        '''
                    }
                    post {
                        always {
                            junit 'jest-results/junit.xml'
                        }
                    }
                }

                stage('E2E') {
                    agent {
                        docker {
                            image 'my-playwright-image'
                            reuseNode true
                        }
                    }

                    steps {
                        sh '''
                            
                            serve -s build &
                            sleep 10
                            npx playwright test --reporter=html
                        '''
                    }
                    post {
                        always {
                            publishHTML([allowMissing: false, alwaysLinkToLastBuild: false, keepAll: false, reportDir: 'playwright-report', reportFiles: 'index.html', reportName: 'Local E2E', reportTitles: '', useWrapperFileDirectly: true])
                        }
                    }    
                }
            }
        }
        
        stage('Deploy staging') {
            agent {
                docker {
                    image 'my-playwright-image'
                    reuseNode true
                }
            }
            environment {
                CI_ENVIRONMENT_URL = 'STAGING_URL_TO_BE_SET'
            }
            steps {
                sh '''
                    
                    netlify --version
                    echo "Deploying to Netlify site id: $NETLIFY_SITE_ID"
                    netlify status
                    netlify deploy --dir=build --json > deploy-report.json
                    CI_ENVIRONMENT_URL=$(node-jq -r '.deploy_url' deploy-report.json)
                    npx playwright test --reporter=html
                '''
            }
            post {
                always {
                    publishHTML([
                        allowMissing: false,
                        alwaysLinkToLastBuild: false,
                        icon: '',
                        keepAll: false,
                        reportDir: 'playwright-report',
                        reportFiles: 'index.html',
                        reportName: 'Staging E2E Report',
                        reportTitles: '',
                        useWrapperFileDirectly: true
                    ])
                }
            }
        }
        stage('Approval') {
            steps {
                timeout(time: 1, unit: 'MINUTES') {
                    input message: 'Ready to deploy to production?', ok: 'Deploy'
                }
                
            }
        }

        stage('Deploy Prod') {
            agent {
                docker {
                    image 'my-playwright-image'
                    reuseNode true
                }
            }
            environment {
                CI_ENVIRONMENT_URL = 'https://roaring-starlight-6adaf6.netlify.app'
            }
            steps {
                sh '''
                    
                    netlify --version
                    echo "Deploying to Netlify site id: $NETLIFY_SITE_ID"
                    netlify status
                    netlify deploy --dir=build --prod 
                    npx playwright test --reporter=html
                '''
            }
            post {
                always {
                    publishHTML([
                        allowMissing: false,
                        alwaysLinkToLastBuild: false,
                        icon: '',
                        keepAll: false,
                        reportDir: 'playwright-report',
                        reportFiles: 'index.html',
                        reportName: 'Prod E2E Report',
                        reportTitles: '',
                        useWrapperFileDirectly: true
                    ])
                }
            }
        }
        
    }

    
}
