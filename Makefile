all: tests.js

tests.js: FORCE $(shell find src test -type f -name '*.elm' -o -name '*.js')
	elm-make --yes --warn
	elm-make test/Test.elm --yes --warn --output=$(TEMPFILE)
	@ node $(TEMPFILE)

FORCE:

TEMPFILE := $(shell mktemp "$$TMPDIR/$$(uuidgen).js")
