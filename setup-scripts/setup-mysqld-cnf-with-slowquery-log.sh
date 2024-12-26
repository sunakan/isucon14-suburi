#!/usr/bin/env bash
set -euo pipefail
#set -x
# -e: エラーが発生した時点でスクリプトを終了
# -u: 未定義の変数を使用した場合にエラーを発生
# -x: スクリプトの実行内容を表示(debugで利用)
# -o pipefail: パイプライン内のエラーを検出

readonly LOCAL_MYSQLD_CNF_PATH="${LOCAL_COMMON_PATH}/etc/mysql/mysql.conf.d/mysqld.cnf"

#
# 通知
#
echo "-------[ $(basename "${0}") ]"
echo "ローカルのmysqld.cnfのパス: ${LOCAL_MYSQLD_CNF_PATH}"
echo '-------'

#
# 既に ${LOCAL_MYSQLD_CNF_PATH} が存在する場合、上書きするか聞く
#
if [ -f "${LOCAL_MYSQLD_CNF_PATH}" ]; then
  echo "既に ${LOCAL_MYSQLD_CNF_PATH} があります"
  echo -n '上書きしますか？(y|yes/それ以外はno扱い): '
  read -r is_replace
  if [ "${is_replace}" != 'y' ] && [ "${is_replace}" != 'yes' ]; then
    echo '上書きしません'
    exit 0
  fi
fi

#
# mysqld.cnfを上書き
#
cp "$(dirname "${0}")/mysqld.cnf" "${LOCAL_MYSQLD_CNF_PATH}"

#
# 通知
#
echo "👍️Done: mysqld.cnfのsetup"

#
# gitの差分がなければここで終了
#
if git diff --quiet "${LOCAL_MYSQLD_CNF_PATH}"; then
  exit 0
fi

#
# git commit するか聞く
#
git diff ${LOCAL_MYSQLD_CNF_PATH}
echo -n "差分があるようです。git commitしますか？(y|yes/それ以外はno扱い)"
read -r is_git
if [ "${is_git}" != 'y' ] && [ "${is_git}" != 'y' ]; then
  echo 'commitしません'
fi
git reset .
git stage "${LOCAL_MYSQLD_CNF_PATH}"
git commit -m 'setup mysqld.cnf with slowquery log'
