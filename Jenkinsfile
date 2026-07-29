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

		stage('Generate Ansible Inventory') {
		    steps {
		        dir('terraform') {
		            script {
		                def ec2_ip = sh(script: 'terraform output -raw ec2_public_ip', returnStdout: true).trim()
		                echo "EC2 IP from Terraform output: ${ec2_ip}"

		                writeFile file: '../ansible/inventory.ini',
		                          text: "[taskapi_servers]\n${ec2_ip} ansible_user=ubuntu ansible_ssh_private_key_file=\$SSH_KEY\n"
		            }
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
						sh 'ansible-playbook -i inventory.ini site.yml --limit taskapi_servers --extra-vars "db_password=${DB_PASSWORD}"'	
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
