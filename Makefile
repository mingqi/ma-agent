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
	coffee -c -o _build/npm/lib ./src/node

_build/ma-agent.jar: 
	ant

rpm: _build npm _build/ma-agent.jar
	## node
	tar -xf node/node-v0.10.29-linux-x64.tar.gz -C _build/
	mv _build/node-v0.10.29-linux-x64 ${OPT_ROOT}/node
	find ${OPT_ROOT}/node/ -type f -exec chmod 644 {} +
	chmod 755 ${OPT_ROOT}/node/bin/node

	## jre
	tar -xf jre/jre-7u65-linux-x64.gz -C _build
	mv _build/jre1.7.0_65 ${OPT_ROOT}/jre
	find ${OPT_ROOT}/jre/ -type f -exec chmod 644 {} +
	chmod 755 ${OPT_ROOT}/jre/bin/java

	## jar
	mkdir -p ${OPT_ROOT}/lib
	cp _build/ma-agent.jar ${OPT_ROOT}/lib
	cp lib/*.jar ${OPT_ROOT}/lib

	## ma-agent npm
	rm -rf /tmp/npm /tmp/node_modules
	cp -r _build/npm /tmp/npm
	cd /tmp && cnpm install  ./npm
	mv /tmp/node_modules ${OPT_ROOT}/
	find ${OPT_ROOT}/node_modules -type f -exec chmod 644 {} +


	# bin var
	cp -r bin ${OPT_ROOT}
	chmod -R 755 ${OPT_ROOT}/bin
	mkdir ${OPT_ROOT}/var

	# etc
	mkdir -p ${ROOT}/etc/ma-agent
	mkdir -p ${ROOT}/etc/ma-agent/monitor.d
	cp conf/dev.conf ${ROOT}/etc/ma-agent/ma-agent.conf

	## init.d
	mkdir -p ${ROOT}/etc/init.d/
	cp init.d/ma-agent ${ROOT}/etc/init.d

	## tarball
	cd _build && tar -zcf ma-agent-${VERSION}.tar.gz ma-agent-${VERSION}

	mv _build/ma-agent-${VERSION}.tar.gz _build/rpmbuild/SOURCES
	cp redhat/ma-agent.spec _build/rpmbuild/SPECS

	rpmbuild -ba _build/rpmbuild/SPECS/ma-agent.spec

install: rpm
	sudo rpm -ihv _build/rpmbuild/RPMS/x86_64/ma-agent-${VERSION}-1.x86_64.rpm

rsync_dev:
	rsync -avz ./_build/rpmbuild/RPMS/x86_64/ma-agent-1.0.0-1.x86_64.rpm  mingqi@dev.monitorat.com:/var/tmp/

clean:
	rm -rf ./_build

linstall: _build/ma-agent.jar lib npm luninstall
	cp bin/* /opt/ma-agent/bin/	
	cp _build/ma-agent.jar /opt/ma-agent/lib
	cp lib/*.jar /opt/ma-agent/lib
	cp -r _build/npm/lib/ /opt/ma-agent/node_modules/ma-agent/lib
	cp -r node_modules/ /opt/ma-agent/node_modules/ma-agent/node_modules

luninstall:
	rm -rf /opt/ma-agent/bin/*
	rm -rf /opt/ma-agent/lib/*
	rm -rf /opt/ma-agent/node_modules/ma-agent/*