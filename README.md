#Resource list that were created manually

- s3 bucket and dynamodb for remote state
- iam-instance-profile for jenkins-controller to access aws

#Terraform infrastructure

- cd terraform
- terraform init
- terraform plan
- terraform apply

#Ansible config for jenkins-controller

- cd ansible
- ansible-playbook -i inventory.ini site.yml (if error occurs for key try using --private-key tag with you key)

#Jenkins setup

- open your jenkins-controller ip on port 8080
- ssh into jenkins-controller ec2 and get the password and enter
- install plugins and set account credentials
- store 2 credentials taskapi-db-password and taskapi-ec2-ssh-key 

#Jenkins pipeline 

- push the whole code to github
- create a pipeline in jenkins using that github as the source
- build the pipeline
