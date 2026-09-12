# Financial Expert System - Prolog

Educational decision-support project for Fundamentals of AI.

Run with SWI-Prolog:
    swipl main.pl
then:
    ?- main.

Architecture:
User Interface -> Working Memory -> Inference Engine -> Knowledge Base
                                      -> Explanation module

Inputs:
age, employment, partner + partner employment/salary, dependents,
personal income, essential monthly expenses, savings, future goals,
psychological reaction to >=10% investment loss.

Partner salary is NOT added to personal income.

Outputs:
financial resilience [0,1], psychological tolerance [0,1],
combined heuristic risk index [0,1], monthly surplus, emergency horizon,
and explicit EUR allocations for four pillars.

The numerical rules are explicit project heuristics, not probabilities or
financial advice. Current savings are allocated P1 -> P2 -> P3 -> P4.
