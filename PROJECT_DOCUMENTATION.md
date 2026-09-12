# Project Documentation

## Expert-system correspondence
The course material defines a functional schema with Knowledge Base,
Inference Engine, User Interface and Working Memory, and describes an
explanation module for WHY and HOW. This project implements those concepts
directly in Prolog.

## Working Memory
Case-specific facts use `wm(Key,Value)`.

## Knowledge Base
Rules encode employment stability, partner support, savings coverage,
expense resilience, family burden, age context, psychological tolerance,
resilience weights, emergency-fund thresholds and four-pillar policy.

## Inference
Financial resilience is a weighted heuristic:
30% employment + 10% partner + 25% savings + 20% expenses +
10% family + 5% age.

Psychological tolerance is independent:
sell=0, worried wait=0.5, calm wait=1.

Combined index = 55% financial resilience + 45% psychological tolerance.

Monthly surplus = max(0, personal income - essential expenses).

## Four pillars
P1 target = 1 month essential expenses.
P2 target = 3/4/6/9/12 months according to resilience.
P3 target = future goals due within 10 years.
P4 = residual current savings.

Current savings are allocated in priority order P1 -> P2 -> P3 -> P4.

## Explanation
The system can answer WHY an input is relevant and HOW intermediate
conclusions were derived through a stored inference trace.

## Limitations
The score is a heuristic index, not a probability or validated financial
risk measure. The system does not forecast returns, inflation, taxes or
optimize individual financial instruments.
