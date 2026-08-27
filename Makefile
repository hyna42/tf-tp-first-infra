fmt:
	@terraform fmt
validate:
	@terraform validate

plan:
	@terraform plan

apply:
	@terraform apply -auto-approve

destroy:
	@terraform destroy -auto-approve

# ANSIBLE
list:
	@ansible-inventory --list
ping:
	@ansible all -m ansible.builtin.ping

nginx-install:
	@ansible-playbook playbook/nginx.yml

nginx-uninstall:
	@ansible-playbook playbook/uninstalled_nginx.yml
