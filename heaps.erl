-module(heaps).
%% (c) 2011-2013 Wojciech Kaczmarek <wk@dualtech.com.pl>. All rights reserved.
%% Released under the BSD 2-clause license - see this for details:
%% http://github.com/herenowcoder/erl-heaps/blob/master/LICENSE
-export([ add/3, add/4, contains_value/2, delete_by_value/2, delete/3,
          is_empty/1, mapping/2, new/0, take_min/1 ]).

-type pri() :: any().
-type heap_tree_key() :: tuple(pri(), reference()).
-type heap() :: tuple(gb_tree(), dict()).
-export_type([heap/0]).

-spec new() -> heap().
new() ->
    {gb_trees:empty(), dict:new()}.

-spec is_empty(heap()) -> boolean().
is_empty(_Heap={T, _}) ->
    gb_trees:size(T) == 0.

-spec add(pri(), any(), heap()) -> heap().
add(Pri, Val, Heap) ->
    add(Pri, Val, none, Heap).

-spec add(pri(), any(), any(), heap()) -> heap().
add(Pri, Val, Aux, Heap={T0,R0}) ->
    false = contains_value(Val, Heap),
    TreeKey = {Pri, make_ref()},
    {gb_trees:insert(TreeKey, Val, T0),
     dict:store(Val, {TreeKey, Aux}, R0)}.

-spec take_min(heap()) -> tuple(pri(), any(), heap()).
take_min(_Heap={T0,R0}) ->
    {{Pri,_}, Val, T1} = gb_trees:take_smallest(T0),
    {Pri, Val, {T1, r_delete(Val, R0)}}.

-spec mapping(any(), heap()) -> tuple(heap_tree_key(), any()).
mapping(Val, _Heap={_T,R}) ->
    {_TreeKey, _Aux} = dict:fetch(Val, R).
-compile({inline, mapping/2}).

-spec delete_by_value(any(), heap()) -> heap().
delete_by_value(Val, Heap) ->
    {TreeKey,_} = mapping(Val, Heap),
    delete(TreeKey, Val, Heap).

-spec delete(heap_tree_key(), any(), heap()) -> heap().
delete(TreeKey, Val, _Heap={T0,R0}) ->
    {gb_trees:delete(TreeKey, T0),  r_delete(Val, R0)}.
-compile({inline, delete/3}).

-spec r_delete(any(), dict()) -> dict().
r_delete(Val, R0) ->
    dict:update(Val, fun({_,Aux})-> {none,Aux} end, R0).
-compile({inline, r_delete/2}).

-spec contains_value(any(), heap()) -> boolean().
contains_value(Val, _Heap={_,R}) ->
    case dict:find(Val, R) of
        {ok, {TreeKey,_}} when TreeKey =/= none -> true;
        _ -> false
    end.
            
-compile({inline, contains_value/2}).


-include_lib("eunit/include/eunit.hrl").
-define(IS(X), ?_assert(X)).
-define(EQ(X,Y), ?_assertEqual(X,Y)).
-define(ERR(T,X), ?_assertError(T,X)).

simple_test_() ->
    H0 = new(),
    H1 = add(1, a, H0),
    H2 = add(2, b, H1),
    {P1, Va, H3} = take_min(H2),
    H4 = delete_by_value(b, H3),
    [ 
        ?IS( not contains_value(any, H0) ),
        ?ERR( badarg, delete_by_value(any, H0) ),
        ?ERR( function_clause, take_min(H0) ),
        ?IS( contains_value(a, H1) ),
        ?ERR( {badmatch,true}, add(anypri, a, H1) ),
        ?IS( contains_value(a, H2) ),
        ?IS( contains_value(b, H2) ),
        ?IS( not contains_value(foo, H2) ),
        ?EQ( P1, 1 ), ?EQ( Va, a ),
        ?IS( not contains_value(a, H3) ),
        %%?ERR( badarg, delete_by_value(a, H3) ),
        ?IS( contains_value(b, H3) ),
        ?IS( not contains_value(b, H4) ),
        %%?ERR( badarg, delete_by_value(a, H4) ),
        []].
