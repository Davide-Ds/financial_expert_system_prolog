:- module(explanation, [explanation_menu/0]).
:- use_module(inference_engine).
:- use_module(knowledge_base).


% =========================================================
% EXPLANATION MODULE
% =========================================================
explanation_menu :- nl, writeln('Explanation:'), writeln('1 = WHY'), writeln('2 = HOW'),
                    writeln('3 = Knowledge Base'), writeln('4 = Four Pillars Explained'), writeln('0 = Exit'),
                    read_line_to_string(user_input, S),
                    (catch(number_string(N, S), _, fail) -> explanation_choice(N);
                     writeln('Invalid choice.'), explanation_menu).

explanation_choice(1) :- why_menu, explanation_menu.
explanation_choice(2) :- how_menu, explanation_menu.
explanation_choice(3) :- show_knowledge_base, explanation_menu.
explanation_choice(4) :- explain_pillars, explanation_menu.
explanation_choice(0).
explanation_choice(_) :- writeln('Invalid choice.'), explanation_menu.


% =========================================================
% WHY
% =========================================================
why_menu :- nl, writeln('=== WHY ==='), writeln('1  = age'), writeln('2  = employment'),
	        writeln('3  = partner'), writeln('4  = partner_employment'),
	        writeln('5  = partner_salary'), writeln('6  = dependents'),
	        writeln('7  = income'), writeln('8  = expenses'), writeln('9  = savings'),
	        writeln('10 = goals'), writeln('11 = psychological_risk'), 
                writeln('0  = Back'), format('Item: '), read_line_to_string(user_input, Input),
	        string_lower(Input, LowerInput),
	        (catch(number_string(N, LowerInput),_,fail) -> why(N); why(LowerInput)).


% ---------------- NUMERIC CHOICES ----------------
why(0).
why(1) :- why("age").
why(2) :- why("employment").
why(3) :- why("partner").
why(4) :- why("partner_employment").
why(5) :- why("partner_salary").
why(6) :- why("dependents").
why(7) :- why("income").
why(8) :- why("expenses").
why(9) :- why("savings").
why(10) :- why("goals").
why(11) :- why("psychological_risk").


% ---------------- TEXT CHOICES ----------------
why("age") :- writeln('Age provides weak contextual information for financial resilience.').
why("employment") :- writeln('Employment stability affects resilience to income shocks.').
why("partner") :- writeln('Determines whether partner employment can provide contextual support.').
why("partner_employment") :- writeln('Partner employment stability affects contextual financial support.').
why("partner_salary") :- writeln('Partner salary represents household support; it is NOT added to personal income.').
why("dependents") :- writeln('Dependents represent recurring family obligations.').
why("income") :- writeln('Income is needed for surplus and expense-resilience calculations.').
why("expenses") :- writeln('Expenses define liquidity and emergency targets and are subtracted from income.').
why("savings") :- writeln('Savings determine the current available allocation and savings coverage.').
why("goals") :- writeln('Future goals determine the Pillar 3 recommended target.').
why("psychological_risk") :- writeln('Psychological risk estimates tolerance for investment losses.').
why(_) :- writeln('Invalid WHY choice.'), why_menu.


% =========================================================
% HOW
% =========================================================
how_menu :- nl, writeln('=== HOW - INFERENCE TRACE ==='),
            forall(trace_step(Item, Value, Why, How),
                   (format('~n- ~w = ~w~n', [Item, Value]), format('  WHY: ~w~n', [Why]), 
                    format('  HOW: ~w~n', [How]))
                  ).


