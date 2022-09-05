### VariaMos 2022
### Infrastructrure Makefile For local Dev Work w/ minikube
###

# Your local dir
WORKDIR=/home/kaiser185/workspace/VMOS2022/
VERSION=latest
PREFIX=up1ps/
VARIAMOS_UI=VariaMosPLE
VARIAMOS_UI_TAG=$(PREFIX)vmos:$(VERSION)
VARIAMOS_LANG=variamos_ms_languages
VARIAMOS_LANG_TAG=$(PREFIX)vlang:$(VERSION)
VARIAMOS_REST=variamos_ms_restrictions
VARIAMOS_REST_TAG=$(PREFIX)vrest:$(VERSION)
DEPLOYMENT_NAME=infra
CONFIG_FILES := $(shell ls ./config)
RUN_ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
$(eval $(RUN_ARGS):;@:)

.PHONY: all rebuild rebuild_ui rebuild_lang rebuild_rest mount mount_ui mount_lang mount_rest startk stopk clean bm_ui bm_lang bm_rest clean clean_ui clean_lang clean_rest restart

all: rebuild mount

bm_ui: rebuild_ui mount_ui

bm_lang: rebuild_lang mount_lang

bm_rest: rebuild_rest mount_rest

rebuild: rebuild_ui rebuild_lang rebuild_rest

rebuild_ui:
	docker build -t $(VARIAMOS_UI_TAG) $(VARIAMOS_UI)

rebuild_lang:
	docker build -t $(VARIAMOS_LANG_TAG) $(VARIAMOS_LANG)

rebuild_rest:
	docker build -t $(VARIAMOS_REST_TAG) $(VARIAMOS_REST)

mount: mount_ui mount_lang mount_rest

mount_ui:
	minikube image load $(VARIAMOS_UI_TAG)

mount_lang:
	minikube image load $(VARIAMOS_LANG_TAG)

mount_rest:
	minikube image load $(VARIAMOS_REST_TAG)

run:
	$(foreach conf,$(CONFIG_FILES), minikube kubectl -- apply -f config/$(conf);)

startk:
	minikube --hyperv-virtual-switch "My Virtual Switch" --v=8 --extra-config apiserver.cors-allowed-origins=["http://*"] start

restart_all: clean all

restart:
ifneq (, $(RUN_ARGS))
restart: restart_svc
else
restart:
	@echo "Restarts need an argument (ui|lang|rest) or call make restart_all. Stopping."
endif

restart_svc: clean_$(RUN_ARGS) bm_$(RUN_ARGS)
	test $(RUN_ARGS)
ifeq (ui,$(firstword $(RUN_ARGS)))
	minikube kubectl -- apply -f config/vmos.yaml
else ifneq ('',$(RUN_ARGS))
	minikube kubectl -- apply -f config/v$(RUN_ARGS).yaml
else
	@echo "OOPS"
endif


clean:
	minikube kubectl -- delete deployment vmos db vlang vrest && sleep 2
	minikube image rm $(VARIAMOS_UI_TAG) $(VARIAMOS_LANG_TAG) $(VARIAMOS_LANG_TAG)

clean_sparedb:
	minikube kubectl -- delete deployment vmos vlang vrest && sleep 2
	minikube image rm $(VARIAMOS_UI_TAG) $(VARIAMOS_LANG_TAG) $(VARIAMOS_LANG_TAG)

clean_ui:
	minikube kubectl -- delete deployment vmos && sleep 2
	minikube image rm $(VARIAMOS_UI_TAG)

clean_lang:
	minikube kubectl -- delete deployment vlang && sleep 2
	minikube image rm $(VARIAMOS_LANG_TAG)

clean_rest:
	minikube kubectl -- delete deployment vrest && sleep 2
	minikube image rm $(VARIAMOS_REST_TAG)

stopk:
	minikube stop
