SHELL = /bin/bash

.ONESHELL:
.EXPORT_ALL_VARIABLES:

all: src

.PHONY: src
src:
	bash -e ./build-src

helm-template:
	helm template vap . --debug

helm-install:
	helm upgrade --install vap-system . -n vap-system --create-namespace

helm-values:
	@cd policies &>/dev/null
	echo policy:
	for pol in $$(echo marvin-* | sort); do
		echo "  $${pol%.*}:"
		echo "    # enabled: false"
		echo "    # failurePolicy: Fail"
		echo "    # nameOverride: $${pol%.*}"
		echo "    # bindingSpec: ## ValidatingAdmissionPolicyBinding.spec ##"
		echo "    # validationsOverride: ## ValidatingAdmissionPolicy.spec.validations ##
		echo
	done

check-file-consistency: FILES = $(shell find vendor/marvin/internal/builtins/ -type f ! -name *_test.yaml -name *.yaml)
check-file-consistency:
	@for i in $(FILES); do
		n=$$(cat $$i | yq '.id + "_" + (.slug|sub("-","_"))')
		i=$${i##*/}
		i=$${i%.*}
		[ "$$i" == "$$n" ] && echo OK: $$i || echo "ERR: $$i:$$n"
	done

test: TEST_FILES ?= $(shell find vendor/marvin/internal/builtins/ -type f -regex .*_test.ya?ml)
test:
	@for i in $(TEST_FILES); do
		if kubectl config  current-context | grep kind -q && [[ $$i =~ .*apparmor.* ]]; then
			echo "Ignoring %%i: Kind cluster has no support for AppArmor"
			continue
		fi
		echo + $$i
		if ! ./test.py <$$i; then
			echo FAILED
			exit 1
		fi
		echo
	done