% =========================================================
% KNOWLEDGE BASE PRESENTATION
% =========================================================
show_knowledge_base :- nl, writeln('=== KNOWLEDGE BASE ==='),
                       employment_score(permanent, Permanent),
                       employment_score(temporary, Temporary),
                       employment_score(none, None),
                       format('Employment: permanent=~2f, temporary=~2f, none=~2f~n', [Permanent, Temporary, None]),
                       partner_score(yes, permanent, PartnerPermanent),
                       partner_score(yes, temporary, PartnerTemporary),
                       format('Partner support: permanent=~2f, temporary=~2f, otherwise=0~n', [PartnerPermanent, PartnerTemporary]),
                       psych_score(sell, Sell), 
                       psych_score(worried_wait, Worried), 
                       psych_score(calm_wait, Calm),
                       format('Psychology: sell=~2f, worried_wait=~2f, calm_wait=~2f~n', [Sell, Worried, Calm]),
                       resilience_weights(WE, WP, WS, WX, WF, WA),
                       format('Resilience weights: employment=~2f partner=~2f savings=~2f expenses=~2f family=~2f age=~2f~n', [WE, WP, WS, WX, WF, WA]),
                       combined_weights(WResilience, WRisk),
                       format('Combined index: resilience=~2f, psychology=~2f~n',[WResilience, WRisk]),
                       goal_horizon_max(MaxYears), 
                       format('Pillar 3 maximum goal horizon: ~w years~n', [MaxYears]),
                       writeln('Emergency fund: 12/9/6/4/3 months according to resilience.'),
                       writeln('Allocation priority: Pillar 1 -> Pillar 2 -> Pillar 3 -> Pillar 4.').

% =========================================================
% FOUR PILLARS EXPLANATION
% =========================================================
explain_pillars :- nl, writeln('=== FOUR PILLARS - FINANCIAL PLAN ==='),
                   explain_pillars_intro,
                   explain_pillar_1,
                   explain_pillar_2,
                   explain_pillar_3,
                   explain_pillar_4,
                   explain_pillars_order,
                   explain_personal_allocation.

% ---------------- INTRODUCTION ----------------
explain_pillars_intro :- nl,
                         writeln('The four pillars organize your money according to its purpose'),
                         writeln('and when you may need it. The first pillars protect your'),
                         writeln('financial stability; the last one supports long-term growth.').

% ---------------- PILLAR 1 ----------------
explain_pillar_1 :- nl, writeln('1. DAILY LIQUIDITY'),
                    writeln('This is the money for rent, groceries, bills and everyday'),
                    writeln('payments. Keep it readily available, usually in a current'),
                    writeln('account. Cover these essential needs before taking investment'),
                    writeln('risk with the remaining savings.').

% ---------------- PILLAR 2 ----------------
explain_pillar_2 :- nl, writeln('2. EMERGENCY FUND'),
                    writeln('This is a safety reserve for unexpected expenses or a loss'),
                    writeln('of income. Its target depends on your essential expenses and'),
                    writeln('financial resilience. It should be accessible and low-risk,'),
                    writeln('for example in suitable deposits or monetary instruments.'),
                    writeln('It helps avoid selling long-term investments at a bad time.').

% ---------------- PILLAR 3 ----------------
explain_pillar_3 :- nl, writeln('3. PLANNED EXPENSES (1-10 YEARS)'),
                    writeln('This pillar covers known future goals, such as buying a car'),
                    writeln('or paying for education. Set aside the amount needed for each'),
                    writeln('goal, matching its deadline with suitable low-risk instruments'),
                    writeln('such as bonds with an appropriate maturity and issuer risk.'),
                    writeln('The main objective is to have the money when it is needed.').

% ---------------- PILLAR 4 ----------------
explain_pillar_4 :- nl, writeln('4. LONG-TERM INVESTMENTS (OVER 10 YEARS)'),
                    writeln('This pillar aims to grow wealth over a long period.'),
                    writeln('Diversified equity ETFs are one possible choice, but prices'),
                    writeln('can fall substantially and losses are possible. Only money'),
                    writeln('not needed for earlier pillars should be considered here.').

% ---------------- ALLOCATION ORDER ----------------
explain_pillars_order :- nl, writeln('WHY DOES THE ORDER MATTER?'),
                         writeln('First cover daily needs, then prepare for emergencies,'),
                         writeln('then fund foreseeable expenses, and finally consider'),
                         writeln('long-term investing. This priority prevents short-term'),
                         writeln('obligations from depending on unpredictable market returns.'),
                         writeln('Targets are planning guidelines, not guaranteed outcomes.').

% ---------------- PERSONALIZED EXPLANATION ----------------
explain_personal_allocation :- nl, writeln('WHY WAS YOUR ALLOCATION CHOSEN?'),
                               writeln('Your current savings are assigned in priority order.'),
                               writeln('The system first calculates the targets for daily'),
                               writeln('liquidity, emergencies and planned goals; only the'),
                               writeln('remaining savings go to long-term investments.'),
                               explain_personal_factors,
                               explain_allocation_results.

