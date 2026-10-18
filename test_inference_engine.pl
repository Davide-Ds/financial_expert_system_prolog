:- module(test_all, [run_financial_tests/0, run_negative_tests/0, run_all_tests/0]).

:- use_module(library(plunit)).
:- use_module(inference_engine, [infer/0, reset_system/0, put_fact/2, get_fact/2, trace_step/4]).
:- use_module(interface, []).

% Run: ?- [test_all].
%      ?- run_financial_tests.   % 16 inference tests
%      ?- run_negative_tests.    % 13 input validation tests
%      ?- run_all_tests.         % all 29 tests

run_financial_tests :- run_tests([financial_engine]).
run_negative_tests :- run_tests([negative_inputs]).
run_all_tests :- run_tests([financial_engine, negative_inputs]).

seed(Age, Employment, Partner, PartnerEmployment, PartnerSalary,
     Income, Expenses, Savings, Dependents, Goals, Psychology) :- put_fact(age, Age),
                                                                  put_fact(employment, Employment),
                                                                  put_fact(partner, Partner),
                                                                  put_fact(partner_employment, PartnerEmployment),
                                                                  put_fact(partner_salary, PartnerSalary),
                                                                  put_fact(income, Income),
                                                                  put_fact(expenses, Expenses),
                                                                  put_fact(savings, Savings),
                                                                  put_fact(dependents, Dependents),
                                                                  put_fact(goals, Goals),
                                                                  put_fact(psychological_risk, Psychology).

% Defaults are realistic and valid for the engine.
base(Income, Expenses, Savings, Goals) :- seed(30, permanent, no, none, 0, Income, Expenses, Savings, 0, Goals, calm_wait).

% near/2 evaluates arithmetic expressions on both sides before comparison.
near(X, Y) :- XValue is X, YValue is Y, abs(XValue - YValue) < 0.000001.

current(P1, P2, P3, P4) :- get_fact(allocations, allocation(P1, P2, P3, P4)).

monthly(P1, P2, P3, P4) :- get_fact(monthly_allocations, allocation(P1, P2, P3, P4)).

% Generic properties every successful inference should satisfy.
check_invariants :- get_fact(savings, Savings),
                    get_fact(monthly_surplus, Surplus),
                    get_fact(targets, targets(T1, T2, T3)),
                    current(A1, A2, A3, A4), monthly(M1, M2, M3, M4),
                    get_fact(remaining_gaps, gaps(G1, G2, G3)),
                    assertion(near(A1+A2+A3+A4, Savings)),
                    assertion(near(M1+M2+M3+M4, Surplus)),
                    forall(member(V, [A1,A2,A3,A4,M1,M2,M3,M4,G1,G2,G3]), assertion(V >= -0.000001)),
                    assertion(A1 =< T1 + 0.000001),
                    assertion(A2 =< T2 + 0.000001),
                    assertion(A3 =< T3 + 0.000001),
                    assertion(near(G1, max(0,T1-A1-M1))),
                    assertion(near(G2, max(0,T2-A2-M2))),
                    assertion(near(G3, max(0,T3-A3-M3))).

:- begin_tests(financial_engine).

% This reproduces the failure income=0.
test(zero_income_with_positive_expenses,
     [setup(reset_system), cleanup(reset_system)]) :- seed(66, none, no, none, 0, 0, 123, 3456.667, 0, [], sell),
                                                      assertion(infer),
                                                      get_fact(expense_score, Score),
                                                      assertion(near(Score, 0)),
                                                      get_fact(monthly_surplus, Surplus),
                                                      assertion(near(Surplus, 0)),
                                                      check_invariants.

% test income > 0 and expenses = 0.
test(zero_expenses_with_positive_income,
     [setup(reset_system), cleanup(reset_system)]) :- base(2000, 0, 5000, []), assertion(infer),
                                                      get_fact(savings_score, Score),
                                                      assertion(near(Score, 1)),
                                                      get_fact(targets, targets(T1, T2, T3)),
                                                      assertion(near(T1, 0)), assertion(near(T2, 0)),
                                                      assertion(near(T3, 0)),
                                                      current(_, _, _, P4),
                                                      assertion(near(P4, 5000)),
                                                      check_invariants.

test(all_financial_amounts_zero,
     [setup(reset_system), cleanup(reset_system)]) :- base(0, 0, 0, []), assertion(infer),
                                                      current(A1,A2,A3,A4), monthly(M1,M2,M3,M4),
                                                      assertion(near(A1+A2+A3+A4, 0)),
                                                      assertion(near(M1+M2+M3+M4, 0)),
                                                      check_invariants.

test(zero_savings_positive_surplus,
     [setup(reset_system), cleanup(reset_system)]) :- base(2000, 1000, 0, []), assertion(infer),
                                                      current(A1,A2,A3,A4), 
                                                      assertion(near(A1+A2+A3+A4, 0)),
                                                      monthly(M1,M2,M3,M4),
                                                      assertion(near(M1, 1000)),
                                                      assertion(near(M2+M3+M4, 0)),
                                                      check_invariants.

