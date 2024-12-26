#!/usr/bin/env bash
set -euo pipefail
#set -x
# -e: エラーが発生した時点でスクリプトを終了
# -u: 未定義の変数を使用した場合にエラーを発生
# -x: スクリプトの実行内容を表示(debugで利用)
# -o pipefail: パイプライン内のエラーを検出

readonly LOCAL_NGINX_CONF_PATH="${LOCAL_COMMON_PATH}/etc/nginx/"
readonly REMOTE_NGINX_CONF_PATH='/etc/nginx/'

#
# 通知
#
echo '-------[ deploy-nginx.sh ]'
echo "アップロード元: ${LOCAL_NGINX_CONF_PATH}"
echo "アップロード先: ${REMOTE_NGINX_CONF_PATH}"

#
# Nginx
#
while read -r server; do
  echo "----[ デプロイサーバー: ${server} ]"
  echo 'アップロード中'
  rsync -az --rsync-path='sudo rsync' "${LOCAL_NGINX_CONF_PATH}" "${server}:${REMOTE_NGINX_CONF_PATH}"
  echo 'アップロード完了 & 再起動中'
  # u=rwX: 所有者に読み取り、書き込み、実行権限を付与します（Xは、ディレクトリのみに実行権限を付与）
  # go=rX: グループとその他のユーザーに読み取りとディレクトリのみに実行権限を付与します
  ssh -n "${server}" "sudo chown root:root -R ${REMOTE_NGINX_CONF_PATH} && sudo chmod u=rwX,go=rX -R ${REMOTE_NGINX_CONF_PATH%/}"
  ssh -n "${server}" 'sudo mkdir -p /var/log/nginx/'
  ssh -n "${server}" 'sudo systemctl daemon-reload && sudo systemctl restart nginx'
  echo '再起動完了'
  ssh -n "${server}" 'sudo chmod 777 -R /var/log/nginx/ && systemctl status nginx'
done < <(cat tmp/isu-reverse-proxy-servers)

#
# 通知
#
echo '👍️Done: Nginxのデプロイ'