% ---------------- FINANCIAL RESILIENCE ----------------
explain_personal_factors :- nl, writeln('YOUR PERSONAL FINANCIAL SITUATION'),
                            explain_employment_factor,
                            explain_partner_factor,
                            explain_savings_factor,
                            explain_expense_factor,
                            explain_family_factor,
                            explain_age_factor,
                            explain_resilience_factor,
                            explain_psychology_factor,
                            explain_surplus_factor,
                            explain_goals_factor.

explain_employment_factor :-
    ( get_fact(employment, permanent)
    -> writeln('A permanent job supports your financial resilience.')
    ; get_fact(employment, temporary)
    -> writeln('A temporary job lowers your financial resilience compared'),
       writeln('with permanent employment, making a safety reserve important.')
    ; get_fact(employment, none)
    -> writeln('No current employment reduces your financial resilience.'),
       writeln('Protecting essential expenses is especially important.')
    ; true ).

explain_partner_factor :-
    ( get_fact(partner, yes), get_fact(partner_employment, Employment)
    -> ( Employment = permanent
       -> writeln('Your partner has permanent employment, which adds'),
          writeln('a small support score to financial resilience.')
       ; Employment = temporary
       -> writeln('Your partner has temporary employment, which adds'),
          writeln('a smaller support score to financial resilience.')
       ; writeln('Your partner does not add an employment support score.') ),
       writeln('Partner salary is not added to your personal monthly income.')
    ; get_fact(partner, no)
    -> writeln('No partner employment support is included in resilience.')
    ; true ).

explain_savings_factor :-
    ( get_fact(savings, Savings), get_fact(expenses, Expenses),
      number(Savings), number(Expenses), Expenses > 0
    -> Months is Savings / Expenses,
       format('Your savings cover approximately ~2f months of expenses.~n', [Months]),
       writeln('This coverage contributes to your resilience score, capped'),
       writeln('at twelve months for the scoring calculation.')
    ; true ).

explain_expense_factor :-
    ( get_fact(income, Income), get_fact(expenses, Expenses),
      number(Income), number(Expenses), Income > 0
    -> Ratio is 100 * Expenses / Income,
       format('Essential expenses represent ~2f percent of your income.~n', [Ratio]),
       writeln('A higher expense burden reduces your resilience score.')
    ; true ).

explain_family_factor :-
    ( get_fact(dependents, Dependents), number(Dependents), Dependents > 0
    -> format('You have ~w dependents. This lowers the family component~n', [Dependents]),
       writeln('of your financial resilience score.')
    ; get_fact(dependents, 0)
    -> writeln('No dependents are recorded, so the family score is maximal.')
    ; true ).

explain_age_factor :-
    ( get_fact(age_score, Score), number(Score)
    -> format('Age contributes a contextual score of ~2f to resilience.~n', [Score])
    ; true ).

explain_resilience_factor :-
    ( get_fact(financial_resilience, Resilience),
      get_fact(emergency_months, Months),
      get_fact(expenses, Expenses),
      number(Resilience), number(Months), number(Expenses)
    -> Target is Expenses * Months,
       format('Your financial resilience score is ~2f (from 0 to 1).~n', [Resilience]),
       format('The rules select ~w months of emergency coverage,~n', [Months]),
       format('giving an emergency target of ~2f EUR.~n', [Target]),
       writeln('The number of months is selected by resilience bands, not'),
       writeln('by psychological tolerance or the combined risk index.')
    ; true ).

explain_psychology_factor :-
    ( get_fact(psychological_risk, Profile)
    -> explain_psychology_profile(Profile)
    ; true ),
    ( get_fact(risk_index, Index), number(Index)
    -> format('Your combined risk index is ~2f (from 0 to 1).~n', [Index]),
       writeln('It describes your risk profile but is NOT used by the'),
       writeln('current allocation rules to change pillar amounts.')
    ; true ).

explain_psychology_profile(sell) :-
    writeln('You would sell after a market loss: psychological risk'),
    writeln('tolerance is low, suggesting caution with volatile assets.').
