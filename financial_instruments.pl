:- module(financial_instruments, [financial_instruments_menu/0, show_financial_instruments/0, show_pillar_instruments/1, show_instrument_category/1, recommended_category/2, instrument_example/7, offer_personalized_instruments/0, show_personalized_instruments/0, active_pillar/3]).

/*
 Financial Expert System - modulo educativo strumenti finanziari
 Dati consultati: 30/10/2026. Le condizioni possono cambiare.
 Struttura di instrument_example/7:
   instrument_example(Categoria, Nome, Identificativo, Metrica, Valore, Nota, URL).
 Nessuna raccomandazione personalizzata, nessun calcolo di rendimenti attesi.
*/

recommended_category(1, conto_remunerato).
recommended_category(2, conto_remunerato).
recommended_category(2, etf_monetario).
recommended_category(3, titoli_stato).
recommended_category(3, etf_obbligazionario).
recommended_category(4, etf_azionario).
recommended_category(4, etc_etn).

pillar_description(1, 'LIQUIDITA MENSILE', 'Soldi per le spese quotidiane: devono essere immediatamente disponibili, senza rischi di prezzo. Il conto corrente operativo resta la prima scelta; un deposito libero e solo complementare.').
pillar_description(2, 'FONDO DI EMERGENZA', 'Riserva per spese impreviste: privilegiare sicurezza e accesso rapido. Gli ETF monetari non garantiscono il capitale e richiedono vendita e regolamento.').
pillar_description(3, 'OBIETTIVI DA 1 A 10 ANNI', 'Risparmi per acquisti programmati: valutare obbligazioni con scadenze coerenti con le spese. Un ETF obbligazionario non ha generalmente una data certa di rimborso.').
pillar_description(4, 'LUNGO PERIODO', 'Capitale non necessario nel breve/medio periodo: strumenti diversificati come ETF azionari possono favorire la crescita, ma espongono a perdite importanti. ETC ed ETN sono solo eventuali componenti accessorie e piu rischiose.').

category_description(conto_remunerato, 'CONTI REMUNERATI / DEPOSITI LIBERI', 'Depositi bancari che riconoscono interessi sulla giacenza. Sono utili per liquidita e riserva emergenze perche normalmente non oscillano come titoli quotati. Verificare tempi di prelievo, promozioni, imposte e schema di garanzia applicabile (in generale fino a 100.000 EUR per depositante e banca). I tassi sono lordi e variabili.').
category_description(etf_monetario, 'ETF MONETARI / ULTRASHORT', 'Fondi quotati esposti ai tassi monetari in euro o a obbligazioni ultrabrevi. Possono essere usati per la parte non immediatamente necessaria del fondo emergenza. Rischi: prezzo, credito, swap dove presenti, spread, commissioni e tempi di liquidazione. NON sono conti bancari garantiti.').
category_description(titoli_stato, 'TITOLI DI STATO ITALIANI', 'Obbligazioni del Tesoro: BOT a breve durata, BTP a tasso fisso e BTP indicizzati all inflazione. In genere hanno rimborso nominale alla scadenza salvo rischio emittente, ma possono perdere valore prima della scadenza. I prezzi e i rendimenti effettivi dipendono dal singolo ISIN e dal momento dell acquisto.').
category_description(etf_obbligazionario, 'ETF OBBLIGAZIONARI', 'Fondi che diversificano fra numerose obbligazioni. Sono utili per la componente obbligazionaria, ma una quota ETF puo variare con tassi e spread e non equivale a detenere una singola obbligazione fino alla scadenza. Per obiettivi con data certa preferire strumenti con scadenza coerente.').
category_description(etf_azionario, 'ETF AZIONARI', 'Fondi negoziati che replicano panieri di azioni. Per il pilastro di lungo periodo permettono diversificazione e bassi costi, ma non garantiscono ne capitale ne rendimento; possono registrare ribassi anche prolungati.').
category_description(etc_etn, 'ETC / ETN (SOLO EVENTUALI SATELLITI)', 'Titoli di debito quotati legati a materie prime o criptoattivita. Un ETC su oro o argento non genera cedole; un ETN su Bitcoin espone a fortissima volatilita e rischi strutturali/emittente. Non sono ETF UCITS, non sostituiscono il fondo di emergenza e non sono indispensabili ai quattro pilastri.').

