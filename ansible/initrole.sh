#!/usr/bin/env bash
#
# init role
# shellcheck disable=SC2001

NAME="$1"
TITLE=$(echo "$NAME" | sed -e 's/[a-z]*/\u&/')
BASE_DIR=$(dirname "$(readlink -f "$0")")
ROLE="$BASE_DIR/roles/${NAME}"
TASKS="$ROLE/tasks/main.yml"
DEFAULTS="$ROLE/defaults/main.yml"
HANDLERS="$ROLE/handlers/main.yml"
PLAY="$BASE_DIR/plays/${NAME}.yml"
INVENTORY="$BASE_DIR/inventory"
AUTOBUILD="$BASE_DIR/auto.sh"
ENVPLAY="$BASE_DIR/plays/env.yml"
ENVROOL="$BASE_DIR/roles/env"
CONFIG="$BASE_DIR/ansible.cfg"
AUTOCHECK="$BASE_DIR/autocheck.sh"

if [[ $# -ne 1 ]]; then
    echo "Usage: $(basename "$0") <role_name>"
    exit 1
fi
if ! [[ -d "$(dirname "$PLAY")" ]]; then
    mkdir -p "$(dirname "$PLAY")"
fi

if ! [[ -d "$INVENTORY" ]]; then
    mkdir -p "$INVENTORY"/group_vars
    cat << EOF | tee "$INVENTORY"/localhost
[local]
127.0.0.1 ansible_connection=local ansible_python_interpreter=/usr/bin/python3
EOF
    cat << EOF | tee "$INVENTORY"/selfhost
[selfhost]
myserver ansible_port=22 ansible_host=    ansible_python_interpreter=/usr/bin/python3
EOF
    cat << EOF | tee "$INVENTORY"/group_vars/all.yml
---
EOF
fi

if [[ -d "$ROLE" ]]; then
    find "$ROLE" -type f
    echo "$PLAY"
else
    mkdir -p "$ROLE"/{defaults,files,handlers,tasks,templates}
    cat > "$TASKS" << EOF
---
EOF
    cat > "$DEFAULTS" << EOF
---
EOF
    cat > "$HANDLERS" << EOF
---
EOF
    cat > "$PLAY" << EOF
---
- name: $TITLE
  hosts: selfhost
  gather_facts: true
  become: true

  roles:
    - role: community.general.log_plays
    - role: $NAME
EOF
fi

if ! [[ -f "$ENVPLAY" ]]; then
    cat > "$ENVPLAY" << EOF
---
- name: Env
  hosts: local
  gather_facts: true
  become: yes

  roles:
    - role: env
EOF
fi

if ! [[ -d "$ENVROOL" ]]; then
    mkdir -p "$ENVROOL"/tasks
    cat > "$ENVROOL"/tasks/main.yml << EOF
---
- name: Install require module
  pip:
    name:
      - github3.py
    executable: pip3
    state: present

- name: Set sudo
  lineinfile:
    path: "/etc/sudoers"
    regexp: '^%sudo'
    line: "%sudo ALL=(ALL:ALL) NOPASSWD: ALL"
    validate: "/usr/sbin/visudo -cf %s"
    mode: 0440
EOF
fi

if ! [[ -f "$CONFIG" ]]; then
    cat > "$CONFIG" << EOF
[defaults]
inventory = inventory
library = library
roles_path = roles
remote_user = root
timeout = 100
forks = 25
poll_interval = 5
gathering = smart
host_key_checking = False
retry_files_enabled = False
ansible_managed = Ansible managed: {file} modified by {uid} on {host}
callback_whitelist = timer, profile_tasks
nocows = 1
command_warnings = False
log_path = /var/log/ansible.log

[ssh_connection]
pipelining = True
control_path = /tmp/ansible-ssh-%%h-%%p-%%r

EOF
fi

if ! [[ -f "$AUTOCHECK" ]]; then
    cat > "$AUTOCHECK" << EOF
#! /bin/bash
set -eu
for _play in plays/*.yml; do
    ansible-playbook --syntax-check "\${_play}"
    ansible-lint "\${_play}"
done
find . -name '*.sh' \! -name 'modinfo.sh' -exec shellcheck -s bash '{}' \;
EOF
fi

if ! [[ -f "$AUTOBUILD" ]]; then
    cat > "$AUTOBUILD" << FOE
#!/bin/bash
set -e
if ! [ -f /usr/local/bin/ansible ]; then
    echo INFO Install ansible
    pip3 install ansible ansible-lint shellcheck -i https://pypi.mirrors.ustc.edu.cn/simple/ 
    ansible-galaxy collection install community.general
fi
read -rp "Please input your server ip add: " server_ip
read -rp "Please input your server sshd port: " sshd_port
if ping -c 3 "\$server_ip"; then
    cat << EOF | tee inventory/selfhost
[selfhost]
myserver ansible_port="\$sshd_port" ansible_host="\$server_ip" ansible_python_interpreter=/usr/bin/python3
EOF
fi
echo INFO set up env
ansible-playbook -vvv plays/env.yml
echo INFO set up soft
read -rp "Do you want to install soft? yes or no: " _YoN
case "\$_YoN" in
    yes | y | Y | YES)
        # ansible-playbook plays/soft.yml
        ;;
    *) ;;

esac
FOE
fi
exit 0
