#!/usr/bin/env bash
set -euo pipefail
#set -x
# -e: エラーが発生した時点でスクリプトを終了
# -u: 未定義の変数を使用した場合にエラーを発生
# -x: スクリプトの実行内容を表示(debugで利用)
# -o pipefail: パイプライン内のエラーを検出

readonly MYSQL_SLOW_QUERY_LOG_PATH='/var/log/mysql/mysql-slow.log'
readonly MYSQL_ERROR_LOG_PATH='/var/log/mysql/error.log'

#
# 通知
#
echo "-------[ $(basename "${0}") ]"

#
# MySQL
#
while read -r server; do
  echo "----[ DBサーバー: ${server} ]"
  ssh -n "${server}" "(ls ${MYSQL_SLOW_QUERY_LOG_PATH} &> /dev/null && sudo mv ${MYSQL_SLOW_QUERY_LOG_PATH} ${MYSQL_SLOW_QUERY_LOG_PATH}.old) || echo 'スロークエリログが存在しません'; (ls ${MYSQL_ERROR_LOG_PATH} &> /dev/null && sudo mv ${MYSQL_ERROR_LOG_PATH} ${MYSQL_ERROR_LOG_PATH}.old) || echo 'エラーログが存在しません';"
  # u=rwX: 所有者に読み取り、書き込み、実行権限を付与します（Xは、ディレクトリのみに実行権限を付与）
  # go=rX: グループとその他のユーザーに読み取りとディレクトリのみに実行権限を付与します
  echo '再起動中'
  ssh -n "${server}" "sudo systemctl restart mysql; sudo chown -R mysql:mysql /var/log/mysql/ && sudo chmod u=rwX,go=rX -R /var/log/mysql/"
  echo '再起動完了'
done < <(cat tmp/isu-db-servers)

#
# 通知
#
echo '👍️Done: MySQLのログを掃除しました'
