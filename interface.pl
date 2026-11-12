:- module(interface, [main/0, demo/0, demo/10, result/0]).

:- use_module(library(lists)).
:- use_module(inference_engine).
:- use_module(knowledge_base, [goal_horizon_max/1]).
:- use_module(explanation, [explanation_menu/0]).
:- use_module('financial_instruments.pl',
              [show_personalized_instruments/0, financial_instruments_menu/0,
               show_pillar_instruments/1, show_financial_instruments/0]).
:- use_module(terminal_ui).

% =========================================================
% FINEXPERT - PROFESSIONAL TERMINAL INTERFACE
% The rules, scores and allocation formulas live in the existing modules.
% User input is stored in a dict until confirmation, to avoid stale wm/2 facts
% when navigating backwards or correcting answers.
% =========================================================

main :- terminal_ui:banner, main_menu.

main_menu :-
    terminal_ui:section('MENU PRINCIPALE'),
    terminal_ui:menu_item(1, 'Avvia una nuova consulenza'),
    terminal_ui:menu_item(2, 'Informazioni sui quattro pilastri'),
    terminal_ui:menu_item(3, 'Guida al sistema'),
    terminal_ui:menu_item(0, 'Esci'),
    choose(['0','1','2','3'], Choice),
    ( Choice = '0' -> terminal_ui:success('Sessione terminata.')
    ; Choice = '1' -> run_consultation, main_menu
    ; Choice = '2' -> four_pillars, terminal_ui:pause, main_menu
    ; Choice = '3' -> help_screen, terminal_ui:pause, main_menu
    ).

run_consultation :-
    defaults(D0),
    terminal_ui:section('NUOVA CONSULENZA'),
    terminal_ui:info('Inserisci i dati richiesti. Digita B per tornare indietro.'),
    questionnaire(1, D0, D),
    ( D == cancelled -> terminal_ui:info('Consulenza annullata.')
    ; confirm_profile(D, Confirmed),
      ( Confirmed == yes ->
          reset_system, commit_profile(D),
          ( catch(infer, Error,
                  (print_message(error,Error), fail))
          -> terminal_ui:success('Inferenza completata.'),
             result, result_menu
          ;  terminal_ui:error_message('Impossibile completare l inferenza. Verifica i moduli.') )
      ; terminal_ui:info('Consulenza annullata.') )
    ).

% Nine navigable steps. The review screen supports editing any step.
defaults(profile{age:26,employment:temporary,partner:no,
                 partner_employment:none,partner_salary:0,dependents:0,
                 income:1800,expenses:1300,savings:5000,goals:[],
                 psychological_risk:worried_wait}).

questionnaire(10, D, D) :- !.
questionnaire(Step, D0, D) :-
    terminal_ui:section('QUESTIONARIO FINANZIARIO'),
    terminal_ui:progress(Step, 9),
    step_name(Step, Name), terminal_ui:subsection(Name),
    terminal_ui:info('B = indietro, oppure inserisci il valore richiesto.'),
    question(Step, D0, Response),
    ( Response = back ->
        ( Step =:= 1 -> D = cancelled
        ; Prev is Step - 1, questionnaire(Prev,D0,D) )
    ; Response = profile_update(D1) ->
        Next is Step + 1, questionnaire(Next,D1,D)
    ).

step_name(1, '01 / Eta').
step_name(2, '02 / Situazione lavorativa').
step_name(3, '03 / Situazione familiare').
step_name(4, '04 / Persone a carico').
step_name(5, '05 / Entrate mensili').
step_name(6, '06 / Spese essenziali mensili').
step_name(7, '07 / Risparmi disponibili').
step_name(8, '08 / Acquisti e obiettivi futuri').
step_name(9, '09 / Tolleranza psicologica al rischio').

question(1,D,R) :-
    read_number('Eta (18-150):',integer,18,150,V),
    update_or_back(V,D,age,R).
question(2,D,R) :-
    terminal_ui:menu_item(1,'Contratto a tempo indeterminato'),
    terminal_ui:menu_item(2,'Contratto a tempo determinato'),
    terminal_ui:menu_item(3,'Non occupato'),
    read_choice_back(['1'-permanent,'2'-temporary,'3'-none],V),
    update_or_back(V,D,employment,R).
