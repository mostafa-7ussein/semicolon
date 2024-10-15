pipeline {
    agent any


    stages {
        stage('preparation') {
            steps {
                // Clone the repository
                git(
                    url: 'https://github.com/mostafa-7ussein/semicolonProject',
                    branch: 'main'
                )
            }
        }
     