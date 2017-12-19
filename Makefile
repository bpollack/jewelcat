all:
	go build ./cmd/jewelcat

release:
	gox -os="darwin linux" -arch="amd64" -ldflags "-X main.Version=$$RELEASE" ./cmd/jewelcat
	mv jewelcat_linux_amd64 jewelcat
	tar czvf jewelcat-$$RELEASE-linux-amd64.tar.gz jewelcat
	mv jewelcat_darwin_amd64 jewelcat
	zip jewelcat-$$RELEASE-darwin-amd64.zip jewelcat

.PHONY: all release
