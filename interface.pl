:- module(interface, [
    main/0,
    demo/10
]).

:- use_module(inference_engine).
:- use_module(knowledge_base).
:- use_module(explanation).

% =========================================================
% MAIN
% =========================================================

main :-
    reset_system,
    banner,
    collect_inputs,
    infer,
    result,
    explanation_menu.

banner :-
    nl,
    writeln('=== FINANCIAL EXPERT SYSTEM ==='),
    writeln(
        'Educational Prolog expert system; not financial advice.'
    ),
    nl.

% =========================================================
% INPUT
% =========================================================

collect_inputs :-
    ask_int('Age', age, 18, 100),

    ask_choice(
        'Employment 1=permanent, 2=temporary, 3=none',
        employment,
        [
            1-permanent,
            2-temporary,
            3-none
        ]
    ),

    ask_money(
        'Personal monthly net income (EUR)',
        income
    ),

    ask_money(
        'Essential monthly expenses (EUR)',
        expenses
    ),

    ask_money(
        'Current savings (EUR)',
        savings
    ),

    ask_yes_no(
        'Partner?',
        partner
    ),

    partner_inputs,

    ask_int(
        'Dependents',
        dependents,
        0,
        20
    ),

    goals,

    ask_choice(
        'Reaction to >=10% investment loss: 1=sell 2=worried wait 3=calm wait',
        psychological_risk,
        [
            1-sell,
            2-worried_wait,
            3-calm_wait
        ]
    ).

% =========================================================
% PARTNER INPUT
% =========================================================

partner_inputs :-
    get_fact(partner, no),
    !,

    put_fact(
        partner_employment,
        none
    ),

    put_fact(
        partner_salary,
        0
    ).

partner_inputs :-
    ask_choice(
        'Partner employment 1=permanent, 2=temporary, 3=none',
        partner_employment,
        [
            1-permanent,
            2-temporary,
            3-none
        ]
    ),

    ask_money(
        'Partner monthly net income (EUR)',
        partner_salary
    ).

% =========================================================
% INTEGER INPUT
% =========================================================

ask_int(Label, Key, Min, Max) :-
    repeat,

    format(
        '~w: ',
        [Label]
    ),

    read_line_to_string(
        user_input,
        String
    ),

    (
        catch(
            number_string(Number, String),
            _,
            fail
        ),

        integer(Number),
        Number >= Min,
        Number =< Max
    ->
        put_fact(
            Key,
            Number
        ),
        !
    ;
        writeln('Invalid value.'),
        fail
    ).

% =========================================================
% MONEY INPUT
% =========================================================

ask_money(Label, Key) :-
    repeat,

    format(
        '~w: ',
        [Label]
    ),

    read_line_to_string(
        user_input,
        String
    ),

    (
        catch(
            number_string(Number, String),
            _,
            fail
        ),

        number(Number),
        Number >= 0
    ->
        Value is round(Number * 100) / 100,

        put_fact(
            Key,
            Value
        ),

        !
    ;
        writeln('Invalid value.'),
        fail
    ).

% =========================================================
% YES / NO INPUT
% =========================================================

ask_yes_no(Label, Key) :-
    repeat,

    format(
        '~w [y/n]: ',
        [Label]
    ),

    read_line_to_string(
        user_input,
        Original
    ),

    string_lower(
        Original,
        Answer
    ),

    (
        (Answer = "y" ; Answer = "yes")
    ->
        put_fact(
            Key,
            yes
        ),
        !

    ;
        (Answer = "n" ; Answer = "no")
    ->
        put_fact(
            Key,
            no
        ),
        !

    ;
        writeln('Use y or n.'),
        fail
    ).

% =========================================================
% MULTIPLE CHOICE INPUT
% =========================================================

ask_choice(Label, Key, Pairs) :-
    repeat,

    format(
        '~w: ',
        [Label]
    ),

    read_line_to_string(
        user_input,
        String
    ),

    (
        catch(
            number_string(Number, String),
            _,
            fail
        ),

        member(
            Number-Value,
            Pairs
        )
    ->
        put_fact(
            Key,
            Value
        ),
        !

    ;
        writeln('Invalid choice.'),
        fail
    ).

% =========================================================
% FUTURE GOALS
% =========================================================

goals :-
    writeln(
        'Future goals: enter 0 as amount to stop.'
    ),

    collect_goals(
        1,
        [],
        Goals
    ),

    put_fact(
        goals,
        Goals
    ).

collect_goals(Index, Accumulator, Goals) :-
    format(
        'Goal ~w amount (EUR): ',
        [Index]
    ),

    read_line_to_string(
        user_input,
        String
    ),

    (
        catch(
            number_string(Number, String),
            _,
            fail
        ),

        Number >= 0
    ->
        collect_goal_value(
            Number,
            Index,
            Accumulator,
            Goals
        )

    ;
        writeln('Invalid amount.'),
        collect_goals(
            Index,
            Accumulator,
            Goals
        )
    ).

