pipeline{
	agent any
	
	environment{
		AWS_REGION = 'ap-south-1'
		TF_VAR_db_password = credentials('taskapi-db-password')
	}

	stages{
		stage('Checkout'){
			steps{
				checkout scm				
			}
		}
	
		stage('Terraform Init & Plan'){
			steps{
				dir('terraform'){
					sh 'terraform init'
					sh 'terraform plan -out=tfplan'
				}
			}
		}
		
		stage('Terrafrom Apply'){
			steps{
				dir('terraform'){
					sh 'terraform apply -auto-approve tfplan'
				}
			}
		}

		stage('Build TaskApi'){
			steps{
				dir('TaskApi'){
					sh 'dotnet publish -c Release -o ../ansible/artifacts/taskapi-build'
				}
			}
		}

		stage('Build Migration Bundle'){
			steps{
				dir('TaskApi'){
					sh '''
						export PATH="$PATH:/var/lib/jenkins/.dotnet/tools"
						dotnet ef migrations bundle --self-contained -r linux-x64 -o ../ansible/artifacts/efbundle --force	
					'''
				}
			}
		}
			
		stage('Deploy via Ansible') {
			steps {
				withCredentials([
				    sshUserPrivateKey(credentialsId: 'taskapi-ec2-ssh-key', keyFileVariable: 'SSH_KEY'),	
				    string(credentialsId: 'taskapi-db-password', variable: 'DB_PASSWORD')		
				]) {
					dir('ansible') {			
						sh 'ansible-playbook -i inventory.ini site.yml --extra-vars "db_password=${DB_PASSWORD}"'	
					}
				}
			}
		}
	}


	post {
	success {
            echo "Deployment succeeded — TaskApi should now be live on the EC2 instance."
        }
        failure {
            echo "Pipeline failed — check the stage logs above for the specific error."
        }
    }
}