test(zero_surplus_income_equals_expenses,
     [setup(reset_system), cleanup(reset_system)]) :- base(1300, 1300, 5000, []), assertion(infer),
                                                      monthly(M1,M2,M3,M4), 
                                                      assertion(near(M1+M2+M3+M4, 0)),
                                                      check_invariants.

test(zero_surplus_income_less_than_expenses,
     [setup(reset_system), cleanup(reset_system)]) :- base(500, 1300, 5000, []),
                                                      assertion(infer),
                                                      get_fact(monthly_surplus, S),
                                                      assertion(near(S, 0)),
                                                      check_invariants.

test(zero_goals_empty_list,
     [setup(reset_system), cleanup(reset_system)]) :- base(2000, 1000, 4000, []),
                                                      assertion(infer),
                                                      get_fact(targets, targets(_,_,T3)),
                                                      assertion(near(T3, 0)),
                                                      check_invariants.

test(goal_with_zero_amount,
     [setup(reset_system), cleanup(reset_system)]) :- base(2000, 1000, 4000, [goal(1,"Free course",0,2)]),
                                                      assertion(infer),
                                                      get_fact(targets, targets(_,_,T3)),
                                                      assertion(near(T3, 0)),
                                                      check_invariants.

test(zero_dependents_and_partner_no,
     [setup(reset_system), cleanup(reset_system)]) :- seed(26, temporary, no, none, 0, 1800, 1300, 5000, 
                                                            0, [goal(1,"Car",10000,2)], worried_wait),
                                                      assertion(infer),
                                                      get_fact(family_score, Family),
                                                      get_fact(partner_score, Partner),
                                                      assertion(near(Family, 1)),
                                                      assertion(near(Partner, 0)),
                                                      check_invariants.

test(monthly_goes_to_emergency_after_p1,
     [setup(reset_system), cleanup(reset_system)]) :- base(1800, 1300, 1300, []),
                                                      assertion(infer),
                                                      monthly(M1,M2,M3,M4),
                                                      assertion(near(M1, 0)),
                                                      assertion(near(M2, 500)),
                                                      assertion(near(M3+M4, 0)),
                                                      check_invariants.

test(monthly_surplus_can_cross_multiple_gaps,
     [setup(reset_system), cleanup(reset_system)]) :- base(5000, 1000, 0, [goal(1,"Car",1000,2)]),
                                                      assertion(infer),
                                                      get_fact(targets, targets(T1,_T2,T3)),
                                                      monthly(M1,M2,M3,M4),
                                                      assertion(near(M1,T1)),
                                                      assertion(near(M2,3000)),
                                                      assertion(near(M3,0)),
                                                      assertion(near(M4,0)),
                                                      assertion(near(T3,1000)),
                                                      check_invariants.

test(all_targets_met_surplus_to_p4,
     [setup(reset_system), cleanup(reset_system)]) :- base(2000, 1000, 100000, [goal(1,"Car",1000,2)]),
                                                      assertion(infer),
                                                      monthly(M1,M2,M3,M4),
                                                      assertion(near(M1+M2+M3,0)),
                                                      assertion(near(M4,1000)),
                                                      check_invariants.

test(decimal_amounts,
     [setup(reset_system), cleanup(reset_system)]) :- base(2000.50, 123.75, 3456.667, [goal(1,"Laptop",499.99,3)]),
                                                      assertion(infer),
                                                      get_fact(targets, targets(_,_,T3)),
                                                      assertion(near(T3,499.99)),
                                                      check_invariants.

test(goals_horizon_10_included,
     [setup(reset_system), cleanup(reset_system)]) :- base(2000,1000,25000,[goal(1,"Degree",700,10)]),
                                                      assertion(infer),
                                                      get_fact(targets, targets(_,_,T3)),
                                                      assertion(near(T3,700)),
                                                      check_invariants.

% Interface should reject >10. Engine currently filters it out.
test(goals_horizon_over_10_excluded_by_engine,  
     [setup(reset_system), cleanup(reset_system)]) :- base(2000,1000,25000,[goal(1,"Long goal",700,11)]),
                                                      assertion(infer),
                                                      get_fact(targets, targets(_,_,T3)),
                                                      assertion(near(T3,0)),
                                                      check_invariants.

test(trace_records_new_allocation,
     [setup(reset_system), cleanup(reset_system)]) :- base(2000,1000,5000,[]),
                                                      assertion(infer),
                                                      assertion(trace_step(monthly_allocations,_,_,_)),
                                                      check_invariants.

:- end_tests(financial_engine).


% =========================================================
% INPUT VALIDATION TESTS
% =========================================================

% Temporarily replace the user_input/user_output/user_error streams to simulate
% keyboard answers without requiring manual intervention.

with_fake_input(Text, Goal) :- setup_call_cleanup(open_string(Text, Input),
                                                  with_fake_streams(Input, Goal),
                                                  close(Input)
                                                  ).

