# 1. chiave del vault (non resta nella history)
read -rs -p 'Password vault: ' P; echo "$P" > ~/.vault_pass; unset P; chmod 600 ~/.vault_pass

# 2. ansible.cfg la usa in automatico (va nella sezione [defaults])
sed -i '/^\[defaults\]/a vault_password_file = ~/.vault_pass' ansible.cfg

# 3. file cifrato con la password di root delle VM RHEL
mkdir -p group_vars/fews_rhel
ansible-vault create group_vars/fews_rhel/vault.yml
