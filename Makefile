all: 
	echo "please give task name: npm, rpm... etc"

init:
	mkdir ./_npm

npm: _npm copy_files compile_coffee

compile_coffee:
	coffee -c -o _npm/lib ./lib

_npm:
	mkdir _npm

copy_files:
	cp index.js ./_npm
	cp ./package.json ./_npm


linux64: _tar  npm
	tar -xvf node/node-v0.10.29-linux-x64.tar.gz -C _tar
	npm install ./_npm

	mkdir -p ./_tar/node_modules
	cp -r node_modules/ma-agent ./_tar/node_modules/ma-agent
	mkdir -p ./_tar/var

mac64: _tar npm
	tar -xvf node/node-v0.10.29-darwin-x64.tar.gz -C _tar
	mv _tar/node-v0.10.29-darwin-x64 _tar/node

	npm install ./_npm
	mkdir -p ./_tar/node_modules
	cp -r node_modules/ma-agent ./_tar/node_modules/ma-agent
	mkdir -p ./_tar/var


_tar:
	mkdir _tar

clean:
	rm -rf ./_tar
	rm -rf ./_npm