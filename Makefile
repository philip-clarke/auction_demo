.PHONY: deps compile clean dev

ERL?=erl
REBAR?=./rebar

all: deps compile

deps:
	$(REBAR) get-deps
	$(REBAR) compile

compile:
	$(REBAR) compile

clean:
	rm -rf deps/
	$(REBAR) clean

dev: compile
	$(ERL) -pa $(CURDIR)/ebin $(CURDIR)/deps/*/ebin -s auction_demo_app