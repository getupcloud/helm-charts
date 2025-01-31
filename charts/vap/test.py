#!/usr/bin/env python

import os
import sys
import yaml
import binascii
import subprocess

color_red = lambda t: f'\033[31m{t}\033[0m'
color_green = lambda t: f'\033[32m{t}\033[0m'
color_dim = lambda t: f'\033[2m{t}\033[0m'

TEST_NAMESPACE='vap-test'

def has_namespace(namespace):
    proc = subprocess.run(f'kubectl get namespace {namespace}'.split(), stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    return proc.returncode == 0


def setup():
    proc = subprocess.run(f'kubectl config view'.split(), text=True, stdout=subprocess.PIPE)
    if proc.returncode != 0:
        sys.exit(1)
    data = yaml.safe_load(proc.stdout)
    cctx = data['current-context']
    ctx = [ c.get('context',{}).get('namespace', None) for c in data['contexts'] if c['name'] == cctx ]
    if not ctx:
        ctx =ctx[0]
    else:
        ctx = TEST_NAMESPACE
    subprocess.run(f'kubectl config set-context "{ctx}" --namespace="{TEST_NAMESPACE}"'.split())

    if not has_namespace(TEST_NAMESPACE):
        subprocess.run(f'kubectl create namespace {TEST_NAMESPACE}'.split())

CLEANUP_QUEUE=[]
if not has_namespace(TEST_NAMESPACE):
    CLEANUP_QUEUE.append(['namespace', 'vap-test'])

def cleanup():
    if os.environ.get('CLEANUP', 'true') == 'false':
        return
    for (kind, name) in CLEANUP_QUEUE:
        subprocess.run(f'kubectl delete {kind} {name}'.split())

setup()

test_no=0
test_list = yaml.safe_load(sys.stdin)
for test in test_list:
    test_no+=1
    passed = False
    name, must_pass, test_data = test['name'], test['pass'], yaml.safe_load(test['input'])

    crc = hex(binascii.crc32(test['input'].encode(encoding="utf-8")))
    test_data['metadata']['name'] = f'test-{test_no:03d}-{crc[-6:]}'

    if not 'namespace' in test_data['metadata']:
        test_data['metadata']['namespace'] = TEST_NAMESPACE

    if not has_namespace(test_data['metadata']['namespace']):
        subprocess.run(f'kubectl create namespace {test_data["metadata"]["namespace"]}'.split())
        CLEANUP_QUEUE.append(['namespace', test_data["metadata"]["namespace"]])

    test_data_str = yaml.dump(test_data)
    print(f'Test-{test_no:03d} {name}... ', end='')
    sys.stdout.flush()
    proc = subprocess.run('kubectl apply -f -'.split(), input=test_data_str, text=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)

    if proc.returncode == 0:
        if must_pass:
            passed = True
        else:
            passed = False
    else:
        if must_pass:
            passed = False
        else:
            passed = True

    if must_pass != passed:
        print(color_red('FAILED'))
        print(color_dim(f'--- Output --- Expected {must_pass}, got {passed} (retCode={proc.returncode})'))
        print(color_dim(proc.stdout), end='')
        print(color_dim('--- Output End ---'))
        subprocess.run('kubectl delete -f -'.split(), input=test_data_str, text=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        cleanup()
        sys.exit(1)
    else:
        print(color_green('PASSED'))

    subprocess.run('kubectl delete --wait=false -f -'.split(), input=test_data_str, text=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

cleanup()
