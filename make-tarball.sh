#!/bin/bash -x
VERSION=`cat VERSION`
ROOT=_build/ma-agent-${VERSION}
# OPT_ROOT=${ROOT}/opt/ma-agent
OPT_ROOT=${ROOT}
NODE_VERSION='0.10.29'
JRE_VERSION='7u65'
ARCH=`uname -m`
if [ $ARCH = 'x86_64' ]; then
  NODE_ARCH='x64'
  JRE_ARCH='x64'
else
  NODE_ARCH='x86'
  JRE_ARCH='i586'
fi
NODE=node-v${NODE_VERSION}-linux-${NODE_ARCH}
JRE=jre-${JRE_VERSION}-linux-${JRE_ARCH}

rm -rf _build

mkdir -p _build/tar
mkdir -p _build/npm/lib
mkdir -p $OPT_ROOT

for rpm_sub_dir in SPECS SOURCES RPMS SRPMS BUILD BUILDROOT; do
  mkdir -p _build/rpmbuild/$rpm_sub_dir
done

# jar
ant

# node
tar -xf resources/node/$NODE.tar.gz -C _build/
mv _build/$NODE ${OPT_ROOT}/node
# find ${OPT_ROOT}/node/ -type f -exec chmod 644 {} +
# chmod 755 ${OPT_ROOT}/node/bin/node ## jre

# jre
tar -xf resources/jre/$JRE.gz -C _build
mv _build/jre1.7.0_65 ${OPT_ROOT}/jre
# find ${OPT_ROOT}/jre/ -type f -exec chmod 644 {} +
# chmod 755 ${OPT_ROOT}/jre/bin/java

## jar
mkdir -p ${OPT_ROOT}/lib
cp _build/ma-agent.jar ${OPT_ROOT}/lib
cp resources/jars/*.jar ${OPT_ROOT}/lib

## npm
coffee -c -o _build/npm/lib ./src/node
cp index.js ./_build/npm
cp ./package.json ./_build/npm

rm -rf /tmp/npm /tmp/node_modules
cp -r _build/npm /tmp/npm
pushd /tmp && npm install  ./npm
popd
mv /tmp/node_modules ${OPT_ROOT}/
# find ${OPT_ROOT}/node_modules -type f -exec chmod 644 {} +

# bin var
cp -r bin ${OPT_ROOT}
chmod -R 755 ${OPT_ROOT}/bin
mkdir ${OPT_ROOT}/var

# etc
mkdir -p ${ROOT}/res/etc/ma-agent
mkdir -p ${ROOT}/res/etc/ma-agent/monitor.d
cp conf/dev.conf ${ROOT}/res/etc/ma-agent/ma-agent.conf

## init.d
# mkdir -p ${ROOT}/res/etc/init.d/
# cp init.d/ma-agent ${ROOT}/res/etc/init.d

## tarball
pushd _build && tar -zcf ma-agent-${VERSION}.tar.gz ma-agent-${VERSION}
popd
