:- module(knowledge_base, [employment_score/2, partner_score/3, psych_score/2, age_score/2,
                           emergency_months/2, resilience_weights/6, combined_weights/2, 
                           goal_horizon_max/1]).

% =========================================================
% KNOWLEDGE BASE
% =========================================================

% Employment stability
employment_score(permanent, 1.0).
employment_score(temporary, 0.55).
employment_score(none,      0.10).

% Partner support
partner_score(no,  _,         0.0).
partner_score(yes, permanent, 0.20).
partner_score(yes, temporary, 0.10).
partner_score(yes, none,      0.0).

% Psychological risk tolerance
psych_score(sell,         0.0).
psych_score(worried_wait, 0.5).
psych_score(calm_wait,    1.0).

% Age heuristic
age_score(Age, 0.85) :- Age < 30, !.
age_score(Age, 0.70) :- Age < 45, !.
age_score(Age, 0.55) :- Age < 60, !.
age_score(_,   0.40).

% Emergency fund according to financial resilience
emergency_months(R, 12) :- R < 0.30, !.
emergency_months(R,  9) :- R < 0.50, !.
emergency_months(R,  6) :- R < 0.70, !.
emergency_months(R,  4) :- R < 0.85, !.
emergency_months(_,  3).

% Weights used for financial resilience
% Employment, Partner, Savings, Expenses, Family, Age
resilience_weights(0.30, 0.10, 0.25, 0.20, 0.10, 0.05).

% Financial resilience + psychological risk tolerance
combined_weights(0.55, 0.45).

% Pillar 3 only contains goals up to 10 years
goal_horizon_max(10).