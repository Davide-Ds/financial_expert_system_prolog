% Financial Expert System - Fundamentals of AI
% SWI-Prolog. Educational decision-support prototype.

:- dynamic wm/2, trace_step/4.

main :-
    reset_system, banner, collect_inputs, infer, result, explanation_menu.

reset_system :- retractall(wm(_,_)), retractall(trace_step(_,_,_,_)).
banner :-
    nl, writeln('=== FINANCIAL EXPERT SYSTEM ==='),
    writeln('Educational Prolog expert system; not financial advice.'), nl.

collect_inputs :-
    ask_int('Age',age,18,100),
    ask_choice('Employment 1=permanent 2=temporary 3=none',employment,
                [1-permanent,2-temporary,3-none]),
    ask_money('Personal monthly net income (EUR)',income),
    ask_money('Essential monthly expenses (EUR)',expenses),
    ask_money('Current savings (EUR)',savings),
    ask_yes_no('Partner?',partner), partner_inputs,
    ask_int('Dependents',dependents,0,20),
    goals,
    ask_choice('Reaction to >=10% investment loss: 1=sell 2=worried wait 3=calm wait',
                psychological_risk,[1-sell,2-worried_wait,3-calm_wait]).

partner_inputs :-
    wm(partner,no), !, assertz(wm(partner_employment,none)),
    assertz(wm(partner_salary,0)).
partner_inputs :-
    ask_choice('Partner employment 1=permanent 2=temporary 3=none',
                partner_employment,[1-permanent,2-temporary,3-none]),
    ask_money('Partner monthly net income (EUR)',partner_salary).

ask_int(L,K,Min,Max) :-
    repeat, format('~w: ',[L]), read_line_to_string(user_input,S),
    catch(number_string(N,S),_,fail), integer(N), N>=Min, N=<Max, !,
    assertz(wm(K,N)).
ask_int(L,K,Min,Max) :- writeln('Invalid value.'), ask_int(L,K,Min,Max).

ask_money(L,K) :-
    repeat, format('~w: ',[L]), read_line_to_string(user_input,S),
    catch(number_string(N,S),_,fail), number(N), N>=0, !,
    V is round(N*100)/100, assertz(wm(K,V)).
ask_money(L,K) :- writeln('Invalid value.'), ask_money(L,K).

ask_yes_no(L, K) :-
	repeat,
	format('~w [y/n]: ', [L]),
	read_line_to_string(user_input, S0),
	string_lower(S0, S),
	((S = "y"; S = "yes") -> assertz(wm(K, yes)), !;
	(S = "n"; S = "no") -> assertz(wm(K, no)), !;
	writeln('Use y or n.'), fail).

ask_choice(L,K,Pairs) :-
    repeat, format('~w: ',[L]), read_line_to_string(user_input,S),
    catch(number_string(N,S),_,fail), member(N-V,Pairs), !,
    assertz(wm(K,V)).
ask_choice(L,K,P) :- writeln('Invalid choice.'), ask_choice(L,K,P).

goals :-
    writeln('Future goals: enter 0 as amount to stop.'),
    collect_goals(1,[],G), assertz(wm(goals,G)).

collect_goals(I,A,G) :-
    format('Goal ~w amount (EUR): ',[I]), read_line_to_string(user_input,S),
    catch(number_string(N,S),_,fail), N>=0, !,
    (N=:=0 -> reverse(A,G)
    ; format('Description: '), read_line_to_string(user_input,D),
      ask_int('Years until goal (max 10) ',dummy_year,1,10), retract(wm(dummy_year,Y)),
      V is round(N*100)/100,
      I1 is I + 1,
      collect_goals(I1,[goal(I,D,V,Y)|A],G)).

collect_goals(I,A,G) :- writeln('Invalid amount.'), collect_goals(I,A,G).

% ---------------- KNOWLEDGE BASE ----------------

employment_score(permanent,1.0).
employment_score(temporary,0.55).
employment_score(none,0.10).
partner_score(no,0.0).
partner_score(yes,0.20) :- wm(partner_employment,permanent), !.
partner_score(yes,0.10) :- wm(partner_employment,temporary), !.
partner_score(yes,0.0).
psych_score(sell,0.0).
psych_score(worried_wait,0.5).
psych_score(calm_wait,1.0).

infer :-
    employment, partner, savings_score, expense_score, family_score, age_score,
    resilience, psychology, combined, surplus, emergency, allocation.

