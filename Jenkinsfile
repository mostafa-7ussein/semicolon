pipeline {
    agent any
    environment {
        
        AWS_ACCESS_KEY_ID = credentials('aws_access_key_id') 
        AWS_SECRET_ACCESS_KEY = credentials('aws_secret_access_key') 
    }
    stages {
        stage('Preparation') {
            steps {
                script {
                    slackSend(channel: 'devops', message: "Starting the pipeline for ${env.JOB_NAME} - Build Number: ${env.BUILD_NUMBER}")
                }
                
                git(
                    url: 'https://github.com/mostafa-7ussein/semicolon',
                    branch: 'main'
                )
            }
        }
        stage('Test') {
            steps {
                echo "Running Docker Compose tests"
                sh "docker compose -f docker-compose-testing.yml down --remove-orphans"
                sh "docker compose -f docker-compose-testing.yml up -d --build"
            }
        }
        stage('Build and Push Docker Image') {
            steps {
                script {
                    def imageTag = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()
                    def imageName = "mostafahu/semicolon-backend:${imageTag}"
                    
                    sh "docker build . -t ${imageName}"

                    def imageExists = sh(script: "docker manifest inspect ${imageName}", returnStatus: true)

                    // Use Jenkins credentials for Docker Hub login
                    withCredentials([usernamePassword(credentialsId: 'DockerHub', passwordVariable: 'PASSWORD', usernameVariable: 'USERNAME')]) {
                        if (imageExists != 0) {
                            // Log in to Docker Hub
                            sh 'echo $PASSWORD | docker login -u $USERNAME --password-stdin'

                            // Push Docker image to Docker Hub
                            sh "docker push ${imageName}"

                            // Tag as 'latest' and push
                            sh "docker tag ${imageName} mostafahu/semicolon-backend:latest"
                            sh "docker push mostafahu/semicolon-backend:latest"

                            echo "Docker image ${imageName} pushed successfully."
                        } else {
                            echo "No changes detected, Docker image ${imageName} already exists. Skipping push."
                        }
                    }
                }
            }
        } 
        stage('Provision Infrastructure') {
            steps {
                script {
                    withEnv(["TF_VAR_aws_access_key=${AWS_ACCESS_KEY_ID}", "TF_VAR_aws_secret_key=${AWS_SECRET_ACCESS_KEY}"]) {                        
                        echo "Provisioning infrastructure with Terraform"
                        sshagent(['ssh-credentials-id']) {
                            try {
                                sh 'cd terraform && terraform init'
                                sh 'cd terraform && terraform apply -auto-approve'
                            } catch (Exception e) {
                                echo "Terraform command failed: ${e.message}"
                                currentBuild.result = 'FAILURE'
                                error("Aborting pipeline due to Terraform failure.")
                            }
                        }
                    }
                }
            }
        }
        stage('Get Public IP') {
            steps {
                script {
                    def publicIP = sh(script: 'cd terraform && terraform output -json ec2_public_ip', returnStdout: true).trim()
                    echo "Public IP Address: ${publicIP}"
                    env.PUBLIC_IP = publicIP
                }
            }
        }
        stage('Run Ansible Playbook') {
            steps {
                

                script {
                      withCredentials([sshUserPrivateKey(credentialsId: 'ssh-credentials-id', keyFileVariable: 'SSH_KEY')]) {
                // Run Ansible playbook, using the public IP
                        sh "ansible-playbook -i ${env.PUBLIC_IP}, semi-colon.yml --extra-vars 'target_host=${env.PUBLIC_IP}' --user ubuntu --private-key $SSH_KEY -e \"ansible_ssh_common_args='-o StrictHostKeyChecking=no'\""
            }
        }
            }
        }
    }
    post {
        success {
            script {
                slackSend(channel: '#devops', color: '#00FF00', message: "Succeeded  ${env.JOB_NAME} - Build Number: ${env.BUILD_NUMBER} succeeded!")
            }
        }
        failure {
            script {
                slackSend(channel: '#devops', message: "Pipeline ${env.JOB_NAME} - Build Number: ${env.BUILD_NUMBER} failed!")
            }
        }
        always {
            script {
                slackSend(channel: '#devops', color: '#FF0000', message: "Finished: ${env.JOB_NAME} - Build Number: ${env.BUILD_NUMBER}.")
            }
        }
    }
}
