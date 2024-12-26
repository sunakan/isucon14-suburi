#!/usr/bin/env bash
set -euo pipefail
#set -x
# -e: エラーが発生した時点でスクリプトを終了
# -u: 未定義の変数を使用した場合にエラーを発生
# -x: スクリプトの実行内容を表示(debugで利用)
# -o pipefail: パイプライン内のエラーを検出

readonly MAKEFILE_PATH="${LOCAL_WEBAPP_PATH}/go/Makefile"

#
# 通知
#
echo '-------[ build-makefile.sh ]'
echo "アプリ名: ${BUILT_APP_NAME}"
echo "ローカルのwebappのPATH: ${LOCAL_WEBAPP_PATH}"
echo "Makefileの掃き出し場所: ${MAKEFILE_PATH}"

#
# 未DLならエラーを吐いて終了
#
if [ ! -d "${LOCAL_WEBAPP_PATH}" ]; then
  echo "まだ ${LOCAL_WEBAPP_PATH} がDLされていないようです"
  echo "make downloadでDLしてください"
  exit 1
fi

#
# Makefileの有無チェック
#
if [ -f "${MAKEFILE_PATH}" ]; then
  echo "既に ${MAKEFILE_PATH} があります"
  echo "もしbuildし直したい場合は、 'rm ${MAKEFILE_PATH}' をしてからbuildし直してください"
  exit 0
fi

#
# Makefileを作成
#
export ENVSUBST_APP_NAME=${BUILT_APP_NAME}
envsubst '$ENVSUBST_APP_NAME' < setup-scripts/Makefile.template > "${LOCAL_WEBAPP_PATH}/go/Makefile"

#
# 通知
#
echo "👍️Done: ${MAKEFILE_PATH} をbuildしました"
