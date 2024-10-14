pipeline {
    agent any
    stages {
        stage('preparation') {
            steps {
                // Clone the repository
                git(
                    url: 'https://github.com/Bahnasy2001/semi-colon-pipeline.git',
                    branch: 'main'
                )
            }
        }
        stage('ci') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
                    // Build Docker image
                    sh 'docker build . -t hassanbahnasy/semi-colon'
                    
                    // Log in to Docker Hub
                    sh 'echo $PASSWORD | docker login -u $USERNAME --password-stdin'
                    
                    // Push Docker image to Docker Hub
                    sh 'docker push hassanbahnasy/semi-colon'
                }
            }
        }
        stage('cd') {
            steps {
                echo "cd"
                sh "docker compose -f docker-compose.yml down --remove-orphans"
                sh "docker compose -f docker-compose.yml up -d --build"
            }
        }
    }
    post {
        success {
            slackSend(channel: "depi", color: '#00FF00', message: "Succeeded: Job '${env.JOB_NAME} ${env.BUILD_NUMBER}'")
        }
        failure {
            slackSend(channel: "depi", color: '#FF0000', message: "Failed: Job '${env.JOB_NAME} ${env.BUILD_NUMBER}'")
        }
    }
}