% --- Depositi: tasso promozionale o costo, sempre con condizioni esplicite ---
instrument_example(conto_remunerato, 'Findomestic Conto Deposito libero', 'Deposito bancario', 'Tasso lordo annuo 01/07-31/12/2026', '2,00%', 'Nessun vincolo; apertura e gestione gratuite; tasso ricalcolato semestralmente.', 'https://www.findomestic.it/conti-e-carte/conto-deposito').
instrument_example(conto_remunerato, 'ING Conto Arancio', 'Deposito bancario', 'Tasso promozionale lordo fino a 12 mesi', '4,00%', 'Solo con requisiti promozionali (conto, stipendio e servizio indicati sul sito); offerta valida fino al 31/01/2027; gestione gratuita.', 'https://www.ing.it/conto-arancio/conto-deposito-online.html').
instrument_example(conto_remunerato, 'ING Deposito Arancio 12 mesi', 'Deposito a termine', 'Tasso standard annuo lordo (documento 2026)', '2,00%', 'Importo da 10.000 EUR; vincolo 12 mesi; se si estingue prima non si percepiscono gli interessi pattuiti. Non adatto alla liquidita immediata.', 'https://secure.ing.it/PDF/DC_CA_DDS_CONDGEN.pdf').

% --- ETF a breve durata ---
instrument_example(etf_monetario, 'Xtrackers II EUR Overnight Rate Swap 1C', 'LU0290358497', 'TER annuo', '0,10%', 'Ticker XEON; accumulazione; replica sintetica del tasso overnight, con rischio di controparte.', 'https://www.justetf.com/it/etf-profile.html?isin=LU0290358497').
instrument_example(etf_monetario, 'Amundi EUR Overnight Return Acc', 'FR0010510800', 'TER annuo', '0,10%', 'Replica sintetica; accumulazione; rendimento variabile con i tassi di mercato.', 'https://www.justetf.com/it/etf-profile.html?isin=FR0010510800').
instrument_example(etf_monetario, 'iShares EUR Ultrashort Bond Dist', 'IE00BCRY6557', 'TER annuo', '0,09%', 'Ticker ERNE; corporate investment grade a brevissima scadenza; distribuzione trimestrale, rischio credito.', 'https://www.ishares.com/it/investitori-professionali/it/prodotti/258114/ishares-euro-ultrashort-bond-ucits-etf').

% --- Titoli di Stato: tre esempi reali di tipologia, non singoli titoli/prezzi ---
instrument_example(titoli_stato, 'BOT (Buoni Ordinari del Tesoro)', 'Famiglia MEF: BOT', 'Tassazione usuale proventi', '12,50%', 'Tipicamente durate 3, 6, 12 mesi; emessi a sconto, rendimento effettivo da calcolare su prezzo/commissioni.', 'https://www.dt.mef.gov.it/it/debito_pubblico/titoli_di_stato/quali_sono_titoli/bot/').
instrument_example(titoli_stato, 'BTP (Buoni del Tesoro Poliennali)', 'Famiglia MEF: BTP', 'Tassazione usuale proventi', '12,50%', 'Cedola fissa; selezionare una emissione con scadenza coerente; rendimento a scadenza non coincide con cedola.', 'https://www.dt.mef.gov.it/it/debito_pubblico/titoli_di_stato/quali_sono_titoli/btp/').
instrument_example(titoli_stato, 'BTP Italia', 'Famiglia MEF: BTP Italia', 'Tassazione usuale proventi', '12,50%', 'Indicizzazione alla inflazione italiana secondo condizioni del titolo; verificare specifico ISIN e cedole.', 'https://www.dt.mef.gov.it/it/debito_pubblico/titoli_di_stato/quali_sono_titoli/btp_italia/').

