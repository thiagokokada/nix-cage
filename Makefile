.DEFAULT_GOAL := all

root           = $(shell git rev-parse --show-toplevel)
version        = 1.0-$(shell git rev-parse --short HEAD)
os             = linux
arch           = amd64
scripts        = $(root)/scripts
build          = $(root)/build
builder        = sudo PATH=$(PATH) $(scripts)/build
gpg_key_id     = 650177753CFC13FA9490ED30887A0D14C7C55BD6
gh_user        = corpix
gh_repo        = devcage
image_uri      = $(gh_user).github.io/devcage

.PHONY: all
all: build test

.PHONY: build
build:: $(build)
	@if [ "$(shell git ls-files -m | wc -l)" != 0 ];                      \
	then                                                                  \
		echo "You have not commited your changes.";                   \
		echo "This will have affect on a version of the containers."; \
		echo "Please commit your changes.";                           \
		echo;                                                         \
		exit 1;                                                       \
	fi 1>&2

include */build.mk

$(build):
	mkdir -p "$(build)"

.PHONY: sign
sign: $(build)
	find $(build) -type f -name '*.aci'                  \
		| xargs -I{} bash -c '                       \
			set -e;                              \
			gpg2                                 \
				--default-key $(gpg_key_id)  \
				--armor                      \
				--output {}.asc              \
				--detach-sig {}              \
			&& gpg2                              \
				--default-key $(gpg_key_id)  \
				--verify {}.asc              \
				{}                           \
		'

.PHONY: tag
tag:
	git tag $(version)

.PHONY: release
release:
	[ ! -z $(GITHUB_TOKEN) ]
	git push origin --tags
	github-release release \
		-u $(gh_user)  \
		-r $(gh_repo)  \
		-t $(version)

.PHONY: upload
upload: $(build)
	[ ! -z $(GITHUB_TOKEN) ]
	find $(build) -type f -name '*.aci'            \
		| xargs -I{} bash -c '                 \
			set -e;                        \
			[ -e {} ]                      \
			&& [ -e {}.asc ]               \
			&& github-release upload       \
				-u $(gh_user)          \
				-r $(gh_repo)          \
				-t $(version)          \
				-n $$(basename {})     \
				-f {}                  \
			&& github-release upload       \
				-u $(gh_user)          \
				-r $(gh_repo)          \
				-t $(version)          \
				-n $$(basename {}).asc \
				-f {}.asc              \
		'

.PHONY: test
test:
	[ "$(shell ls $(build)/*.aci | wc -l)" -gt 0 ]
	find $(build) -type f -name '*.aci'             \
		| xargs -I{} bash -c '                  \
			set -e;                         \
			sudo rkt --insecure-options=all \
				run {}                  \
				--exec=/bin/sh --       \
				-c "echo 1"             \
		'

.PHONY: clean
clean:
	rm -rf $(build)
	sudo rm -rf .acbuild