question(3,D,R) :-
    terminal_ui:menu_item(1,'Ho un partner'),
    terminal_ui:menu_item(2,'Non ho un partner'),
    read_choice_back(['1'-yes,'2'-no],Partner),
    ( Partner == back -> R = back
    ; Partner == no -> New = D.put(_{partner:no,partner_employment:none,partner_salary:0}), R = profile_update(New)
    ; terminal_ui:subsection('Informazioni sul partner'),
      terminal_ui:menu_item(1,'Lavoro a tempo indeterminato'),
      terminal_ui:menu_item(2,'Lavoro a tempo determinato'),
      terminal_ui:menu_item(3,'Non occupato'),
      read_choice_back(['1'-permanent,'2'-temporary,'3'-none],Employment),
      ( Employment == back -> R = back
      ; read_number('Reddito mensile netto del partner (EUR):',money,0,1000000000,Salary),
        ( Salary == back -> R = back
        ; New = D.put(_{partner:yes,partner_employment:Employment,partner_salary:Salary}), R = profile_update(New) ) ) ).
question(4,D,R) :- read_number('Numero persone a carico (0-200):',integer,0,200,V), update_or_back(V,D,dependents,R).
question(5,D,R) :- read_number('Entrate personali nette al mese (EUR):',money,0,1000000000,V), update_or_back(V,D,income,R).
question(6,D,R) :- read_number('Spese essenziali mensili (EUR):',money,0,1000000000,V), update_or_back(V,D,expenses,R).
question(7,D,R) :- read_number('Risparmi attuali (EUR):',money,0,100000000000,V), update_or_back(V,D,savings,R).
question(8,D,R) :-
    terminal_ui:info('Puoi aggiungere piu obiettivi. Importo 0 per terminare.'),
    collect_goals(1, [], Goals),
    ( Goals == back -> R = back ; New = D.put(goals,Goals), R = profile_update(New) ).
question(9,D,R) :-
    terminal_ui:info('Immagina una perdita improvvisa del 10% sugli investimenti.'),
    terminal_ui:menu_item(1,'Venderei per evitare altre perdite'),
    terminal_ui:menu_item(2,'Aspetterei, ma sarei preoccupato'),
    terminal_ui:menu_item(3,'Aspetterei con tranquillita'),
    read_choice_back(['1'-sell,'2'-worried_wait,'3'-calm_wait],V),
    update_or_back(V,D,psychological_risk,R).

update_or_back(back,_,_,back) :- !.
update_or_back(V,D,Key,profile_update(New)) :- New = D.put(Key,V).

% Avoid recursion on invalid input and accept comma-decimal money amounts.
read_number(Label,Kind,Min,Max,Value) :-
    repeat,
    terminal_ui:prompt(Label,S),
    ( S == end_of_file -> Value = back, !
    ; normal_input(S,T),
      ( T == "b" -> Value = back, !
      ; parse_number(T,Kind,N), N >= Min, N =< Max
      -> Value = N, !
      ; terminal_ui:error_message('Valore non valido o fuori intervallo.'), fail ) ).

parse_number(S,integer,N) :- catch(number_string(N,S),_,fail), integer(N).
parse_number(S,money,N) :-
    string_chars(S,Chars), maplist(decimal_char,Chars,Converted),
    string_chars(US,Converted),
    catch(number_string(N0,US),_,fail), number(N0),
    N is round(N0*100)/100.
decimal_char(',', '.') :- !.
decimal_char(C,C).

normal_input(S,Clean) :- normalize_space(string(Trim),S), string_lower(Trim,Clean).

read_choice_back(Pairs,Value) :-
    repeat,
    terminal_ui:prompt('Scelta:', S),
    ( S == end_of_file -> Value=back, !
    ; normal_input(S,T),
      ( T == "b" -> Value=back, !
      ; atom_string(Atom,T), memberchk(Atom-Value,Pairs) -> !
      ; terminal_ui:error_message('Opzione non valida.'), fail ) ).