collect_goal_value(
    0,
    _,
    Accumulator,
    Goals
) :-
    reverse(
        Accumulator,
        Goals
    ),
    !.

collect_goal_value(
    Number,
    Index,
    Accumulator,
    Goals
) :-
    format('Description: '),

    read_line_to_string(
        user_input,
        Description
    ),

    ask_goal_years(Years),

    Value is round(Number * 100) / 100,

    NextIndex is Index + 1,

    collect_goals(
        NextIndex,
        [
            goal(
                Index,
                Description,
                Value,
                Years
            )
            |
            Accumulator
        ],
        Goals
    ).

% =========================================================
% GOAL YEARS
% =========================================================

ask_goal_years(Years) :-
    goal_horizon_max(MaxYears),

    repeat,

    format(
        'Years until goal (1-~w): ',
        [MaxYears]
    ),

    read_line_to_string(
        user_input,
        String
    ),

    (
        catch(
            number_string(Number, String),
            _,
            fail
        ),

        integer(Number),
        Number >= 1,
        Number =< MaxYears
    ->
        Years = Number,
        !

    ;
        format(
            'Goals for Pillar 3 must be between 1 and ~w years.~n',
            [MaxYears]
        ),

        format(
            'For horizons above ~w years, capital is considered long-term (Pillar 4).~n',
            [MaxYears]
        ),

        fail
    ).

% =========================================================
% OUTPUT / PRESENTATION
% =========================================================

result :-
    get_fact(
        financial_resilience,
        FinancialResilience
    ),

    get_fact(
        risk_tolerance,
        RiskTolerance
    ),

    get_fact(
        risk_index,
        RiskIndex
    ),

    get_fact(
        monthly_surplus,
        Surplus
    ),

    get_fact(
        emergency_months,
        EmergencyMonths
    ),

    get_fact(
        targets,
        targets(
            Target1,
            Target2,
            Target3
        )
    ),

    get_fact(
        allocations,
        allocation(
            Allocation1,
            Allocation2,
            Allocation3,
            Allocation4
        )
    ),

    nl,
    writeln('=== RESULT ==='),

    format(
        'Financial resilience: ~2f / 1.00~n',
        [FinancialResilience]
    ),

    format(
        'Psychological risk tolerance: ~2f / 1.00~n',
        [RiskTolerance]
    ),

    format(
        'Combined risk index: ~2f / 1.00~n',
        [RiskIndex]
    ),

    format(
        'Monthly surplus: EUR ~2f~n',
        [Surplus]
    ),

    format(
        'Emergency target: ~w months~n',
        [EmergencyMonths]
    ),

    nl,

    writeln(
        'CURRENT SAVINGS ALLOCATION'
    ),

    format(
        'Pillar 1 ordinary liquidity: EUR ~2f (recommended target ~2f)~n',
        [
            Allocation1,
            Target1
        ]
    ),

    format(
        'Pillar 2 emergency fund:     EUR ~2f (recommended target ~2f)~n',
        [
            Allocation2,
            Target2
        ]
    ),

    format(
        'Pillar 3 future goals:       EUR ~2f (recommended target ~2f)~n',
        [
            Allocation3,
            Target3
        ]
    ),

    format(
        'Pillar 4 long term:          EUR ~2f~n',
        [Allocation4]
    ),

    nl,

    writeln(
        'Pillar 3 goals (<=10 years):'
    ),

    show_goals.

show_goals :-
    get_fact(
        goals,
        Goals
    ),

    (
        Goals = []
    ->
        writeln('  None.')

    ;
        forall(
            member(
                goal(_, Description, Amount, Years),
                Goals
            ),

            format(
                '  - ~w: EUR ~2f in ~w years~n',
                [
                    Description,
                    Amount,
                    Years
                ]
            )
        )
    ).

% =========================================================
% NON-INTERACTIVE TEST
% =========================================================

demo(
    Age,
    Employment,
    Partner,
    PartnerEmployment,
    PartnerSalary,
    Income,
    Expenses,
    Savings,
    Goals,
    PsychologicalRisk
) :-
    reset_system,

    put_fact(
        age,
        Age
    ),

    put_fact(
        employment,
        Employment
    ),

    put_fact(
        partner,
        Partner
    ),

    put_fact(
        partner_employment,
        PartnerEmployment
    ),

    put_fact(
        partner_salary,
        PartnerSalary
    ),

    put_fact(
        dependents,
        0
    ),

    put_fact(
        income,
        Income
    ),

    put_fact(
        expenses,
        Expenses
    ),

    put_fact(
        savings,
        Savings
    ),

    put_fact(
        goals,
        Goals
    ),

    put_fact(
        psychological_risk,
        PsychologicalRisk
    ),

    infer,

    result.