% --- Obbligazionari ---
instrument_example(etf_obbligazionario, 'iShares Core EUR Government Bond Acc', 'IE0008U15456', 'TER annuo', '0,07%', 'Titoli di Stato area euro investment grade, tutte le scadenze: esposizione a variazioni dei tassi.', 'https://www.justetf.com/it/etf-profile.html?isin=IE0008U15456').
instrument_example(etf_obbligazionario, 'iShares Core EUR Corporate Bond Dist', 'IE00B3F81R35', 'TER annuo', '0,09%', 'Obbligazioni societarie euro investment grade, molte scadenze; rischio tassi e credito.', 'https://www.justetf.com/it/etf-profile.html?isin=IE00B3F81R35').
instrument_example(etf_obbligazionario, 'iShares EUR Ultrashort Bond Dist', 'IE00BCRY6557', 'TER annuo', '0,09%', 'Alternativa per orizzonti piu brevi; obbligazioni corporate euro ultracorte, senza rimborso garantito.', 'https://www.justetf.com/it/etf-profile.html?isin=IE00BCRY6557').

% --- Azionari ---
instrument_example(etf_azionario, 'Vanguard FTSE All-World Acc', 'IE00BK5BQT80', 'TER annuo', '0,14%', 'Ticker VWCE; azioni paesi sviluppati ed emergenti; accumulazione, rischio azionario e cambio.', 'https://www.justetf.com/it/etf-profile.html?isin=IE00BK5BQT80').
instrument_example(etf_azionario, 'iShares Core MSCI World Acc', 'IE00B4L5Y983', 'TER annuo', '0,20%', 'Ticker SWDA; azioni paesi sviluppati, senza emergenti; accumulazione.', 'https://www.ishares.com/it/investitore-privato/it/prodotti/251882/ishares-msci-world-ucits-etf-acc-fund').
instrument_example(etf_azionario, 'iShares Core S&P 500 Acc', 'IE00B5BMR087', 'TER annuo', '0,07%', 'Ticker CSSPX; 500 grandi societa USA; concentrazione geografica sugli Stati Uniti.', 'https://www.justetf.com/it/etf-profile.html?isin=IE00B5BMR087').

% --- ETC / ETN: satellite non necessario ---
instrument_example(etc_etn, 'Invesco Physical Gold ETC', 'IE00B579F325', 'Costo annuo', '0,12%', 'ETC fisico su oro; niente cedole; rischio prezzo dell oro e valuta.', 'https://www.justetf.com/it/etf-profile.html?isin=IE00B579F325').
instrument_example(etc_etn, 'WisdomTree Physical Silver', 'JE00B1VS3333', 'Commissione gestione annua', '0,49%', 'ETC su argento fisico; elevata volatilita; dato tratto dalla scheda emittente, verificare aggiornamenti.', 'https://www.wisdomtree.eu/-/media/eu-media-files/key-documents/factsheet/etf-securities/factsheet---wisdomtree-physical-silver.pdf?sc_lang=it-it').
instrument_example(etc_etn, 'WisdomTree Physical Bitcoin', 'GB00BJYDH287', 'Commissione annua', 'Da verificare', 'ETP su Bitcoin: le schede 2025/2026 riportano commissioni/promozioni con scadenze differenti; consultare il KID attuale. Rischio molto elevato.', 'https://www.wisdomtree.eu/it-it/products/ucits-etfs-unleveraged-etps/cryptocurrency/wisdomtree-physical-bitcoin').

show_financial_instruments :-
    format('~n========== STRUMENTI FINANZIARI SUGGERITI ==========~n'),
    format('Catalogo educativo (dati verificati il 30/10/2026). Non e consulenza personalizzata.~n'),
    format('I rendimenti futuri non sono garantiti; i costi e le condizioni vanno ricontrollati.~n'),
    forall(between(1,4,P), show_pillar_instruments(P)).

