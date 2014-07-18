VERSION=1.0.0
ROOT=_build/ma-agent-${VERSION}
OPT_ROOT=${ROOT}/opt/ma-agent


all: 
	echo "please give task name: npm, rpm... etc"

_build:
	mkdir _build
	mkdir -p _build/tar
	mkdir -p _build/npm/lib
	mkdir -p _build/rpmbuild/SPECS
	mkdir -p _build/rpmbuild/SOURCES
	mkdir -p _build/rpmbuild/RPMS
	mkdir -p _build/rpmbuild/SRPMS
	mkdir -p _build/rpmbuild/BUILD
	mkdir -p _build/rpmbuild/BUILDROOT
	mkdir -p ${OPT_ROOT}

npm: _build compile_coffee
	cp index.js ./_build/npm
	cp ./package.json ./_build/npm

compile_coffee:
	coffee -c -o _build/npm/lib ./lib

rpm: _build  npm
	## node
	tar -xf node/node-v0.10.29-linux-x64.tar.gz -C _build/
	mv _build/node-v0.10.29-linux-x64 ${OPT_ROOT}/node
	mkdir -p ${OPT_ROOT}/

	## ma-agent npm
	rm -rf /tmp/npm /tmp/node_modules
	cp -r _build/npm /tmp/npm
	cd /tmp && npm install  ./npm

	mv /tmp/node_modules ${OPT_ROOT}/

	# var
	cp -r bin ${OPT_ROOT}
	mkdir ${OPT_ROOT}/var

	# etc
	mkdir -p ${ROOT}/etc/ma-agent
	cp conf/dev.conf ${ROOT}/etc/ma-agent/ma-agent.conf

	## init.d
	mkdir -p ${ROOT}/etc/init.d/
	cp init.d/ma-agent ${ROOT}/etc/init.d

	## tarball
	cd _build && tar -zcf ma-agent-${VERSION}.tar.gz ma-agent-${VERSION}

	mv _build/ma-agent-${VERSION}.tar.gz _build/rpmbuild/SOURCES
	cp redhat/ma-agent.spec _build/rpmbuild/SPECS

	rpmbuild -ba _build/rpmbuild/SPECS/ma-agent.spec

	# npm install ./_npm

	# mkdir -p ./_tar/node_modules
	# cp -r node_modules/ma-agent ./_tar/node_modules/ma-agent
	# mkdir -p ./_tar/var

mac64: _tar npm
	tar -xvf node/node-v0.10.29-darwin-x64.tar.gz -C _tar
	mv _tar/node-v0.10.29-darwin-x64 _tar/node

	npm install ./_npm
	mkdir -p ./_tar/node_modules
	cp -r node_modules/ma-agent ./_tar/node_modules/ma-agent
	mkdir -p ./_tar/var

clean:
	rm -rf ./_build

