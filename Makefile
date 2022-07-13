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


.PHONY: all rebuild rebuild_ui rebuild_lang rebuild_rest mount mount_ui mount_lang mount_rest startk stopk clean bm_ui bm_lang bm_rest

all: rebuild mount

bm_ui: rebuid_ui mount_ui

bm_lang: rebuid_lang mount_lang

bm_rest: rebuid_rest mount_rest

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
	minikube kubectl -- apply -f cloudbuild.yaml

startk:
	minikube start --hyperv-virtual-switch "My Virtual Switch" --v=8 --extra-config "apiserver.cors-allowed-origins=["http://\*"]"

stopk:
	minikube stop