employment :-
    wm(employment,E), employment_score(E,S),
    assertz(wm(employment_score,S)),
    tr(employment_score,S,'Employment stability','permanent=1.00, temporary=0.55, none=0.10').

partner :-
    wm(partner,P), partner_score(P,S),
    assertz(wm(partner_score,S)),
    tr(partner_score,S,'Partner support','permanent=0.20, temporary=0.10, otherwise=0').

savings_score :-
    wm(savings,S), wm(expenses,E), E>0,
    M is min(12,S/E), V is min(1.0,M/12),
    assertz(wm(savings_score,V)),
    tr(savings_score,V,'Savings coverage','min(1, months covered/12)').

expense_score :-
    wm(income,I), wm(expenses,E), I>0,
    V is 1-min(1,E/I), assertz(wm(expense_score,V)),
    tr(expense_score,V,'Essential expenses versus personal income',
       '1-min(1,expenses/income)').

family_score :-
    wm(dependents,D), V is max(0,1-min(1,D/4)),
    assertz(wm(family_score,V)),
    tr(family_score,V,'Number of dependents','1-min(1,dependents/4)').

age_score :-
    wm(age,A),
    (A<30->V=0.85;A<45->V=0.70;A<60->V=0.55;V=0.40),
    assertz(wm(age_score,V)), tr(age_score,V,'Age context','small heuristic weight').

resilience :-
    wm(employment_score,E), wm(partner_score,P), wm(savings_score,S),
    wm(expense_score,X), wm(family_score,F), wm(age_score,A),
    V0 is 0.30*E+0.10*P+0.25*S+0.20*X+0.10*F+0.05*A,
    V is max(0,min(1,V0)), assertz(wm(financial_resilience,V)),
    tr(financial_resilience,V,'Objective financial situation',
       'weighted employment/partner/savings/expenses/family/age').

psychology :-
    wm(psychological_risk,P), psych_score(P,V),
    assertz(wm(risk_tolerance,V)),
    tr(risk_tolerance,V,'Reaction to a >=10% loss',
       'sell=0.00, worried_wait=0.50, calm_wait=1.00').

combined :-
    wm(financial_resilience,F), wm(risk_tolerance,P),
    V is 0.55*F+0.45*P, assertz(wm(risk_index,V)),
    tr(risk_index,V,'Financial resilience and psychological tolerance',
       '0.55*resilience + 0.45*risk_tolerance').

surplus :-
    wm(income,I), wm(expenses,E), V is max(0,I-E),
    assertz(wm(monthly_surplus,V)),
    tr(monthly_surplus,V,'Personal income minus essential expenses',
       'max(0,income-expenses)').

emergency :-
    wm(financial_resilience,F),
    (F<0.30->M=12;F<0.50->M=9;F<0.70->M=6;F<0.85->M=4;M=3),
    assertz(wm(emergency_months,M)),
    tr(emergency_months,M,'Financial resilience','3/4/6/9/12 month heuristic bands').

goal_total(T) :-
    wm(goals,G), findall(A,(member(goal(_,_,A,Y),G),Y=<10),L), sum_list(L,T).

allocation :-
    wm(expenses,E), wm(emergency_months,M), wm(savings,S), goal_total(G),
    T1 is E, T2 is E*M, T3 is G,
    A1 is min(S,T1), R1 is S-A1,
    A2 is min(R1,T2), R2 is R1-A2,
    A3 is min(R2,T3), A4 is max(0,R2-A3),
    assertz(wm(targets,targets(T1,T2,T3))),
    assertz(wm(allocations,allocation(A1,A2,A3,A4))),
    tr(allocations,allocation(A1,A2,A3,A4),'Four-pillar allocation',
       'current savings: P1 -> P2 -> P3 -> P4').

% ---------------- PRESENTATION ----------------

