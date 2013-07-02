heaps.beam:	heaps.erl
			erlc +debug_info heaps.erl

all: 		heaps.beam

dialyzer: 	all
			dialyzer heaps.beam

dialyzer-upd: all
			dialyzer --add_to_plt heaps.beam
