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
echo "webappへのPATH: ${REMOTE_WEBAPP_PATH}"
echo "アプリ(バイナリ): ${BUILT_APP_NAME}"
echo "systemdで動いているアプリ: ${SYSTEMD_APP_NAME}"
echo "golangのPATH: ${REMOTE_GOLANG_PATH}"
echo '-------'

while read -r server; do
  #
  # webappの場所
  #
  if ssh -n "${server}" "[ -d ${REMOTE_WEBAPP_PATH} ]"; then
    echo "OK: REMOTE_WEBAPP_PATH=${REMOTE_WEBAPP_PATH}"
  else
    echo "NG: REMOTE_WEBAPP_PATH=${REMOTE_WEBAPP_PATH}"
    echo "ssh ${server} をしてwebappへのPATHを .env に記述してください"
    exit 1
  fi

  #
  # アプリ(バイナリ)の場所
  #
  readonly BUILT_APP_PATH="${REMOTE_WEBAPP_PATH}/go/${BUILT_APP_NAME}"
  if ssh -n "${server}" "[ -f ${BUILT_APP_PATH} ]"; then
    echo "OK: BUILT_APP_PATH=${BUILT_APP_PATH}"
  else
    echo "NG: BUILT_APP_PATH=${BUILT_APP_PATH}"
    echo "ssh ${server} をしてビルドされるバイナリ名を .env に記述してください"
    exit 1
  fi

  #
  # systemdで動いているアプリ
  #
  if ssh -n "${server}" "systemctl list-units --type=service | grep '${SYSTEMD_APP_NAME}'"; then
     echo "OK: SYSTEMD_APP_NAME=${SYSTEMD_APP_NAME}"
  else
     echo "NG: SYSTEMD_APP_NAME=${SYSTEMD_APP_NAME}"
    echo "ssh ${server} をしてsystemctl list-units --type=service | grep 'isu\-'して .env に記述してください"
    exit 1
  fi

  #
  # Golangの場所
  #
  if ssh -n "${server}" "[ -d ${REMOTE_GOLANG_PATH} ]"; then
     echo "OK: REMOTE_GOLANG_PATH=${REMOTE_GOLANG_PATH}"
  else
     echo "NG: REMOTE_GOLANG_PATH=${REMOTE_GOLANG_PATH}"
    echo "ssh ${server} をしてgolangへのPATHを .env に記述してください"
    exit 1
  fi
done < <(head -n1 tmp/isu-servers)
