.PHONY : test start setup_path


HTTP_MODULE := ./node_modules/http-server/bin

test:
	echo "npm install http-server required"
	@ $(HTTP_MODULE)/http-server

start:
	echo @ "starting the server in test directory"
	python -m SimpleHTTPServer 9100

setup_path:
	PATH=/usr/bin/node:$$PATH
