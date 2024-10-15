pipeline {
    agent any
    stages {
        stage('Preparation') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'git-credentials-id', usernameVariable: 'GIT_USERNAME', passwordVariable: 'GIT_PASSWORD')]) {
                    sh 'git clone https://github.com/mostafa-7ussein/semicolonProject'
                }
            }
        }
        stage('Build Docker Image') {
            steps {
                // Log in to Docker Hub using credentials
                withCredentials([usernamePassword(credentialsId: 'DockerHub', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
                    // Log in to Docker Hub
                    sh 'echo $PASSWORD | docker login -u $USERNAME --password-stdin'
                    
                    // Build Docker image
                    sh 'docker build . -t mostafahu/semicolon-backend'
                    
                    // Push Docker image to Docker Hub
                    sh 'docker push mostafahu/semicolon-backend'
                }
            }
        }
                stage('Run Tests') {
            steps {
                echo "Running tests using Docker Compose"
                sh "docker-compose -f docker-compose-testing.yml down --remove-orphans"
                sh "docker-compose -f docker-compose-testing.yml up -d --build"
            }
        }
    }
}
