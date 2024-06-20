
def microservices = ['ecomm-cart','ecomm-order','ecomm-product','ecomm-web']
def frontEndService = ['ecomm-ui']
def services = microservices + frontEndService
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
        // Ensure Docker credentials are stored securely in Jenkins
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
                        script {
                            // Check each microservice for secrets
                            for (def service in services) {
                                dir(service) {
                                    // Run TruffleHog to check for secrets in the repository
                                    sh 'docker run --rm gesellix/trufflehog --json https://github.com/imen309/EOS.git > trufflehog.json'
                                    sh 'cat trufflehog.json' // Output the results
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
                    // Build each microservice using Maven
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

        stage('SonarQube Analysis and Dependency Check') {
          when {
            expression {
              (env.BRANCH_NAME == 'dev') || (env.BRANCH_NAME == 'test') || (env.BRANCH_NAME == 'master')
                }
               }
          steps {
            script {
               // Run unit tests for each microservice using Maven
                  for (def service in services) {
                     dir(service) {
                         withSonarQubeEnv('sonarqube') {
                            sh 'mvn sonar:sonar'
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
                    withCredentials([usernamePassword(credentialsId: 'dockerhub', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
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
                            // Scan each Docker image for vulnerabilities using Trivy
                            for (def service in services) {
                                def trivyReportFile = "trivy-${service}.txt"

                                // Combine vulnerability and severity filters for clarity and flexibility
                                def trivyScanArgs = "--scanners vuln --severiCRITICAL,HIGH,MEDIUM--timeout 30m"
                                if (env.BRANCH_NAME == 'test') {
                                    sh "docker run --rm -v /var/run/docker.sock:/var/run/docker.sock -v $PWD:/tmp/.cache/ aquasec/trivy image --scanners vuln --timeout 30m ${DOCKERHUB_USERNAME}/${service}_test:latest > ${trivyReportFile}"
                                } else if (env.BRANCH_NAME == 'master') {
                                    sh "docker run --rm -v /var/run/docker.sock:/var/run/docker.sock -v $PWD:/tmp/.cache/ aquasec/trivy image --scanners vuln --timeout 30m ${DOCKERHUB_USERNAME}/${service}_prod:latest > ${trivyReportFile}"
                                } else if (env.BRANCH_NAME == 'dev') {
                                    sh "docker run --rm -v /var/run/docker.sock:/var/run/docker.sock -v $PWD:/tmp/.cache/ aquasec/trivy image --scanners vuln --timeout 30m ${DOCKERHUB_USERNAME}/${service}_dev:latest > ${trivyReportFile}"
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
                    // Push each Docker image to Docker Hub based on the branch
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



         stage('Kube-bench Scan') {
             when {
               expression { (env.BRANCH_NAME == 'test') || (env.BRANCH_NAME == 'master') }
             }
             steps {
               sshagent(credentials: [env.SSH_CREDENTIALS_ID]) {
                 sh " [ -d ~/.ssh ] || mkdir ~/.ssh && chmod 0700 ~/.ssh "
                 sh " ssh-keyscan -t rsa,dsa ${MASTER_NODE} >> ~/.ssh/known_hosts "
                 sh "ssh ubuntu@$MASTER_NODE 'sudo kube-bench > kubebench_CIS_${env.BRANCH_NAME}.txt'"
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
                         sh "curl -o deploy_to_${deployenv}.sh \"https://raw.githubusercontent.com/imen309/EOS/test/deploy_to_${deployenv}.sh\""
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
                        sh "ssh ubuntu@$MASTER_NODE 'sudo kubescape scan ${deployenv}_manifests/infrastructure/*.yml > kubescape_infrastructure_${deployenv}.txt'"
                        sh "ssh ubuntu@$MASTER_NODE 'sudo kubescape scan ${deployenv}_manifests/microservices/*.yml > kubescape_microservices_${deployenv}.txt'"
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




*/


}

