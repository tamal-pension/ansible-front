# vagrant plugin install vagrant-aws 
# vagrant up --provider=aws
# vagrant destroy -f && vagrant up --provider=aws
# vagrant rsync-auto
## optional:
# export COMMON_COLLECTION_PATH='~/git/inqwise/ansible/ansible-common-collection'
# export STACKTREK_COLLECTION_PATH='~/git/inqwise/ansible/ansible-stack-trek'

TOPIC_NAME = "pre_playbook_errors"
ACCOUNT_ID = "339712742264"
AWS_REGION = "eu-west-1"
MAIN_SH_ARGS = <<MARKER
-e "playbook_name=ansible-front discord_message_owner_name=#{Etc.getpwuid(Process.uid).name}environment_id=pension-stg.local" --tags "installation,configuration"
MARKER
Vagrant.configure("2") do |config|
  config.vm.provision "shell", inline: <<-SHELL  
    set -euxo pipefail
    echo "start vagrant file"
    python3 -m venv /tmp/ansibleenv
    source /tmp/ansibleenv/bin/activate
    aws s3 cp s3://resource-pension-stg/get-pip.py - | python3
    cd /vagrant
    export VAULT_PASSWORD=#{`op read "op://Security/ansible-vault tamal-pension-stg/password"`.strip!}
    echo "$VAULT_PASSWORD" > vault_password
    export ANSIBLE_VERBOSITY=0
    if [ ! -f "main.sh" ]; then
    echo "Local main.sh not found. Download main.sh script from URL..."
    curl -s https://raw.githubusercontent.com/inqwise/ansible-automation-toolkit/default/main_amzn2023.sh -o main.sh
    fi
    bash main.sh #{MAIN_SH_ARGS}
    rm vault_password
  SHELL

  config.vm.provider :aws do |aws, override|
  	override.vm.box = "dummy"
    override.ssh.username = "ec2-user"
    override.ssh.private_key_path = "~/.ssh/id_rsa"
    aws.aws_dir = ENV['HOME'] + "/.aws/"
    aws.aws_profile = "pension-stg"
  
    aws.keypair_name = Etc.getpwuid(Process.uid).name
    aws.region = AWS_REGION
    override.vm.allowed_synced_folder_types = [:rsync]
    override.vm.synced_folder ".", "/vagrant", type: :rsync, rsync__exclude: ['.git/','inqwise/'], disabled: false
    common_collection_path = ENV['COMMON_COLLECTION_PATH'] || '~/git/ansible-common-collection'
    override.vm.synced_folder common_collection_path, '/vagrant/collections/ansible_collections/inqwise/common', type: :rsync, rsync__exclude: '.git/', disabled: false
    
    aws.security_groups = ["sg-077f8d7d58d420467","sg-0ae991e1451bdc255"]
    # public-ssh, pension-front
    aws.ami = "ami-0fa86d752d8b7d1ff"
    aws.instance_type = "t4g.small"
    aws.subnet_id = "subnet-0331d92e81f166c9f"
    aws.associate_public_ip = true
    aws.iam_instance_profile_name = "bootstrap-role"
    aws.tags = {
      Name: "pension-front-test-#{Etc.getpwuid(Process.uid).name}",
      playbook_name: "ansible-front",
      version: "latest",
      app: "pension-front",
      private_dns: "pension-front-test-#{Etc.getpwuid(Process.uid).name}"
    }
  end
end