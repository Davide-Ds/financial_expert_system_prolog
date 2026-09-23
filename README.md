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

commands examples to launch the demo:
demo(
    30,                             % Age
    permanent,                      % Employment
    yes,                            % Partner
    permanent,                      % Partner employment
    2000,                           % Partner salary
    2500,                           % Personal monthly income
    1500,                           % Essential monthly expenses
    30000,                          % Current savings
    [goal(1, "Car", 8000, 3)],       % Future goal
    calm_wait                       % Psychological risk
).
```

Scenario 1 — Elevata disponibilità

Reddito stabile, risparmi sufficienti e buona tolleranza psicologica al rischio.

demo(30, permanent, yes, permanent, 2000,
        2500, 1500, 50000,
        [goal(1, "Car", 8000, 3)],
        calm_wait).

Verifica che il sistema assegni il capitale residuo al Pilastro 4 dopo aver soddisfatto i primi tre.

Scenario 2 — Risparmi insufficienti
Lavoro a tempo determinato, nessun partner e un acquisto futuro.

demo(26, temporary, no, none, 0,
        1800, 1300, 5000,
        [goal(1, "Car", 10000, 2)],
        worried_wait).

Verifica la differenza tra allocation e recommended target e che il Pilastro 4 rimanga vuoto.


Scenario 3 — Più obiettivi futuri
Reddito stabile, tre acquisti programmati e risparmi consistenti.

demo(35, permanent, yes, temporary, 1500,
        3500, 1800, 80000,
        [goal(1, "Car", 12000, 2),
         goal(2, "House", 30000, 7),
         goal(3, "Wedding", 10000, 4)],
        calm_wait).

Verifica che il Pilastro 3 sommi correttamente tutti e tre gli obiettivi: 52.000 €.

Attenzione: nel `demo/10` il numero di persone a carico è fissato a `0`. Per testare anche quel parametro, devi usare `main.` oppure modificare `demo` aggiungendo un undicesimo argomento.