choose(Allowed, Choice) :-
    repeat,
    terminal_ui:prompt('Scelta:',S),
    ( S == end_of_file -> Choice='0', !
    ; normal_input(S,T),
      ( atom_string(Atom,T), memberchk(Atom,Allowed) -> Choice=Atom, !
      ; terminal_ui:error_message('Seleziona una delle opzioni disponibili.'), fail ) ).

collect_goals(Index,Acc,Goals) :-
    format('~n  Obiettivo numero ~d~n',[Index]),
    read_number('Importo (0 = termina):',money,0,100000000000,Amount),
    ( Amount == back -> Goals=back
    ; Amount =:= 0 -> reverse(Acc,Goals)
    ; terminal_ui:prompt('Descrizione:',Description),
      ( Description == end_of_file -> Goals=back
      ; normal_input(Description,Clean),
        ( Clean == "b" -> Goals=back
        ; Clean == "" -> terminal_ui:error_message('Descrizione obbligatoria.'),
          collect_goals(Index,Acc,Goals)
        ; read_number('Tra quanti anni (almeno 1):',integer,1,150,Years),
          ( Years == back -> Goals=back
          ; goal_horizon_max(Max),
            (Years > Max -> terminal_ui:warning('Oltre 10 anni: obiettivo non conteggiato nel pilastro obbligazionario.') ; true),
            Next is Index+1,
            collect_goals(Next,[goal(Index,Description,Amount,Years)|Acc],Goals) ) ) ) ).

confirm_profile(D, Answer) :-
    terminal_ui:section('VERIFICA LE RISPOSTE'),
    print_profile(D),
    terminal_ui:menu_item(1,'Conferma e calcola il piano'),
    terminal_ui:menu_item(2,'Modifica una risposta'),
    terminal_ui:menu_item(0,'Annulla'),
    choose(['0','1','2'],Choice),
    ( Choice == '1' -> Answer=yes
    ; Choice == '0' -> Answer=no
    ; edit_profile(D,Updated),
      (Updated == cancelled -> Answer=no ; confirm_profile(Updated,Answer)) ).

edit_profile(D,Updated) :-
    terminal_ui:section('MODIFICA UNA RISPOSTA'),
    forall(between(1,9,N),(step_name(N,Name),format('  [~d] ~w~n',[N,Name]))),
    terminal_ui:menu_item(0,'Torna al riepilogo'),
    choose(['0','1','2','3','4','5','6','7','8','9'],Choice),
    ( Choice == '0' -> Updated=D
    ; atom_number(Choice,Step),
      terminal_ui:subsection('Modifica il campo selezionato'),
      question(Step,D,R),
      ( R == back -> Updated=D ; R=profile_update(Updated) ) ).

print_profile(D) :-
    format('  Eta:                     ~d~n',[D.age]),
    format('  Lavoro:                  ~w~n',[D.employment]),
    format('  Partner:                 ~w~n',[D.partner]),
    (D.partner == yes -> format('  Lavoro partner:          ~w~n  Stipendio partner:       EUR ~2f~n',[D.partner_employment,D.partner_salary]) ; true),
    format('  Persone a carico:        ~d~n',[D.dependents]),
    format('  Entrate personali:       EUR ~2f~n',[D.income]),
    format('  Spese essenziali:        EUR ~2f~n',[D.expenses]),
    format('  Risparmi:                EUR ~2f~n',[D.savings]),
    format('  Reazione alle perdite:   ~w~n',[D.psychological_risk]),
    terminal_ui:subsection('Obiettivi futuri'), print_goals(D.goals).

% Commit only once: no obsolete facts remain when editing or starting over.
commit_profile(D) :-
    put_fact(age,D.age), put_fact(employment,D.employment),
    put_fact(partner,D.partner),
    put_fact(partner_employment,D.partner_employment),
    put_fact(partner_salary,D.partner_salary),
    put_fact(dependents,D.dependents),
    put_fact(income,D.income), put_fact(expenses,D.expenses),
    put_fact(savings,D.savings), put_fact(goals,D.goals),
    put_fact(psychological_risk,D.psychological_risk).

