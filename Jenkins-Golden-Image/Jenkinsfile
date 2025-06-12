pipeline {
    agent { label 'packer' }

    environment {
        AWS_ACCESS_KEY_ID     = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
    }

    stages {
        stage('Terraform') {
            steps {
                sh 'tar -cvf jenkinsrole.tar jenkins.yml roles'
                sh '/usr/local/bin/terraform init'
                sh '/usr/local/bin/terraform validate'
                // Make sure vars.tfvars contains: efs_id = "fs-0ca08ca27116ea4b5"
                sh '/usr/local/bin/terraform plan -var-file=vars.tfvars -out testplan'
                sh '/usr/local/bin/terraform apply -var-file=vars.tfvars -auto-approve'
            }
        }
        stage('trivy scan') {
            steps {
                script {
                    def amiId = sh(
                        script: "aws ec2 describe-images --owners self --region us-east-1 --query 'Images | sort_by(@, &CreationDate)[-1].ImageId' --output text",
                        returnStdout: true
                    ).trim()
                    echo "Latest AMI ID: ${amiId}"
                    sh "/usr/bin/trivy vm --scanners vuln ami:${amiId} --aws-region us-east-1"
                }
            }
        }
    }
}
