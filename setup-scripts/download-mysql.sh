#!/usr/bin/env bash
set -euo pipefail
#set -x
# -e: エラーが発生した時点でスクリプトを終了
# -u: 未定義の変数を使用した場合にエラーを発生
# -x: スクリプトの実行内容を表示(debugで利用)
# -o pipefail: パイプライン内のエラーを検出

readonly LOCAL_MYSQL_CONF_PATH="${LOCAL_COMMON_PATH}/etc/mysql/"
readonly REMOTE_MYSQL_CONF_PATH='/etc/mysql/'

#
# 通知
#
echo '-------[ download-mysql.sh ]'
echo "ダウンロード元: ${REMOTE_MYSQL_CONF_PATH}"
echo "ダウンロード先: ${LOCAL_MYSQL_CONF_PATH}"

#
# DL済みなら、DLしない
#
if [ -d "${LOCAL_MYSQL_CONF_PATH}" ]; then
  echo "既に ${LOCAL_MYSQL_CONF_PATH} があります(DL済みです)"
  echo "もしDLし直したい場合は、 'rm -rf ${LOCAL_MYSQL_CONF_PATH}' をしてからDLし直してください"
  exit 0
fi

#
# 有無チェック
#
head -n1 tmp/isu-servers | xargs -I{} ssh {} "[ -d ${REMOTE_MYSQL_CONF_PATH} ]" || \
(echo "ssh先に、 ${REMOTE_MYSQL_CONF_PATH} がありません。 ssh して確認してください" && exit 1)

#
# ${REMOTE_MYSQL_CONF_PATH} をダウンロード
#
mkdir -p "${LOCAL_MYSQL_CONF_PATH}"
head -n1 tmp/isu-servers | xargs -I{} rsync -az --rsync-path='sudo rsync' "{}:${REMOTE_MYSQL_CONF_PATH}" "${LOCAL_MYSQL_CONF_PATH}"

#
# 通知
#
echo '👍️Done: MySQLの設定ファイル群をDLしました'
