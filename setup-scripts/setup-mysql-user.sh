#!/usr/bin/env bash
set -euo pipefail
#set -x
# -e: エラーが発生した時点でスクリプトを終了
# -u: 未定義の変数を使用した場合にエラーを発生
# -x: スクリプトの実行内容を表示(debugで利用)
# -o pipefail: パイプライン内のエラーを検出

#
# 通知
#
echo "-------[ $(basename "${0}") ]"
echo "SQL: create user if not exists 'isucon'@'%' identified by 'isucon';"
echo "SQL: grant all privileges on *.* to 'isucon'@'%';"
echo '-------'

#
# isuconユーザの作成
# user: isucon
# pass: isucon
# 権限: 全て
#
while read -r db_server; do
  echo "${db_server}にてMySQLユーザー isuconを作成中"
  ssh -n "${db_server}" "sudo mysql -e \"create user if not exists 'isucon'@'%' identified by 'isucon'; grant all privileges on *.* to 'isucon'@'%'; select user, host from mysql.user where user like 'isu%';\""
done < <(cat tmp/isu-db-servers)

#
# 通知
#
echo "👍️Done: MySQLユーザを作成"