with_fake_streams(Input, Goal) :- current_input(OldInput), current_output(OldOutput),
                                  stream_property(OldError, alias(user_error)),
                                  setup_call_cleanup(open_null_stream(NullOutput),
                                                     setup_call_cleanup(set_prolog_IO(Input, NullOutput, OldError),
                                                                        call(Goal),
                                                                        set_prolog_IO(OldInput, OldOutput, OldError)
                                                                       ),
                                                      close(NullOutput)
                                                     ).

:- begin_tests(negative_inputs).

% Income: -1000 must be rejected; 0 must be accepted.
test(negative_income_rejected,
     [setup(reset_system), cleanup(reset_system)]) :- with_fake_input("-1000\n0\n", interface:ask_money('Income', income)),
                                                      get_fact(income, V),
                                                      assertion(V =:= 0).

% Monthly essential expenses: -0.01 must be rejected.
test(negative_expenses_rejected,
     [setup(reset_system), cleanup(reset_system)]) :- with_fake_input("-0.01\n123.45\n", interface:ask_money('Expenses', expenses)),
                                                      get_fact(expenses, V),
                                                      assertion(V =:= 123.45).

% Savings: reject a negative decimal and accept exactly zero.
test(negative_savings_rejected,
     [setup(reset_system), cleanup(reset_system)]) :- with_fake_input("-3456.667\n0\n", interface:ask_money('Savings', savings)),
                                                      get_fact(savings, V),
                                                      assertion(V =:= 0).

% Partner income: same nonnegative rule.
test(negative_partner_salary_rejected,
     [setup(reset_system), cleanup(reset_system)]) :- with_fake_input("-250\n0\n", interface:ask_money('Partner salary', partner_salary)),
                                                      get_fact(partner_salary, V),
                                                      assertion(V =:= 0).

% Age: negative age invalid, minimum valid value 18.
test(negative_age_rejected,
     [setup(reset_system), cleanup(reset_system)]) :- with_fake_input("-1\n18\n", interface:ask_int('Age', age, 18, 150)),
                                                      get_fact(age, V),
                                                      assertion(V =:= 18).

% Even age 0 is invalid (unlike financial amounts).
test(zero_age_rejected,
     [setup(reset_system), cleanup(reset_system)]) :- with_fake_input("0\n26\n", interface:ask_int('Age', age, 18, 150)),
                                                      get_fact(age, V),
                                                      assertion(V =:= 26).

% Dependents: negative is invalid, zero is valid.
test(negative_dependents_rejected,
     [setup(reset_system), cleanup(reset_system)]) :- with_fake_input("-3\n0\n", interface:ask_int('Dependents', dependents, 0, 200)),
                                                      get_fact(dependents, V),
                                                      assertion(V =:= 0).

% Employment menu accepts only 1, 2, 3.
test(negative_employment_choice_rejected,
     [setup(reset_system), cleanup(reset_system)]) :- with_fake_input("-1\n3\n",interface:ask_choice('Employment', employment,[1-permanent,2-temporary,3-none])),
                                                      get_fact(employment, V),
                                                      assertion(V == none).

% Psychological risk menu accepts only 1, 2, 3.
test(negative_psychological_choice_rejected,
     [setup(reset_system), cleanup(reset_system)]) :- with_fake_input("-2\n1\n", interface:ask_choice('Risk', psychological_risk,[1-sell,2-worried_wait,3-calm_wait])),
                                                      get_fact(psychological_risk, V),
                                                      assertion(V == sell).

% Goal amount: -100 must be rejected; 0 ends goal collection.
test(negative_goal_amount_rejected,
     [setup(reset_system), cleanup(reset_system)]) :- with_fake_input("-100\n0\n", interface:goals),
                                                      get_fact(goals, Goals),
                                                      assertion(Goals == []).

% Goal years: negative and 0 must both be rejected; 2 accepted.
test(negative_or_zero_goal_years_rejected) :- with_fake_input("-5\n0\n2\n", interface:ask_goal_years(Years)),
                                              assertion(Years =:= 2).

% Goal amount -0.01 rejected; valid goal is then recorded correctly.
test(negative_goal_followed_by_valid_goal,
     [setup(reset_system), cleanup(reset_system)]) :- with_fake_input("-0.01\n500\nLaptop\n3\n0\n", interface:goals),
                                                      get_fact(goals, Goals),
                                                      assertion(Goals == [goal(1,"Laptop",500,3)]).

% Zero is valid for all money fields.
test(zero_money_values_accepted,
     [setup(reset_system), cleanup(reset_system)]) :- with_fake_input("0\n", interface:ask_money('Income', income)),
                                                      with_fake_input("0\n", interface:ask_money('Expenses', expenses)),
                                                      with_fake_input("0\n", interface:ask_money('Savings', savings)),
                                                      get_fact(income, I), get_fact(expenses, E), get_fact(savings, S),
                                                      assertion(I =:= 0), assertion(E =:= 0), assertion(S =:= 0).

:- end_tests(negative_inputs).
