:- begin_tests(financial_instruments_integration).

:- use_module(interface, [demo/0]).
:- use_module(inference_engine, [reset_system/0, put_fact/2, get_fact/2]).
:- use_module(financial_instruments, [active_pillar/3, show_personalized_instruments/0,
                                      recommended_category/2, instrument_example/7]).

seed(Current, Monthly) :-
    reset_system,
    put_fact(allocations, Current),
    put_fact(monthly_allocations, Monthly).

test(current_only, [setup(seed(allocation(100,0,0,0), allocation(0,0,0,0))), cleanup(reset_system)]) :-
    findall(P, active_pillar(P,_,_), Pillars),
    assertion(Pillars == [1]).

test(next_month_only, [setup(seed(allocation(0,0,0,0), allocation(0,250,0,20))), cleanup(reset_system)]) :-
    findall(P, active_pillar(P,_,_), Pillars),
    assertion(Pillars == [2,4]).

test(mixed_allocation, [setup(seed(allocation(400,500,0,0), allocation(0,100,40,0))), cleanup(reset_system)]) :-
    findall(P-C-M, active_pillar(P,C,M), Actual),
    assertion(Actual == [1-400-0,2-500-100,3-0-40]).

test(zero_allocation, [setup(seed(allocation(0,0,0,0), allocation(0,0,0,0))), cleanup(reset_system)]) :-
    assertion(\+ active_pillar(_,_,_)),
    with_output_to(string(Output), show_personalized_instruments),
    assertion(sub_string(Output,_,_,_,"Nessun pilastro")).

test(three_examples_per_category) :-
    forall(recommended_category(_P, Category),
           (findall(Id, instrument_example(Category,_,Id,_,_,_,_), Entries),
            length(Entries, 3))).

test(demo_runs, [cleanup(reset_system)]) :-
    with_output_to(string(_), demo),
    get_fact(allocations, allocation(_,_,_,_)),
    get_fact(monthly_allocations, allocation(_,_,_,_)).

:- end_tests(financial_instruments_integration).
