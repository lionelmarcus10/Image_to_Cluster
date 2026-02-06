.PHONY: setup deploy update destroy

setup:
	if ! command -v k3d >/dev/null 2>&1; then echo "Installing k3d..."; curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash; else echo "k3d already installed"; fi; \
	if ! k3d cluster list | grep -q '^lab\b'; then echo "Creating k3d cluster 'lab'..."; k3d cluster create lab --servers 1 --agents 2; else echo "k3d cluster 'lab' already exists"; fi; \
	if ! command -v packer >/dev/null 2>&1; then echo "Installing Packer..."; sudo apt update; sudo apt install -y gnupg software-properties-common curl; curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg; echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $$(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list; sudo apt update; sudo apt install -y packer; else echo "Packer already installed"; fi; \
	if ! command -v ansible >/dev/null 2>&1; then echo "Installing pipx and Ansible..."; python3 -m pip install --user pipx; python3 -m pipx ensurepath; pipx install --include-deps ansible; else echo "Ansible already installed"; fi

deploy:
	ansible-playbook ansible/deploy.yml

update:
	ansible-playbook ansible/update.yml

destroy:
	ansible-playbook ansible/destroy.yml
