:- module(explanation, [
    explanation_menu/0
]).

:- use_module(inference_engine).
:- use_module(knowledge_base).

% =========================================================
% EXPLANATION MODULE
% =========================================================

explanation_menu :-
    nl,
    writeln('Explanation:'),
    writeln('1 = WHY'),
    writeln('2 = HOW'),
    writeln('3 = Knowledge Base'),
    writeln('0 = Exit'),

    read_line_to_string(user_input, S),

    (
        catch(number_string(N, S), _, fail)
    ->
        explanation_choice(N)
    ;
        writeln('Invalid choice.'),
        explanation_menu
    ).

explanation_choice(1) :-
    why_menu,
    explanation_menu.

explanation_choice(2) :-
    how_menu,
    explanation_menu.

explanation_choice(3) :-
    show_knowledge_base,
    explanation_menu.

explanation_choice(0).

explanation_choice(_) :-
    writeln('Invalid choice.'),
    explanation_menu.

% =========================================================
% WHY
% =========================================================

why_menu :-
    nl,
    writeln('Available items:'),
    writeln('age'),
    writeln('employment'),
    writeln('partner'),
    writeln('partner_employment'),
    writeln('partner_salary'),
    writeln('dependents'),
    writeln('income'),
    writeln('expenses'),
    writeln('savings'),
    writeln('goals'),
    writeln('psychological_risk'),

    format('Item (or 0): '),
    read_line_to_string(user_input, Item),

    why(Item).

why("0").

why("age") :-
    writeln(
        'Provides weak contextual information for financial resilience.'
    ).

why("employment") :-
    writeln(
        'Employment stability affects resilience to income shocks.'
    ).

why("partner") :-
    writeln(
        'Determines whether partner employment can provide contextual support.'
    ).

why("partner_employment") :-
    writeln(
        'Partner employment stability affects contextual financial support.'
    ).

why("partner_salary") :-
    writeln(
        'Represents household support; it is NOT added to personal income.'
    ).

why("dependents") :-
    writeln(
        'Dependents represent recurring family obligations.'
    ).

why("income") :-
    writeln(
        'Needed for surplus and expense-resilience calculations.'
    ).

why("expenses") :-
    writeln(
        'Defines liquidity and emergency targets and is subtracted from income.'
    ).

why("savings") :-
    writeln(
        'Determines current available allocation and savings coverage.'
    ).

why("goals") :-
    writeln(
        'Future goals determine the Pillar 3 recommended target.'
    ).

why("psychological_risk") :-
    writeln(
        'Estimates psychological tolerance for investment losses.'
    ).

why(_) :-
    writeln('No WHY explanation registered.').

% =========================================================
% HOW
% =========================================================

how_menu :-
    nl,
    writeln('=== HOW - INFERENCE TRACE ==='),

    forall(
        trace_step(Item, Value, Why, How),
        (
            format('~n- ~w = ~w~n', [Item, Value]),
            format('  WHY: ~w~n', [Why]),
            format('  HOW: ~w~n', [How])
        )
    ).

% =========================================================
% KNOWLEDGE BASE PRESENTATION
% =========================================================

show_knowledge_base :-
    nl,
    writeln('=== KNOWLEDGE BASE ==='),

    employment_score(permanent, Permanent),
    employment_score(temporary, Temporary),
    employment_score(none, None),

    format(
        'Employment: permanent=~2f, temporary=~2f, none=~2f~n',
        [Permanent, Temporary, None]
    ),

    partner_score(yes, permanent, PartnerPermanent),
    partner_score(yes, temporary, PartnerTemporary),

    format(
        'Partner support: permanent=~2f, temporary=~2f, otherwise=0~n',
        [PartnerPermanent, PartnerTemporary]
    ),

    psych_score(sell, Sell),
    psych_score(worried_wait, Worried),
    psych_score(calm_wait, Calm),

    format(
        'Psychology: sell=~2f, worried_wait=~2f, calm_wait=~2f~n',
        [Sell, Worried, Calm]
    ),

    resilience_weights(
        WE,
        WP,
        WS,
        WX,
        WF,
        WA
    ),

    format(
        'Resilience weights: employment=~2f partner=~2f savings=~2f expenses=~2f family=~2f age=~2f~n',
        [WE, WP, WS, WX, WF, WA]
    ),

    combined_weights(WResilience, WRisk),

    format(
        'Combined index: resilience=~2f, psychology=~2f~n',
        [WResilience, WRisk]
    ),

    goal_horizon_max(MaxYears),

    format(
        'Pillar 3 maximum goal horizon: ~w years~n',
        [MaxYears]
    ),

    writeln(
        'Emergency fund: 12/9/6/4/3 months according to resilience.'
    ),

    writeln(
        'Allocation priority: Pillar 1 -> Pillar 2 -> Pillar 3 -> Pillar 4.'
    ).