result :-
    wm(financial_resilience,F), wm(risk_tolerance,P), wm(risk_index,R),
    wm(monthly_surplus,S), wm(emergency_months,M),
    wm(targets,targets(T1,T2,T3)), wm(allocations,allocation(A1,A2,A3,A4)),
    nl,writeln('=== RESULT ==='),
    format('Financial resilience: ~2f / 1.00~n',[F]),
    format('Psychological risk tolerance: ~2f / 1.00~n',[P]),
    format('Combined risk index: ~2f / 1.00~n',[R]),
    format('Monthly surplus: EUR ~2f~n',[S]),
    format('Emergency target: ~w months~n',[M]),nl,
    writeln('CURRENT SAVINGS ALLOCATION'),
    format('Pillar 1 ordinary liquidity: EUR ~2f (recommended target ~2f)~n',[A1,T1]), % allocation equal target if there is enough savings
    format('Pillar 2 emergency fund:     EUR ~2f (recommended target ~2f)~n',[A2,T2]),
    format('Pillar 3 future goals:       EUR ~2f (recommended target ~2f)~n',[A3,T3]),
    format('Pillar 4 long term:          EUR ~2f~n',[A4]),nl,
    writeln('Pillar 3 goals (<=10 years):'), show_goals.

show_goals :-
    wm(goals,G), (G=[]->writeln('  None.');
    forall(member(goal(_,D,A,Y),G),format('  - ~w: EUR ~2f in ~w years~n',[D,A,Y]))).

% ---------------- EXPLANATION ----------------

tr(I,V,W,H) :- assertz(trace_step(I,V,W,H)).

explanation_menu :-
    nl,writeln('Explanation: 1=WHY  2=HOW  3=Knowledge Base  0=exit'),
    read_line_to_string(user_input,S), catch(number_string(N,S),_,fail),
    (N=:=1->why_menu,explanation_menu;
     N=:=2->how_menu,explanation_menu;
     N=:=3->kb,explanation_menu;
     N=:=0->true;writeln('Invalid.'),explanation_menu).

why_menu :-
    nl,writeln('WHY: age, employment, partner, partner_employment, partner_salary,'),
    writeln('dependents, income, expenses, savings, goals, psychological_risk.'),
    format('Item (or 0): '),read_line_to_string(user_input,S),why(S).

why("0").
why("age") :- writeln('Provides weak contextual information for resilience.').
why("employment") :- writeln('Employment stability affects resilience to income shocks.').
why("partner") :- writeln('Determines whether partner employment can provide contextual support.').
why("partner_employment") :- writeln('Partner employment stability affects contextual support.').
why("partner_salary") :- writeln('Represents household support; it is NOT added to personal income.').
why("dependents") :- writeln('Dependents represent recurring family obligations.').
why("income") :- writeln('Needed for surplus and expense-resilience calculations.').
why("expenses") :- writeln('Defines liquidity/emergency targets and is subtracted from income.').
why("savings") :- writeln('Determines current available allocation and coverage.').
why("goals") :- writeln('Future goals determine the Pillar 3 target.').
why("psychological_risk") :- writeln('Estimates tolerance for investment losses.').
why(_) :- writeln('No WHY explanation registered.').

how_menu :- nl,writeln('HOW - inference trace:'),forall(
    trace_step(I,V,W,H),format('- ~w = ~w~n  WHY: ~w~n  HOW: ~w~n',[I,V,W,H])).

kb :-
    nl,writeln('=== KNOWLEDGE BASE ==='),
    writeln('Employment: permanent=1.00, temporary=0.55, none=0.10'),
    writeln('Partner support: permanent=0.20, temporary=0.10, otherwise=0'),
    writeln('Savings: min(1, months covered/12)'),
    writeln('Expense resilience: 1-min(1,expenses/income)'),
    writeln('Family: 1-min(1,dependents/4)'),
    writeln('Psychology: sell=0, worried_wait=0.5, calm_wait=1'),
    writeln('Resilience weights: employment 30%, partner 10%, savings 25%,'),
    writeln('expenses 20%, family 10%, age 5%'),
    writeln('Combined index: 55% resilience + 45% psychology'),
    writeln('Emergency: 12/9/6/4/3 months by resilience band'),
    writeln('P1 target=1 month; P3=goals <=10 years; savings priority P1->P2->P3->P4').

% Non-interactive test:
% ?- demo(30,permanent,yes,permanent,2500,3000,1500,30000,[goal(1,'car',6000,3)],calm_wait).
demo(A,E,P,PE,PS,I,X,S,G,PR) :-
    reset_system,
    forall(member(K-V,[age-A,employment-E,partner-P,partner_employment-PE,
                       partner_salary-PS,dependents-0,income-I,expenses-X,
                       savings-S,goals-G,psychological_risk-PR]),assertz(wm(K,V))),
    infer,result.
