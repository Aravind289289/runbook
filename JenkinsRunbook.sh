Runbook Title: CI/CD Jenkins Pipeline Deployment

Last Updated: [Date]

Author: [Your Name]

Purpose: This runbook provides detailed instructions for deploying applications using Jenkins CI/CD pipelines. It includes setup, triggering builds, handling failures, and rolling back deployments.

Table of Contents
Prerequisites
Jenkins Setup
Pipeline Configuration
Triggering a Build
Monitoring Builds
Handling Build Failures
Rolling Back Deployments
Common Issues and Troubleshooting
References
1. Prerequisites
Access to Jenkins server with appropriate permissions.
Jenkins installed and configured with necessary plugins (e.g., Git, Docker, Pipeline).
Source code repository set up (e.g., GitHub, Bitbucket).
Application artifacts and Docker images should be available in the relevant repositories.
2. Jenkins Setup
Log in to Jenkins:

Open your web browser and navigate to http://<your-jenkins-url>.
Enter your username and password.
Configure Global Tools:

Navigate to Manage Jenkins > Global Tool Configuration.
Set up JDK, Git, and Maven installations as necessary.
Install Necessary Plugins:

Go to Manage Jenkins > Manage Plugins.
Ensure the following plugins are installed:
Git Plugin
Pipeline Plugin
Docker Pipeline
Slack Notification (if using Slack)
3. Pipeline Configuration
Create a New Pipeline:

Click on New Item.
Enter a name for your pipeline and select Pipeline.
Click OK.
Pipeline Definition:

Under Pipeline section, choose Pipeline script or Pipeline script from SCM.
If using SCM, provide the repository URL and credentials.
Sample Jenkinsfile: Here’s an example Jenkinsfile for a basic CI/CD pipeline:

groovy
Copy code
pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                git 'https://github.com/your-repo.git'
            }
        }
        stage('Build') {
            steps {
                sh 'mvn clean package'
            }
        }
        stage('Test') {
            steps {
                sh 'mvn test'
            }
        }
        stage('Build Docker Image') {
            steps {
                script {
                    def app = docker.build("your-image:${env.BUILD_ID}")
                }
            }
        }
        stage('Deploy to Staging') {
            steps {
                script {
                    docker.withServer('tcp://your-docker-host:2376') {
                        app.deploy()
                    }
                }
            }
        }
    }
    post {
        success {
            slackSend(channel: '#your-channel', message: "Build ${env.BUILD_ID} succeeded!")
        }
        failure {
            slackSend(channel: '#your-channel', message: "Build ${env.BUILD_ID} failed!")
        }
    }
}
4. Triggering a Build
Manual Trigger:

Navigate to the pipeline job.
Click Build Now.
Automatic Trigger:

Set up webhooks in your source code repository (e.g., GitHub) to trigger a build on push.
Go to your GitHub repository > Settings > Webhooks > Add webhook.
Set the payload URL to http://<your-jenkins-url>/github-webhook/ and select the events you want to trigger the build.
5. Monitoring Builds
Monitor build progress on the Jenkins dashboard.
View console output by clicking on the build number in the job view.
Check for build artifacts in the Workspace or configured storage.
6. Handling Build Failures
Identify Failure:

Review the console output for error messages.
Take note of any specific error codes or logs.
Common Steps to Resolve:

Fix code errors in the source repository.
Update dependencies in your pom.xml or package.json.
Rerun the build after fixing the issues.
Notify Team:

Ensure that notifications are sent via Slack or email to inform the team about build failures.
7. Rolling Back Deployments
Identify the Last Stable Version:

Check the Jenkins build history for the last successful deployment.
Rollback Command:

If using Docker, you can revert to a previous image version:
bash
Copy code
docker tag your-image:previous_version your-image:latest
Redeploy:

Trigger the deployment stage in Jenkins to deploy the stable version.
8. Common Issues and Troubleshooting
Jenkins Not Starting: Check the Jenkins log files for errors and ensure sufficient system resources.
Plugin Issues: If a plugin fails, try updating or reinstalling it.
Network Issues: Ensure Jenkins can access external services (e.g., GitHub, Docker registry).
9. References
Jenkins Documentation
GitHub Webhooks Documentation
Docker Documentation

