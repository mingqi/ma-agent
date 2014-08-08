#!/bin/bash
VERSION=`cat VERSION`

## tarball
./make-tarball.sh

## rpmbuild
mv _build/ma-agent-${VERSION}.tar.gz _build/rpmbuild/SOURCES
cp redhat/ma-agent.spec _build/rpmbuild/SPECS

cd _build/rpmbuild && rpmbuild -ba SPECS/ma-agent.spec
