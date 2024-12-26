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
echo '-------[ validate-dotenv.sh ]'
echo "リモート: webappへのPATH: ${REMOTE_WEBAPP_PATH}"
echo "リモート: golangのPATH: ${REMOTE_GOLANG_PATH}"
echo "アプリ名: ${BUILT_APP_NAME}"

while read -r server; do
  #
  # webappの場所
  #
  if ssh -n "${server}" "[ -d ${REMOTE_WEBAPP_PATH} ]"; then
    echo "リモートに ${REMOTE_WEBAPP_PATH} はあります 👍(OK: REMOTE_WEBAPP_PATH)"
  else
    echo "リモートに ${REMOTE_WEBAPP_PATH} がありません ❌(NG: REMOTE_WEBAPP_PATH)"
    echo "ssh ${server} をしてwebappへのPATHを .env に記述してください"
    exit 1
  fi

  #
  # アプリ(バイナリ)の場所
  #
  readonly BUILT_APP_PATH="${REMOTE_WEBAPP_PATH}/go/${BUILT_APP_NAME}"
  if ssh -n "${server}" "[ -f ${BUILT_APP_PATH} ]"; then
    echo "リモートに ${BUILT_APP_PATH} はあります 👍(OK: BUILT_APP_PATH)"
  else
    echo "リモートに ${BUILT_APP_PATH} がありません ❌(NG: BUILT_APP_PATH)"
    echo "ssh ${server} をしてビルドされるバイナリ名を .env に記述してください"
    exit 1
  fi

  #
  # systemdで動いているアプリ
  #
  if ssh -n "${server}" "systemctl list-units --type=service | grep '${SYSTEMD_APP_NAME}'"; then
     echo "リモートで ${SYSTEMD_APP_NAME} はあります 👍(OK: SYSTEMD_APP_NAME)"
  else
    echo "リモートに ${SYSTEMD_APP_NAME} がありません ❌(NG: SYSTEMD_APP_NAME)"
    echo "ssh ${server} をしてsystemctl list-units --type=service | grep 'isu\-'して .env に記述してください"
    exit 1
  fi

  #
  # Golangの場所
  #
  if ssh -n "${server}" "[ -d ${REMOTE_GOLANG_PATH} ]"; then
     echo "リモートに ${REMOTE_GOLANG_PATH} はあります 👍(OK: REMOTE_GOLANG_PATH)"
  else
    echo "リモートに ${REMOTE_GOLANG_PATH} がありません ❌(NG: REMOTE_GOLANG_PATH)"
    echo "ssh ${server} をしてgolangへのPATHを .env に記述してください"
    exit 1
  fi
done < <(head -n1 tmp/isu-servers)
