:- module(inference_engine, [
    infer/0,
    reset_system/0,
    put_fact/2,
    get_fact/2,
    trace_step/4
]).

:- use_module(knowledge_base).

:- dynamic wm/2.
:- dynamic trace_step/4.

% =========================================================
% WORKING MEMORY
% =========================================================

reset_system :-
    retractall(wm(_, _)),
    retractall(trace_step(_, _, _, _)).

put_fact(Key, Value) :-
    assertz(wm(Key, Value)).

get_fact(Key, Value) :-
    wm(Key, Value).

% =========================================================
% INFERENCE ENGINE
% =========================================================

infer :-
    employment,
    partner,
    savings_score,
    expense_score,
    family_score,
    calculate_age_score,
    resilience,
    psychology,
    combined,
    surplus,
    emergency,
    allocation.

% ---------------------------------------------------------
% Employment
% ---------------------------------------------------------

employment :-
    wm(employment, Employment),
    employment_score(Employment, Score),

    assertz(wm(employment_score, Score)),

    tr(
        employment_score,
        Score,
        'Employment stability',
        'permanent=1.00, temporary=0.55, none=0.10'
    ).

% ---------------------------------------------------------
% Partner
% ---------------------------------------------------------

partner :-
    wm(partner, Partner),
    wm(partner_employment, PartnerEmployment),

    partner_score(
        Partner,
        PartnerEmployment,
        Score
    ),

    assertz(wm(partner_score, Score)),

    tr(
        partner_score,
        Score,
        'Partner support',
        'permanent=0.20, temporary=0.10, otherwise=0'
    ).

% ---------------------------------------------------------
% Savings coverage
% ---------------------------------------------------------

savings_score :-
    wm(savings, Savings),
    wm(expenses, Expenses),
    Expenses > 0,

    Months is min(12, Savings / Expenses),
    Score is min(1.0, Months / 12),

    assertz(wm(savings_score, Score)),

    tr(
        savings_score,
        Score,
        'Savings coverage',
        'min(1, months covered / 12)'
    ).

% ---------------------------------------------------------
% Expense resilience
% ---------------------------------------------------------

expense_score :-
    wm(income, Income),
    wm(expenses, Expenses),
    Income > 0,

    Score is 1 - min(1, Expenses / Income),

    assertz(wm(expense_score, Score)),

    tr(
        expense_score,
        Score,
        'Essential expenses versus personal income',
        '1 - min(1, expenses / income)'
    ).

% ---------------------------------------------------------
% Family
% ---------------------------------------------------------

family_score :-
    wm(dependents, Dependents),

    Score is max(0, 1 - min(1, Dependents / 4)),

    assertz(wm(family_score, Score)),

    tr(
        family_score,
        Score,
        'Number of dependents',
        '1 - min(1, dependents / 4)'
    ).

% ---------------------------------------------------------
% Age
% ---------------------------------------------------------

calculate_age_score :-
    wm(age, Age),
    age_score(Age, Score),

    assertz(wm(age_score, Score)),

    tr(
        age_score,
        Score,
        'Age context',
        'small heuristic weight'
    ).

% ---------------------------------------------------------
% Financial resilience
% ---------------------------------------------------------

resilience :-
    wm(employment_score, Employment),
    wm(partner_score, Partner),
    wm(savings_score, Savings),
    wm(expense_score, Expenses),
    wm(family_score, Family),
    wm(age_score, Age),

    resilience_weights(
        WE,
        WP,
        WS,
        WX,
        WF,
        WA
    ),

    Value0 is
        WE * Employment +
        WP * Partner +
        WS * Savings +
        WX * Expenses +
        WF * Family +
        WA * Age,

    Value is max(0, min(1, Value0)),

    assertz(wm(financial_resilience, Value)),

    tr(
        financial_resilience,
        Value,
        'Objective financial situation',
        'weighted employment/partner/savings/expenses/family/age'
    ).

% ---------------------------------------------------------
% Psychological risk tolerance
% ---------------------------------------------------------

psychology :-
    wm(psychological_risk, Profile),
    psych_score(Profile, Value),

    assertz(wm(risk_tolerance, Value)),

    tr(
        risk_tolerance,
        Value,
        'Reaction to a >=10% loss',
        'sell=0.00, worried_wait=0.50, calm_wait=1.00'
    ).

% ---------------------------------------------------------
% Combined index
% ---------------------------------------------------------

combined :-
    wm(financial_resilience, Financial),
    wm(risk_tolerance, Psychological),

    combined_weights(WF, WP),

    Value is
        WF * Financial +
        WP * Psychological,

    assertz(wm(risk_index, Value)),

    tr(
        risk_index,
        Value,
        'Financial resilience and psychological tolerance',
        'weighted combination of resilience and risk tolerance'
    ).

% ---------------------------------------------------------
% Monthly surplus
% ---------------------------------------------------------

surplus :-
    wm(income, Income),
    wm(expenses, Expenses),

    Value is max(0, Income - Expenses),

    assertz(wm(monthly_surplus, Value)),

    tr(
        monthly_surplus,
        Value,
        'Personal income minus essential expenses',
        'max(0, income - expenses)'
    ).

% ---------------------------------------------------------
% Emergency fund
% ---------------------------------------------------------

emergency :-
    wm(financial_resilience, Resilience),

    emergency_months(Resilience, Months),

    assertz(wm(emergency_months, Months)),

    tr(
        emergency_months,
        Months,
        'Financial resilience',
        '3/4/6/9/12 month heuristic bands'
    ).

% ---------------------------------------------------------
% Total future goals
% ---------------------------------------------------------

goal_total(Total) :-
    wm(goals, Goals),
    goal_horizon_max(MaxYears),

    findall(
        Amount,
        (
            member(goal(_, _, Amount, Years), Goals),
            Years =< MaxYears
        ),
        Amounts
    ),

    sum_list(Amounts, Total).

% ---------------------------------------------------------
% Four-pillar allocation
% ---------------------------------------------------------

allocation :-
    wm(expenses, Expenses),
    wm(emergency_months, EmergencyMonths),
    wm(savings, Savings),

    goal_total(GoalTotal),

    % Recommended targets
    Target1 is Expenses,
    Target2 is Expenses * EmergencyMonths,
    Target3 is GoalTotal,

    % Pillar 1
    Allocation1 is min(Savings, Target1),
    Remaining1 is Savings - Allocation1,

    % Pillar 2
    Allocation2 is min(Remaining1, Target2),
    Remaining2 is Remaining1 - Allocation2,

    % Pillar 3
    Allocation3 is min(Remaining2, Target3),
    Remaining3 is Remaining2 - Allocation3,

    % Pillar 4
    Allocation4 is max(0, Remaining3),

    assertz(
        wm(
            targets,
            targets(Target1, Target2, Target3)
        )
    ),

    assertz(
        wm(
            allocations,
            allocation(
                Allocation1,
                Allocation2,
                Allocation3,
                Allocation4
            )
        )
    ),

    tr(
        allocations,
        allocation(
            Allocation1,
            Allocation2,
            Allocation3,
            Allocation4
        ),
        'Four-pillar allocation',
        'current savings: P1 -> P2 -> P3 -> P4'
    ).

% =========================================================
% TRACE
% =========================================================

tr(Item, Value, Why, How) :-
    assertz(
        trace_step(Item, Value, Why, How)
    ).