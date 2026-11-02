:- begin_tests(financial_instruments).
:- use_module(financial_instruments).

test(four_pillars_have_categories) :-
    forall(between(1,4,P), recommended_category(P,_)).

test(three_examples_for_every_category) :-
    forall(member(C,[conto_remunerato,etf_monetario,titoli_stato,etf_obbligazionario,etf_azionario,etc_etn]),
           (findall(N, instrument_example(C,N,_,_,_,_,_), Ns), length(Ns,3))).

test(valid_urls_and_identifiers) :-
    forall(instrument_example(_,Name,Id,Metric,Value,Note,URL),
           (string(Name),string(Id),string(Metric),string(Value),string(Note),string(URL),
            sub_string(URL,0,8,_,"https://"))).

test(invalid_pillar_is_handled) :-
    with_output_to(string(Output),show_pillar_instruments(8)),
    sub_string(Output,_,_,_,"non valido").

:- end_tests(financial_instruments).

% Avviare dalla directory del progetto:
% ?- [test_financial_instruments].
% ?- run_tests(financial_instruments).
