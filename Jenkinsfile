pipeline {
    agent any
    stages {
        stage('Preparation') {
            steps {
                    sh 'git clone https://github.com/mostafa-7ussein/semicolonProject'
                }
            }
        stage('test') {
            steps {
                echo "docker compose"
                sh "docker compose -f docker-compose-testing.yml down --remove-orphans"
                sh "docker compose -f docker-compose-testing.yml up -d --build"
            }
        }        
        stage('Build and Push Docker Image') {
            steps {
                script {
                    // Define the image name and tag using Git commit hash or a timestamp
                    def imageTag = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()
                    def imageName = "mostafahu/semicolon-backend:${imageTag}"
                    
                    // Build the Docker image
                    sh "docker build . -t ${imageName}"

                    // Check if the image already exists on Docker Hub
                    def imageExists = sh(script: "docker manifest inspect ${imageName}", returnStatus: true)

                    if (imageExists != 0) {
                        // Log in to Docker Hub
                        sh 'echo $PASSWORD | docker login -u $USERNAME --password-stdin'

                        // Push Docker image to Docker Hub
                        sh "docker push ${imageName}"

                        // Optionally, tag as 'latest' and push
                        sh "docker tag ${imageName} hassanbahnasy/semi-colon:latest"
                        sh "docker push hassanbahnasy/semi-colon:latest"

                        echo "Docker image ${imageName} pushed successfully."
                    } else {
                        echo "No changes detected, Docker image ${imageName} already exists. Skipping push."
                    }
                }
            }
        }
   
    }
}
