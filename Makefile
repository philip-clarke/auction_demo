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

demo: compile
	$(ERL) -pa $(CURDIR)/ebin $(CURDIR)/deps/*/ebin -s sync -s auction_demo_app

nosmp: compile
	$(ERL) -pa $(CURDIR)/ebin $(CURDIR)/deps/*/ebin -s sync -s auction_demo_app -smp disable 

demo8: compile
	$(ERL) -pa $(CURDIR)/ebin $(CURDIR)/deps/*/ebin -s sync -s auction_demo_app +S 8:8

demo16: compile
	$(ERL) -pa $(CURDIR)/ebin $(CURDIR)/deps/*/ebin -s sync -s auction_demo_app +S 16:16
