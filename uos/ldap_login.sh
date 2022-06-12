#!/bin/bash
curl -X POST --url "http://ac.uniontech.com/ac_portal/login.php" \
  --header "content-type: application/x-www-form-urlencoded" \
  --data opr='pwdLogin' \
  --data userName='LDAP用户名' \
  --data-urlencode pwd='LDAP密码' \
  --data rememberPwd='0'
