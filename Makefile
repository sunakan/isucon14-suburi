################################################################################
# Kaizen
################################################################################
.PHONY: deploy-mysql
deploy-mysql: ## MySQLの設定をデプロイ
	@bash kaizen-scripts/deploy-mysql.sh

################################################################################
# Setup
################################################################################
.PHONY: create-sshconfig
create-sshconfig: tmp/hosts.csv ## ssh用のconfigを作成
	@bash setup-scripts/create-sshconfig.sh

.PHONY: check-ssh
check-ssh: tmp/hosts.csv ## sshできるか確認
	@cat tmp/hosts.csv | cut -d',' -f1 | xargs -I{} bash -c 'echo "----[ {} ]" && ssh {} "ls"'

.PHONY: download-codes
download-codes: ## コード類をDL
	@bash setup-scripts/download-webapp.sh
	@echo ''
	@bash setup-scripts/download-mysql.sh
	@echo ''
	@bash setup-scripts/download-nginx.sh

.PHONY: build-makefile
build-makefile: ## ${LOCAL_WEBAPP_PATH}/go/Makefile がなければ作成
	@bash setup-scripts/build-makefile.sh

################################################################################
# Fileがなかった時の挙動
################################################################################
tmp/hosts.csv: ## tmp/hosts.csvをAWSと通信して作成
	@bash setup-scripts/create-hosts-csv.sh

################################################################################
# Utility-Command help
################################################################################
.DEFAULT_GOAL := help

################################################################################
# マクロ
################################################################################
# Makefileの中身を抽出してhelpとして1行で出す
# $(1): Makefile名
# 使い方例: $(call help,{included-makefile})
define help
  grep -E '^[\.a-zA-Z0-9_-]+:.*?## .*$$' $(1) \
  | grep --invert-match "## non-help" \
  | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'
endef

# 指定されたhostに3100番のポートフォワーディング
# $(1): ホスト名
# 使い方例: $(call port-forward-3100,host名)
define port-forward-3100
  (grep '$(1)' tmp/isu-servers &> /dev/null && ssh $(1) -R 3100:localhost:3100 -N) || echo '$(1)がありません'
endef

################################################################################
# タスク
################################################################################
.PHONY: help
help: ## Make タスク一覧
	@echo '######################################################################'
	@echo '# Makeタスク一覧'
	@echo '# $$ make XXX'
	@echo '# or'
	@echo '# $$ make XXX --dry-run'
	@echo '######################################################################'
	@echo $(MAKEFILE_LIST) \
	| tr ' ' '\n' \
	| xargs -I {included-makefile} $(call help,{included-makefile})
