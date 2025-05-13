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
	@cd templates &>/dev/null
	echo policy:
	echo
	echo '  # To install a policy add it here. Each entry supports the following custom config:'
	echo '  #'
	echo '  # enabled:             bool. default=.Values.(marvin|kubescape).enabled'
	echo '  # needParams:          bool. default=false'
	echo '  # failurePolicy:       string(Fail|Ignore). default=.Values.defaultFailurePolicy'
	echo '  # nameOverride:        string'
	echo '  # bindingSpec:         ValidatingAdmissionPolicyBinding.spec. default=.Values.bindingSpec'
	echo '  # validationsOverride: ValidatingAdmissionPolicy.spec.validations'
	for pol in $$(echo getup-* marvin-* | sort); do
		echo
		echo "  $${pol%.*}:"
		if grep -qw 'params\.settings' $$pol; then
		echo "    needParams: true"
		fi
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
