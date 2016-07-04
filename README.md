# dotfiles
make development environment for mac

## requirements
- Homebrew
- Ansible

## Usage

### for mac
```
./init.sh # only first
ansible-playbook playbook.yml -i hosts
```

### for ubuntu
```
sudo ansible-playbook playbook_ubuntu.yml -i hosts -k
```
