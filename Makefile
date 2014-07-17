all: 
	echo "please give task name: npm, rpm... etc"

_build:
	mkdir _build
	mkdir -p _build/npm/lib
	mkdir _build/rpm

npm: _build compile_coffee
	cp index.js ./_build/npm
	cp ./package.json ./_build/npm

compile_coffee:
	coffee -c -o _build/npm/lib ./lib

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