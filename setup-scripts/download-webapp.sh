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
echo '-------[ download-webapp.sh ]'
echo "アプリ名: ${BUILT_APP_NAME}"
echo "リモートのwebappへのPATH: ${REMOTE_WEBAPP_PATH}"
echo "ローカルのwebappへのPATH: ${LOCAL_WEBAPP_PATH}"
echo '-------'

#
# DL済みなら、DLしない
#
if [ -d "${LOCAL_WEBAPP_PATH}" ]; then
  echo "既に ${LOCAL_WEBAPP_PATH} があります(DL済みです)"
  echo "もしDLし直したい場合は、 'rm -rf ${LOCAL_WEBAPP_PATH}' をしてからDLし直してください"
  exit 0
fi

#
# 有無チェック
#
head -n1 tmp/isu-servers | xargs -I{} ssh {} "[ -d ${REMOTE_WEBAPP_PATH} ]" || \
(echo "ssh先に、 ${REMOTE_WEBAPP_PATH} がありません。 ssh して確認してください" && exit 1)

#
# webapp
# .envにて、REMOTE_WEBAPP_PATHを設定していること
# 例: REMOTE_WEBAPP_PATH=/home/isucon/webapp
#
head -n1 tmp/isu-servers | xargs -I{} rsync -az \
  --exclude 'php' \
  --exclude 'perl' \
  --exclude 'rust' \
  --exclude 'ruby' \
  --exclude 'nodejs' \
  --exclude 'python' \
  --exclude "${BUILT_APP_NAME}" \
  "{}:${REMOTE_WEBAPP_PATH}/" "${LOCAL_WEBAPP_PATH}"

#
# 通知
#
echo '👍️Done: webappをDLしました'
