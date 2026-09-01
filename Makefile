init:
	@terraform init

fmt:
	@terraform fmt -recursive
validate:
	@terraform validate

plan:
	@terraform plan

apply:
	@terraform apply -auto-approve

destroy:
	@terraform destroy -auto-approve

state-list:
	@terraform state list
# ANSIBLE
inv-list:
	@ansible-inventory --list
ping:
	@ansible all -m ansible.builtin.ping

nginx-install:
	@ansible-playbook playbook/nginx.yml

nginx-uninstall:
	@ansible-playbook playbook/uninstalled_nginx.yml
