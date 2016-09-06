all: tests.js

tests.js: FORCE $(shell find src test -type f -name '*.elm' -o -name '*.js')
	elm-make --yes --warn
	cd test && elm-make Test.elm --yes --warn --output=../$@ && cd ..
	@ node $@

FORCE:
