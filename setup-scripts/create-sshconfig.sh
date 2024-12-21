#!/usr/bin/env bash
set -eu
#set -x
# -e: エラーが発生した時点でスクリプトを終了
# -u: 未定義の変数を使用した場合にエラーを発生
# -x: スクリプトの実行内容を表示(debugで利用)

#
# OUTPUT:
# - ~/.ssh/isucon.d/config
# - tmp/isu-servers
# - tmp/isu-db-servers データベース(主にMySQL)
# - tmp/isu-reverse-proxy-servers リバースプロキシ(主にnginx)
#

readonly SSH_CONFIG_DIR_PATH="${HOME}/.ssh/isucon.d"
readonly SSH_CONFIG_PATH="${SSH_CONFIG_DIR_PATH}/config"
mkdir -p "${SSH_CONFIG_DIR_PATH}"

#
# ${SSH_CONFIG_PATH}を作成
#
cat tmp/hosts.csv \
  | awk -F, '{print "Host "$1"\n  HostName "$2"\n  User isucon\n  IdentityFile ~/.ssh/id_ed25519\n  StrictHostKeyChecking no\n  UserKnownHostsFile /dev/null\n  LogLevel quiet"}' \
  > "${SSH_CONFIG_PATH}"
chmod 644 "${SSH_CONFIG_PATH}"

#
# 以下を作成
# - tmp/isu-servers
# - tmp/isu-db-servers
# - tmp/isu-reverse-proxy-servers
grep -v 'bench' tmp/hosts.csv | cut -d',' -f1 > tmp/isu-servers
head -n1 tmp/isu-servers > tmp/isu-db-servers
head -n1 tmp/isu-servers > tmp/isu-reverse-proxy-servers

#
# 通知
#
echo "${SSH_CONFIG_PATH}を作成しました"
echo '----------------------------------------'
cat "${SSH_CONFIG_PATH}"
echo '----------------------------------------'
echo '👉~/.ssh/configの先頭に以下を記述してください'
echo "Include ${SSH_CONFIG_DIR_PATH}"
echo ''
echo '~/.ssh/configにIncludeをすると、以下でssh可能です'
while read -r server; do
  echo "ssh ${server}"
done < <(cat tmp/isu-servers)
