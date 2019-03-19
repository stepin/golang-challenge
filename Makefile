.PHONY: all test build clean deps run rund setup package release help

PROJECTNAME=$(shell basename "$(PWD)")
export GO111MODULE := on

all: test build

## test: Run code reformat, tests, and lints.
test:
	go fmt
	go vet
	go test
	golangci-lint run --enable-all
	find . -name '*.go' | xargs grep -inHwE '(FIXME|TODO|HACK|XXX|BUG)' || true
	go mod tidy

## build: Build dev version for current OS.
build: deps
	go install -race

## clean: Clean folder.
clean:
	rm -rf ${PROJECTNAME} ${PROJECTNAME}.exe dist/ || true

## deps: Load dependent Go packages.
deps:
	go mod download
	go generate ./...

## run: Start server.
run: build
	~/go/bin/${PROJECTNAME}

## rund: Start server in the Docker.
rund: package
	docker run --rm -it -p8080:8080 stepin/${PROJECTNAME}:dev

## setup: Download extra packages for development and build.
setup:
	#ide
	go get -v -u golang.org/x/tools/cmd/gorename
	go get -v -u github.com/rogpeppe/godef
	go get -v -u github.com/jstemmer/gotags
	go get -v -u github.com/nsf/gocode
	go get -v -u golang.org/x/tools/cmd/guru

	#use brew or other tool
	golangci-lint -v

## package: Build docker image.
package:
	docker build -t stepin/golang-challenge:dev .

## release: Package and upload to docker image to hub.docker.com.
release: package
	docker tag stepin/${PROJECTNAME}:dev stepin/${PROJECTNAME}:latest
	docker push -t stepin/${PROJECTNAME}:latest

## help: This help.
help: Makefile
	@echo
	@echo " Choose a command run in "$(PROJECTNAME)":"
	@echo
	@sed -n 's/^##//p' $< | column -t -s ':' |  sed -e 's/^/ /'
	@echo