% =========================================================
% REPORT / FOUR PILLARS
% =========================================================
result :-
    get_fact(financial_resilience,Resilience),
    get_fact(risk_tolerance,Tolerance),
    get_fact(risk_index,Index),
    get_fact(monthly_surplus,Surplus),
    get_fact(emergency_months,Months),
    get_fact(savings,Savings),
    get_fact(targets,targets(T1,T2,T3)),
    get_fact(allocations,allocation(A1,A2,A3,A4)),
    terminal_ui:section('REPORT FINANZIARIO PERSONALIZZATO'),
    terminal_ui:success('Analisi completata'),
    format('  Patrimonio disponibile:   EUR ~2f~n',[Savings]),
    format('  Surplus mensile:          EUR ~2f~n',[Surplus]),
    terminal_ui:subsection('01 / INDICATORI DEL PROFILO'),
    format('  Resilienza finanziaria:   ~2f / 1.00~n',[Resilience]),
    format('  Tolleranza psicologica:   ~2f / 1.00~n',[Tolerance]),
    format('  Indice di rischio:        ~2f / 1.00~n',[Index]),
    format('  Copertura emergenze:      ~d mesi~n',[Months]),
    terminal_ui:info('L indice di rischio descrive il profilo ma non cambia gli importi dei pilastri.'),
    terminal_ui:subsection('02 / ALLOCAZIONE RISPARMI ATTUALI'),
    show_pillar(1,'Liquidita mensile',A1,T1,Savings),
    show_pillar(2,'Fondo emergenza',A2,T2,Savings),
    show_pillar(3,'Spese programmate (1-10 anni)',A3,T3,Savings),
    show_pillar(4,'Investimenti a lungo termine',A4,none,Savings),
    terminal_ui:subsection('03 / OBIETTIVI PROGRAMMATI'),
    get_fact(goals,Goals), print_goals(Goals),
    show_monthly_allocation.

show_pillar(N,Label,Amount,Target,Total) :-
    format('~n  ~d. ~w~n',[N,Label]),
    terminal_ui:money_row('Importo assegnato',Amount,Target),
    ( Total > 0 -> P is 100*Amount/Total ; P=0 ),
    bar(P), format(' ~1f%%~n',[P]).

bar(Percent) :-
    Count is max(0,min(30,round(Percent*30/100))),
    Rest is 30-Count,
    forall(between(1,Count,_),write('#')),
    forall(between(1,Rest,_),write('-')).

print_goals([]) :- writeln('  Nessun obiettivo programmato.').
print_goals(Goals) :-
    Goals \== [],
    forall(member(goal(_,Label,Amount,Years),Goals),
           format('  - ~w: EUR ~2f tra ~d anni~n',[Label,Amount,Years])).

show_monthly_allocation :-
    get_fact(monthly_surplus,Surplus),
    get_fact(monthly_allocations,allocation(M1,M2,M3,M4)),
    get_fact(remaining_gaps,gaps(G1,G2,G3)),
    terminal_ui:subsection('04 / PIANO DEL PROSSIMO MESE'),
    format('  Surplus disponibile: EUR ~2f~n',[Surplus]),
    terminal_ui:money_row('P1 - Liquidita',M1,none),
    terminal_ui:money_row('P2 - Emergenze',M2,none),
    terminal_ui:money_row('P3 - Obiettivi',M3,none),
    terminal_ui:money_row('P4 - Lungo periodo',M4,none),
    terminal_ui:subsection('Gap residui dopo il prossimo mese'),
    format('  P1: EUR ~2f  |  P2: EUR ~2f  |  P3: EUR ~2f~n',[G1,G2,G3]),
    terminal_ui:info('La proiezione va ricalcolata quando entrate, spese o obiettivi cambiano.').

