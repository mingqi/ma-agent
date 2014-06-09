all: mygodbuild
	cp -r bin mygodbuild
	cp -r etc mygodbuild
	cp -r lib mygodbuild

mygodbuild:
	mkdir mygodbuild

clean:
	rm -rf mygodbuild