explain_psychology_profile(worried_wait) :-
    writeln('You would wait despite concern after a market loss:'),
    writeln('psychological risk tolerance is moderate.').
explain_psychology_profile(calm_wait) :-
    writeln('You would wait calmly after a market loss:'),
    writeln('psychological risk tolerance is high.').
explain_psychology_profile(_).

explain_surplus_factor :-
    ( get_fact(monthly_surplus, Surplus), number(Surplus)
    -> ( Surplus =< 0
       -> writeln('No positive monthly surplus is available for allocation.')
       ; format('Your monthly surplus is ~2f EUR, calculated as the~n', [Surplus]),
         writeln('positive difference between income and expenses.') )
    ; true ).

explain_goals_factor :-
    ( get_fact(goals, Goals), is_list(Goals),
      goal_horizon_max(MaxYears)
    -> findall(Amount,
               ( member(goal(_, _, Amount, Years), Goals), Years =< MaxYears ),
               Amounts),
       sum_list(Amounts, Total),
       format('Goals within the ~w-year limit require ~2f EUR in Pillar 3.~n',
              [MaxYears, Total]),
       writeln('Goals beyond that horizon are not included in its target.')
    ; true ).

% ---------------- ALLOCATION RESULTS ----------------
explain_allocation_results :-
    ( get_fact(targets, targets(T1,T2,T3)),
      get_fact(allocations, allocation(A1,A2,A3,A4)),
      maplist(number, [T1,T2,T3,A1,A2,A3,A4])
    -> nl, writeln('CURRENT SAVINGS ALLOCATION'),
       format('Pillar 1 - Daily liquidity: ~2f / ~2f EUR (target)~n', [A1,T1]),
       format('Pillar 2 - Emergency fund: ~2f / ~2f EUR (target)~n', [A2,T2]),
       format('Pillar 3 - Planned expenses: ~2f / ~2f EUR (target)~n', [A3,T3]),
       format('Pillar 4 - Long-term investments: ~2f EUR~n', [A4]),
       explain_pillar_gap(1, T1, A1),
       explain_pillar_gap(2, T2, A2),
       explain_pillar_gap(3, T3, A3),
       explain_pillar_4_reason(A4)
    ; nl, writeln('No completed allocation is available in working memory.') ),
    explain_monthly_allocation.

explain_pillar_gap(Number, Target, Allocated) :-
    Gap is max(0, Target - Allocated),
    ( Gap > 0
    -> format('Pillar ~w is below target by ~2f EUR. Savings are assigned~n', [Number,Gap]),
       writeln('to earlier pillars first, so this gap has priority over'),
       writeln('allocations to later pillars.')
    ; format('Pillar ~w has reached its calculated target.~n', [Number]) ).

explain_pillar_4_reason(Amount) :-
    ( Amount > 0
    -> format('Pillar 4 receives ~2f EUR because this amount remains~n', [Amount]),
       writeln('after covering the first three pillar targets.')
    ; writeln('Pillar 4 receives no current savings because none remain'),
      writeln('after allocation to the earlier priorities.') ).

% ---------------- NEXT MONTH ALLOCATION ----------------
explain_monthly_allocation :-
    ( get_fact(monthly_allocations, allocation(M1,M2,M3,M4)),
      maplist(number, [M1,M2,M3,M4])
    -> nl, writeln('PROJECTED NEXT MONTH SURPLUS ALLOCATION'),
       format('Pillar 1: ~2f EUR~n', [M1]),
       format('Pillar 2: ~2f EUR~n', [M2]),
       format('Pillar 3: ~2f EUR~n', [M3]),
       format('Pillar 4: ~2f EUR~n', [M4]),
       writeln('Next month surplus first closes any remaining target'),
       writeln('gaps in pillar order; only the remainder goes to Pillar 4.'),
       explain_remaining_gaps
    ; true ).

explain_remaining_gaps :-
    ( get_fact(remaining_gaps, gaps(G1,G2,G3)),
      maplist(number, [G1,G2,G3])
    -> format('Gaps after next month: P1=~2f, P2=~2f, P3=~2f EUR.~n',
              [G1,G2,G3])
    ; true ).
