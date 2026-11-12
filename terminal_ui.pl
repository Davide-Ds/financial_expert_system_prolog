:- module(terminal_ui,
          [ banner/0, section/1, subsection/1, success/1, warning/1,
            error_message/1, info/1, menu_item/2, prompt/2,
            progress/2, money_row/3, metric/2, separator/0,
            color_text/2, pause/0 ]).

:- use_module(library(ansi_term)).
:- use_module(library(lists)).

% Keep all styling in this module: the inference engine remains unchanged.
color_text(Style, Text) :-
    ( stream_property(user_output, tty(true))
    -> ansi_format(Style, '~w', [Text])
    ;  format('~w', [Text]) ).

separator :- color_text([fg(blue)], '------------------------------------------------------------'), nl.

banner :-
    nl, separator,
    color_text([bold,fg(cyan)], '                        F I N E X P E R T'), nl,
    color_text([fg(cyan)], '                 FINANCIAL EXPERT SYSTEM'), nl,
    color_text([fg(white)], '                  Rule-Based Financial Planning'), nl,
    separator,
    info('Educational decision support - not financial advice.'),
    success('Knowledge Base / Inference Engine / Explanations ready'), nl.

section(Title) :-
    nl, separator,
    color_text([bold,fg(cyan)], Title), nl,
    separator.

subsection(Title) :- nl, color_text([bold,fg(blue)], Title), nl.
success(Message) :- color_text([fg(green)], '[OK] '), format('~w~n', [Message]).
warning(Message) :- color_text([fg(yellow)], '[!] '), format('~w~n', [Message]).
error_message(Message) :- color_text([fg(red)], '[ERRORE] '), format('~w~n', [Message]).
info(Message) :- color_text([fg(cyan)], '[i] '), format('~w~n', [Message]).
menu_item(Number, Label) :- format('  [~w] ~w~n', [Number, Label]).
prompt(Label, Answer) :-
    nl, color_text([bold,fg(cyan)], '?> '),
    format('~w ', [Label]),
    flush_output(user_output),
    read_line_to_string(user_input, Answer).

progress(Current, Total) :-
    Total > 0,
    Filled is round(30 * Current / Total),
    Empty is 30 - Filled,
    length(Fs, Filled), maplist(=('#'), Fs),
    length(Es, Empty), maplist(=('-'), Es),
    atomic_list_concat(Fs, FBar), atomic_list_concat(Es, EBar),
    Percent is round(100 * Current / Total),
    format('  [~w~w] ~d%  (~d/~d)~n', [FBar,EBar,Percent,Current,Total]).

money_row(Name, Value, Target) :-
    format('  ~|~w~t~30+ EUR ~|~2f~t~45+', [Name,Value]),
    ( Target == none -> nl ; format(' / target EUR ~2f~n', [Target]) ).

metric(Name, Value) :- format('  ~|~w~t~32+ ~w~n', [Name, Value]).

pause :-
    nl, color_text([fg(blue)], 'Premi INVIO per continuare...'),
    flush_output(user_output),
    read_line_to_string(user_input, _).
