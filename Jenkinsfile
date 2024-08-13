@Library('my-shared-library@main') _

pipeline{

    agent any

    parameters{
        choice(name: 'action', choices: 'create\ndelete', description: 'Choose create/Destroy')
        string(name: 'ImageName', description: 'name of the docker build', defaultValue: 'ci-cd-app')
        string(name: 'ImageTag', description: 'tag of the docker build', defaultValue: 'v1')
        string(name: 'DockerHubUser', description: 'name of the application', defaultValue: 'isebastienstore')
    }

    stages{
        stage('git Checkout'){
        when { expression {  params.action == 'create' } }
            steps{
                script{
                    gitCheckout(
                        branch: "main",
                        url: "https://github.com/isebastienstore/simple-ci-cd-app.git"
                    )
                }
            }
        }
        stage('clean'){
        when { expression {  params.action == 'create' } }
            steps{
                script{
                    clean()
                }
            }
        }
        stage('checkstyle'){
            when { expression {  params.action == 'create' } }
            steps{
                script{
                    checkstyle()
                }
            }
        }

        stage('integration test maven'){
            when { expression {  params.action == 'create' } }
            steps{
                script{
                    mvnIntegrationTest()
                }
            }
        }

        stage('Static code analysis: Sonarqube'){
            when { expression {  params.action == 'create' } }
            steps{
                script{
                    def SonarQubecredentialsId = 'sonar-token'
                    statiCodeAnalysis(SonarQubecredentialsId)
                }
            }
        }

        stage('Quality Gate Status Check : Sonarqube'){
            when { expression {  params.action == 'create' } }
            steps{
                script{
                    def SonarQubecredentialsId = 'sonar-token'
                    QualityGateStatus(SonarQubecredentialsId)
                }
            }
        }

        stage('Maven Build : maven'){
            when { expression {  params.action == 'create' } }
            steps{
                script{
                    mvnBuild()
                }
            }
        }

        stage('Docker image build: ECR'){
            when { expression { params.action == 'create' } }
            steps{
                script{
                    dockerBuild("${params.aws_account_id}", "${params.Region}", "${params.ECR_REPO_NAME}")
                }
            }
        }

        stage('Docker image scan: trivy'){
            when{ expression { params.action == 'create'} }
            steps{
                script{
                    dockerImageScan("${params.aws_account_id}", "${params.Region}", "${params.ECR_REPO_NAME}")
                }
            }
        }

        stage('Docker image push: ECR'){
            when{ expression { params.action == 'create'} }
            steps{
                script{
                    dockerImagePush("${params.aws_account_id}", "${params.Region}", "${params.ECR_REPO_NAME}")
                }
            }
        }

        stage('Docker image cleanup: ECR'){
            when{ expression { params.action == 'create'} }
            steps{
                script{
                    dockerImageCleanup("${params.aws_account_id}", "${params.Region}", "${params.ECR_REPO_NAME}")
                }
            }
        }
