#!/usr/bin/env bash
set -euo pipefail
#set -x
# -e: エラーが発生した時点でスクリプトを終了
# -u: 未定義の変数を使用した場合にエラーを発生
# -x: スクリプトの実行内容を表示(debugで利用)
# -o pipefail: パイプライン内のエラーを検出

readonly NGINX_ACCESS_LOG_PATH='/var/log/nginx/access.log'
readonly NGINX_ERROR_LOG_PATH='/var/log/nginx/error.log'

#
# 通知
#
echo "-------[ $(basename "${0}") ]"

#
# Nginx
#
while read -r server; do
  echo "----[ reverse proxy サーバー: ${server} ]"
  ssh -n "${server}" "(ls ${NGINX_ACCESS_LOG_PATH} &> /dev/null && sudo mv ${NGINX_ACCESS_LOG_PATH} ${NGINX_ACCESS_LOG_PATH}.old) || echo 'アクセスログが存在しません'; (ls ${NGINX_ERROR_LOG_PATH} &> /dev/null && sudo mv ${NGINX_ERROR_LOG_PATH} ${NGINX_ERROR_LOG_PATH}.old) || echo 'エラーログが存在しません'"
  # u=rwX: 所有者に読み取り、書き込み、実行権限を付与します（Xは、ディレクトリのみに実行権限を付与）
  # go=rX: グループとその他のユーザーに読み取りとディレクトリのみに実行権限を付与します
  echo '再起動中'
  ssh -n "${server}" "sudo nginx -t && sudo systemctl reload nginx && sudo chmod u=rwX,go=rX -R /var/log/nginx/"
  echo '再起動完了'
done < <(cat tmp/isu-reverse-proxy-servers)

#
# 通知
#
echo '👍️Done: Nginxのログを掃除しました'
