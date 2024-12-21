#!/usr/bin/env bash
set -eu
#set -x
# -e: エラーが発生した時点でスクリプトを終了
# -u: 未定義の変数を使用した場合にエラーを発生
# -x: スクリプトの実行内容を表示(debugで利用)

readonly LOCAL_NGINX_CONF_PATH="${LOCAL_COMMON_PATH}/etc/nginx/"
readonly REMOTE_NGINX_CONF_PATH='/etc/nginx/'

#
# 通知
#
echo '-------[ download-nginx.sh ]'
echo "ダウンロード元: ${REMOTE_NGINX_CONF_PATH}"
echo "ダウンロード先: ${LOCAL_NGINX_CONF_PATH}"

#
# DL済みなら、DLしない
#
if [ -d "${LOCAL_NGINX_CONF_PATH}" ]; then
  echo "既に ${LOCAL_NGINX_CONF_PATH} があります(DL済みです)"
  echo "もしDLし直したい場合は、 'rm -rf ${LOCAL_NGINX_CONF_PATH}' をしてからDLし直してください"
  exit 0
fi

#
# 有無チェック
#
head -n1 tmp/isu-servers | xargs -I{} ssh {} "[ -d ${REMOTE_NGINX_CONF_PATH} ]" || \
(echo "ssh先に、 ${REMOTE_NGINX_CONF_PATH} がありません。 ssh して確認してください" && exit 1)

#
# nginx
# 証明書以外をDL
#
mkdir -p "${LOCAL_NGINX_CONF_PATH}"
head -n1 tmp/isu-servers | xargs -I{} rsync -az --rsync-path='sudo rsync' --exclude '*.key' --exclude '*.crt' "{}:${REMOTE_NGINX_CONF_PATH}" "${LOCAL_NGINX_CONF_PATH}"


#
# 通知
#
echo '👍️Done: Nginxの設定ファイル群をDLしました'
