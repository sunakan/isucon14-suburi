#!/usr/bin/env bash
set -eu
#set -x
# -e: エラーが発生した時点でスクリプトを終了
# -u: 未定義の変数を使用した場合にエラーを発生
# -x: スクリプトの実行内容を表示(debugで利用)

readonly LOCAL_MYSQL_CONF_PATH="${LOCAL_COMMON_PATH}/etc/mysql/"
readonly REMOTE_MYSQL_CONF_PATH='/etc/mysql/'

#
# 通知
#
echo '-------[ deploy-mysql.sh ]'
echo "アップロード元: ${LOCAL_MYSQL_CONF_PATH}"
echo "アップロード先: ${REMOTE_MYSQL_CONF_PATH}"

#
# MySQL
#
while read -r server; do
  echo "----[ デプロイサーバー: ${server} ]"
  echo 'アップロード中'
  rsync -az --rsync-path='sudo rsync' "${LOCAL_MYSQL_CONF_PATH}" "${server}:${REMOTE_MYSQL_CONF_PATH}"
  echo 'アップロード完了 & 再起動中'
  # u=rwX: 所有者に読み取り、書き込み、実行権限を付与します（Xは、ディレクトリのみに実行権限を付与）
  # go=rX: グループとその他のユーザーに読み取りとディレクトリのみに実行権限を付与します
  ssh -n "${server}" "sudo chown root:root -R ${REMOTE_MYSQL_CONF_PATH} && sudo chmod u=rwX,go=rX -R ${REMOTE_MYSQL_CONF_PATH%/}"
  ssh -n "${server}" 'sudo mkdir -p /var/log/mysql/'
  ssh -n "${server}" 'sudo systemctl daemon-reload && sudo systemctl restart mysql'
  echo '再起動完了'
  ssh -n "${server}" 'sudo chown -R mysql:mysql /var/log/mysql/ && sudo chmod 777 -R /var/log/mysql/ && systemctl status mysql'
done < <(cat tmp/isu-db-servers)

#
# 通知
#
echo '👍️Done: MySQLのデプロイ'