show_pillar_instruments(Pillar) :-
    integer(Pillar), between(1,4,Pillar), !,
    pillar_description(Pillar, Title, Description),
    format('~n========== PILASTRO ~d - ~s ==========~n~s~n', [Pillar,Title,Description]),
    forall(recommended_category(Pillar,Category), show_instrument_category(Category)).
show_pillar_instruments(Pillar) :-
    format('Pilastro non valido: ~w. Valori ammessi: 1..4.~n', [Pillar]).

show_instrument_category(Category) :-
    category_description(Category,Title,Description), !,
    format('~n--- ~s ---~n~s~n', [Title,Description]),
    forall(instrument_example(Category,Name,Id,Metric,Value,Note,URL),
           (format('  * ~s (~s)~n', [Name,Id]),
            format('    ~s: ~s~n', [Metric,Value]),
            format('    ~s~n', [Note]),
            format('    Link: ~s~n', [URL]))).
show_instrument_category(Category) :-
    format('Categoria sconosciuta: ~w.~n',[Category]).

% =========================================================
% PERSONALIZED INTEGRATION WITH THE INFERENCE ENGINE
% =========================================================

:- use_module(inference_engine, [get_fact/2]).

% Display a pillar if it receives current savings OR next month's surplus.
% No investment quantities or product allocations are inferred.
active_pillar(Pillar, Current, NextMonth) :-
    get_fact(allocations, allocation(A1, A2, A3, A4)),
    get_fact(monthly_allocations, allocation(M1, M2, M3, M4)),
    nth1(Pillar, [A1,A2,A3,A4], Current),
    nth1(Pillar, [M1,M2,M3,M4], NextMonth),
    (Current > 0 -> true; NextMonth > 0).

show_personalized_instruments :-
    nl, writeln('=== STRUMENTI FINANZIARI IN BASE ALLA TUA ALLOCAZIONE ==='),
    writeln('Importi per pilastro, NON somme da investire automaticamente nei prodotti.'),
    writeln('Gli esempi sono informativi, non raccomandazioni di acquisto.'),
    writeln('Prima di scegliere verifica condizioni aggiornate, rischi e documentazione ufficiale.'),
    ( once(active_pillar(_,_,_))
    -> forall(active_pillar(Pillar, Current, NextMonth),
              ( format('~nPillar ~d - Risparmi correnti: EUR ~2f; prossimo mese: EUR ~2f~n',
                       [Pillar, Current, NextMonth]),
                show_pillar_instruments(Pillar) ))
    ;  writeln('Nessun pilastro ha un importo positivo: nessuno strumento da proporre.') ).

offer_personalized_instruments :-
    nl, writeln('Vuoi visualizzare gli strumenti finanziari suggeriti per i pilastri finanziati?'),
    writeln('1 = Si, visualizza i suggerimenti'),
    writeln('2 = No, passa all Explanation Menu'),
    prompt_instruments_choice.

prompt_instruments_choice :-
    repeat,
    write('Scelta [1/2]: '),
    read_line_to_string(user_input, Input),
    ( Input == end_of_file -> !
    ; normalize_space(string(Clean), Input),
      ( Clean == "1" -> !, show_personalized_instruments, financial_instruments_menu
      ; Clean == "2" -> !
      ; writeln('Scelta non valida. Digita 1 o 2.'), fail ) ).

% Optional navigation: for detailed info about another pillar.
financial_instruments_menu :-
    repeat,
    nl, writeln('=== STRUMENTI FINANZIARI SUGGERITI ==='),
    writeln('1-4 = Dettagli di un pilastro'),
    writeln('5 = Tutti gli strumenti'),
    writeln('0 = Prosegui all Explanation Menu'),
    write('Scelta: '),
    read_line_to_string(user_input, Input),
    ( Input == end_of_file -> !
    ; normalize_space(string(Clean), Input),
      ( Clean == "0" -> !
      ; member(Clean-Pillar, ["1"-1,"2"-2,"3"-3,"4"-4])
        -> show_pillar_instruments(Pillar), fail
      ; Clean == "5" -> show_financial_instruments, fail
      ; writeln('Scelta non valida.'), fail ) ).
