pipeline {
    agent any
    stages {
        stage('Clone repo') {
            steps {
                git url: 'https://github.com/Izjmz/html-static-hosting.git', branch: 'master'
            }
        }
        stage('Health Check') {
            steps {
                sh 'curl -s http://50.16.22.74:9100/metrics | head -n 10 > health-check.log'
            }
        }
    }
    post {
        always {
            archiveArtifacts artifacts: 'health-check.log', allowEmptyArchive: true
        }
        failure {
            echo 'URGENT >> CHECK JENKINS LOG in /var/lib/jenkins/workspace/health-check>'
        }
    }
} 
