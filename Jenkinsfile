
def microservices = ['ecomm-cart','ecomm-order','ecomm-product','ecomm-web']
def frontendservice = ['ecomm-ui']
def services = microservices + frontendservice
def deployenv = ''
if (env.BRANCH_NAME == 'test') {
    deployenv = 'test'
} else if (env.BRANCH_NAME == 'master') {
    deployenv = 'prod'
}

pipeline {
    agent any
    tools{
            maven 'maven'
        }

    environment {
        DOCKERHUB_USERNAME = "imenmettichi"
        SSH_CREDENTIALS_ID= "ec2sshkeyID"
        SCANNER_HOME = tool 'sonarqube'
        MASTER_NODE= "44.223.127.246"
    }

    stages {

        stage('Checkout') {
            steps {
                // Checkout the repository from GitHub
                checkout([
                    $class: 'GitSCM',
                    branches: [[name: env.BRANCH_NAME]], // Checkout the current branch
                    userRemoteConfigs: [[url: 'https://github.com/imen309/EOS.git']]
                ])
            }
        }
/*
        stage('Check Git Secrets') {
           when {
               expression { (env.BRANCH_NAME == 'dev') || (env.BRANCH_NAME == 'test') || (env.BRANCH_NAME == 'master') }
           }
           steps {
               sh 'docker run --rm -v "$PWD:/pwd" trufflesecurity/trufflehog:latest github --repo https://github.com/imen309/EOS.git > trufflehog.txt'
           }
        }

        stage('Source Composition Analysis') {
            when {
               expression { (env.BRANCH_NAME == 'dev') || (env.BRANCH_NAME == 'test') || (env.BRANCH_NAME == 'master') }
            }
            steps {
               script {
                   for (def service in services) {
                       dir(service) {
                           def reportFile = "dependency-check-report-${service}.html"
                           if (service in microservices) {
                               sh 'rm -f owasp-dependency-check.sh'
                               sh 'wget "https://raw.githubusercontent.com/imen309/EOS/test/owasp-dependency-check.sh"'
                               sh 'chmod +x owasp-dependency-check.sh'
                               sh "./owasp-dependency-check.sh"
                               sh "mv /var/lib/jenkins/OWASP-Dependency-Check/reports/dependency-check-report.html /var/lib/jenkins/OWASP-Dependency-Check/reports/${reportFile}"
                           }
                       }
                   }
               }
            }
        }

        stage('Maven Build') {
            when {
                expression { (env.BRANCH_NAME == 'dev') || (env.BRANCH_NAME == 'test') || (env.BRANCH_NAME == 'master') }
            }
            steps {
                script {
                    for (def service in microservices) {
                        dir(service) {
                            sh 'mvn clean install'
                        }
                    }
                }
            }
        }

        stage('Unit Test') {
            when {
                expression { (env.BRANCH_NAME == 'dev') || (env.BRANCH_NAME == 'test') || (env.BRANCH_NAME == 'master') }
            }
            steps {
                script {
                    for (def service in microservices) {
                        dir(service) {
                            sh 'mvn test'
                        }
                    }
                }
            }
        }

        stage('SonarQube Analysis') {
           when {
               expression { (env.BRANCH_NAME == 'dev') || (env.BRANCH_NAME == 'test') || (env.BRANCH_NAME == 'master') }
           }
           steps {
               script {
                  for (def service in microservices) {
                     dir(service) {
                        withSonarQubeEnv('sonarqube') {
                            sh 'mvn clean package sonar:sonar'
                        }
                     }
                  }
               }
           }
        }

        stage('Docker Login') {
            when {
                expression { (env.BRANCH_NAME == 'dev') || (env.BRANCH_NAME == 'test') || (env.BRANCH_NAME == 'master') }
            }
            steps {
                script {
                    // Log into Docker Hub using Jenkins credentials
                    withCredentials([usernamePassword(credentialsId: 'DockerHubID', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                        sh "docker login -u $DOCKER_USERNAME -p $DOCKER_PASSWORD"
                    }
                }
            }
        }

        stage('Docker Build') {
            when {
                expression { (env.BRANCH_NAME == 'dev') || (env.BRANCH_NAME == 'test') || (env.BRANCH_NAME == 'master') }
            }
            steps {
                script {
                    for (def service in services) {
                        dir(service) {
                            if (env.BRANCH_NAME == 'test') {
                                sh "docker build -t ${DOCKERHUB_USERNAME}/${service}_test:latest ."
                            } else if (env.BRANCH_NAME == 'master') {
                                sh "docker build -t ${DOCKERHUB_USERNAME}/${service}_prod:latest ."
                            } else if (env.BRANCH_NAME == 'dev') {
                                sh "docker build -t ${DOCKERHUB_USERNAME}/${service}_dev:latest ."
                            }
                        }
                    }
                }
            }
        }

        stage('Trivy Image Scan') {
            when {
                expression { (env.BRANCH_NAME == 'dev') || (env.BRANCH_NAME == 'test') || (env.BRANCH_NAME == 'master') }
            }
            steps {
                script {
                    for (def service in services) {
                        def trivyReportFile = "trivy-${service}.txt"
                        if (env.BRANCH_NAME == 'test') {
                            sh "trivy --timeout 15m image ${DOCKERHUB_USERNAME}/${service}_test:latest > ${trivyReportFile}"
                        } else if (env.BRANCH_NAME == 'master') {
                            sh "trivy --timeout 15m image ${DOCKERHUB_USERNAME}/${service}_prod:latest > ${trivyReportFile}"
                        } else if (env.BRANCH_NAME == 'dev') {
                            sh "trivy --timeout 15m image ${DOCKERHUB_USERNAME}/${service}_dev:latest > ${trivyReportFile}"
                        }
                    }
                }
            }
        }

        stage('Docker Push') {
            when {
                expression { (env.BRANCH_NAME == 'dev') || (env.BRANCH_NAME == 'test') || (env.BRANCH_NAME == 'master') }
            }
            steps {
                script {
                    for (def service in services) {
                        if (env.BRANCH_NAME == 'test') {
                            sh "docker push ${DOCKERHUB_USERNAME}/${service}_test:latest"
                            sh "docker rmi -f ${DOCKERHUB_USERNAME}/${service}_test:latest"
                        } else if (env.BRANCH_NAME == 'master') {
                            sh "docker push ${DOCKERHUB_USERNAME}/${service}_prod:latest"
                            sh "docker rmi -f ${DOCKERHUB_USERNAME}/${service}_prod:latest"
                        } else if (env.BRANCH_NAME == 'dev') {
                            sh "docker push ${DOCKERHUB_USERNAME}/${service}_dev:latest"
                            sh "docker rmi -f ${DOCKERHUB_USERNAME}/${service}_dev:latest"
                        }
                    }
                }
            }
        }
*/
         stage('Kube-bench Scan') {
             when {
               expression { (env.BRANCH_NAME == 'test') || (env.BRANCH_NAME == 'master') }
             }
             steps {
                sshagent(credentials: [env.SSH_CREDENTIALS_ID]) {
                  sh " [ -d ~/.ssh ] || mkdir ~/.ssh && chmod 0700 ~/.ssh "
                  sh " ssh-keyscan -t rsa,dsa ${MASTER_NODE} >> ~/.ssh/known_hosts "
                  sh "ssh ubuntu@$MASTER_NODE 'sudo kube-bench > kubebench_CIS_${env.BRANCH_NAME}.txt'"
                  sh "ssh ubuntu@$MASTER_NODE cat kubebench_CIS_${env.BRANCH_NAME}.txt"
                }
             }
         }

         stage('Kubescape Scan') {
            when {
              expression { (env.BRANCH_NAME == 'test') || (env.BRANCH_NAME == 'master') }
            }
            steps {
               sshagent(credentials: [env.SSH_CREDENTIALS_ID]) {
                 sh " [ -d ~/.ssh ] || mkdir ~/.ssh && chmod 0700 ~/.ssh "
                 sh " ssh-keyscan -t rsa,dsa ${MASTER_NODE} >> ~/.ssh/known_hosts "
                 sh "ssh ubuntu@$MASTER_NODE 'sudo kubescape scan framework mitre > kubescape_mitre_${env.BRANCH_NAME}.txt'"
                 sh "ssh ubuntu@$MASTER_NODE cat kubescape_mitre_${env.BRANCH_NAME}.txt"
               }
            }
         }

         stage('Get YAML Files') {
             when {
                 expression { (env.BRANCH_NAME == 'test') || (env.BRANCH_NAME == 'master') }
             }
             steps {
                 sshagent(credentials: [env.SSH_CREDENTIALS_ID]) {
                     script {
                         sh "wget \"https://raw.githubusercontent.com/imen309/EOS/test/deploy_to_${deployenv}.sh\""
                         sh "[ -d ~/.ssh ] || mkdir ~/.ssh && chmod 0700 ~/.ssh "
                         sh "ssh-keyscan -t rsa,dsa ${MASTER_NODE} >> ~/.ssh/known_hosts "
                         sh "scp deploy_to_${deployenv}.sh ubuntu@$MASTER_NODE:~"
                         sh "ssh ubuntu@$MASTER_NODE chmod +x deploy_to_${deployenv}.sh"
                         sh "ssh ubuntu@$MASTER_NODE ./deploy_to_${deployenv}.sh"
                     }
                 }
             }
         }

         stage('Scan YAML Files') {
             when {
                expression { (env.BRANCH_NAME == 'test') || (env.BRANCH_NAME == 'master') }
             }
             steps {
                sshagent(credentials: [env.SSH_CREDENTIALS_ID]) {
                    script {
                        sh " [ -d ~/.ssh ] || mkdir ~/.ssh && chmod 0700 ~/.ssh "
                        sh " ssh-keyscan -t rsa,dsa ${MASTER_NODE} >> ~/.ssh/known_hosts "
                        sh "ssh ubuntu@$MASTER_NODE rm -f kubescape_infrastructure_${deployenv}.txt"
                        sh "ssh ubuntu@$MASTER_NODE rm -f kubescape_microservices_${deployenv}.txt"
                        sh "ssh ubuntu@$MASTER_NODE 'sudo kubescape scan ${deployenv}_manifests/infrastructure/*.yml -v > kubescape_infrastructure_${deployenv}.txt'"
                        sh "ssh ubuntu@$MASTER_NODE cat kubescape_infrastructure_${deployenv}.txt"
                        sh "ssh ubuntu@$MASTER_NODE 'sudo kubescape scan ${deployenv}_manifests/microservices/*.yml -v > kubescape_microservices_${deployenv}.txt'"
                        sh "ssh ubuntu@$MASTER_NODE cat kubescape_microservices_${deployenv}.txt"
                    }
                }
             }
         }

         stage('Deploy to Kubernetes') {
              when {
                 expression { (env.BRANCH_NAME == 'test') || (env.BRANCH_NAME == 'master') }
              }
              steps {
                 sshagent(credentials: [env.SSH_CREDENTIALS_ID]) {
                     script {
                         sh " [ -d ~/.ssh ] || mkdir ~/.ssh && chmod 0700 ~/.ssh "
                         sh " ssh-keyscan -t rsa,dsa ${MASTER_NODE} >> ~/.ssh/known_hosts "
                         sh "ssh ubuntu@$MASTER_NODE sudo kubectl apply -f ${deployenv}_manifests/namespace.yml"
                         sh "ssh ubuntu@$MASTER_NODE sudo kubectl apply -f ${deployenv}_manifests/infrastructure/"
                         for (service in services) {
                              sh "ssh ubuntu@$MASTER_NODE sudo kubectl apply -f ${deployenv}_manifests/microservices/${service}.yml"
                         }
                     }
                 }
              }
         }

         stage('Send reports to Slack') {
             when {
                 expression { (env.BRANCH_NAME == 'dev') || (env.BRANCH_NAME == 'test') || (env.BRANCH_NAME == 'master') }
             }
             steps {
                 slackUploadFile filePath: '**/trufflehog.txt',  initialComment: 'Check TruffleHog Reports!!'
                 slackUploadFile filePath: '**/trivy-*.txt', initialComment: 'Check Trivy Reports!!'
             }
           }
         }

         post {
             always {
                script {
                   if ((env.BRANCH_NAME == 'dev') || (env.BRANCH_NAME == 'test') || (env.BRANCH_NAME == 'master'))
                     archiveArtifacts artifacts: '**/trufflehog.txt, **/trivy-*.txt'
                }
             }
         }


}

