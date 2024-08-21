@Library('my-shared-library@main') _

pipeline{

    agent any

    parameters{
        choice(name: 'action', choices: 'create\ndelete', description: 'Choose create/Destroy')
        string(name: 'aws_account_id', description: 'AWS Account ID', defaultValue: '211125402309')
        string(name: 'Region', description: 'Region of ECR', defaultValue: 'eu-west-3')
        string(name: 'ECR_REPO_NAME', description: 'name of the ECR', defaultValue: 'isebastienstore')
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
    }
}