result_menu :-
    terminal_ui:section('MENU DELLA CONSULENZA'),
    terminal_ui:menu_item(1,'Visualizza nuovamente il report'),
    terminal_ui:menu_item(2,'Strumenti finanziari suggeriti'),
    terminal_ui:menu_item(3,'Explanation Menu: WHY / HOW / KB'),
    terminal_ui:menu_item(4,'Guida ai quattro pilastri'),
    terminal_ui:menu_item(0,'Torna al menu principale'),
    choose(['0','1','2','3','4'],C),
    ( C == '0' -> true
    ; C == '1' -> result, terminal_ui:pause, result_menu
    ; C == '2' -> instruments_screen, result_menu
    ; C == '3' -> terminal_ui:section('SPIEGAZIONI DEL SISTEMA'), explanation_menu, result_menu
    ; C == '4' -> four_pillars, terminal_ui:pause, result_menu ).

instruments_screen :-
    terminal_ui:section('STRUMENTI FINANZIARI SUGGERITI'),
    terminal_ui:info('Informazioni educative; non e una raccomandazione di acquisto.'),
    terminal_ui:menu_item(1,'Strumenti per i pilastri finanziati'),
    terminal_ui:menu_item(2,'Esplora un singolo pilastro'),
    terminal_ui:menu_item(3,'Mostra tutti gli strumenti'),
    terminal_ui:menu_item(0,'Indietro'),
    choose(['0','1','2','3'],C),
    ( C == '0' -> true
    ; C == '1' -> show_personalized_instruments, terminal_ui:pause, instruments_screen
    ; C == '2' -> pillar_selection, instruments_screen
    ; C == '3' -> show_financial_instruments, terminal_ui:pause, instruments_screen ).

pillar_selection :-
    terminal_ui:subsection('Scegli il pilastro da esplorare'),
    forall(between(1,4,N),format('  [~d] Pilastro ~d~n',[N,N])),
    terminal_ui:menu_item(0,'Indietro'),
    choose(['0','1','2','3','4'],C),
    (C == '0' -> true ; atom_number(C,N), show_pillar_instruments(N), terminal_ui:pause).

four_pillars :-
    terminal_ui:section('GUIDA AI QUATTRO PILASTRI'),
    terminal_ui:subsection('1 / Liquidita mensile'),
    writeln('  Disponibilita immediata per affitto, spese, bollette e acquisti quotidiani.'),
    terminal_ui:subsection('2 / Fondo emergenza'),
    writeln('  Riserva prudente per imprevisti e interruzioni delle entrate.'),
    terminal_ui:subsection('3 / Obiettivi da 1 a 10 anni'),
    writeln('  Capitale destinato alle spese programmate entro dieci anni.'),
    terminal_ui:subsection('4 / Lungo periodo'),
    writeln('  Investimenti con orizzonte superiore a dieci anni e rischio di mercato.'),
    terminal_ui:info('L ordine P1 -> P2 -> P3 -> P4 protegge prima le necessita piu vicine.').

help_screen :-
    terminal_ui:section('GUIDA ALL UTILIZZO'),
    writeln('  1. Seleziona Nuova consulenza dal menu principale.'),
    writeln('  2. Rispondi alle nove sezioni del questionario.'),
    writeln('  3. Usa B per tornare indietro durante la compilazione.'),
    writeln('  4. Rivedi o modifica i dati nel riepilogo.'),
    writeln('  5. Consulta report, strumenti e motivazioni WHY/HOW/KB.'),
    terminal_ui:info('I numeri sono euristici didattici, non previsioni garantite.').

% =========================================================
% NON-INTERACTIVE DEMOS (preserve legacy demo/0; support demo/10)
% =========================================================
demo :-
    demo(26,temporary,no,none,0,1800,1300,5000,
         [goal(1,"Car",10000,2)],worried_wait).

demo(Age,Employment,Partner,PartnerEmployment,PartnerSalary,
     Income,Expenses,Savings,Goals,Psych) :-
    reset_system,
    D=profile{age:Age,employment:Employment,partner:Partner,
              partner_employment:PartnerEmployment,partner_salary:PartnerSalary,
              dependents:0,income:Income,expenses:Expenses,savings:Savings,
              goals:Goals,psychological_risk:Psych},
    commit_profile(D), infer, result.
