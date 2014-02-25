%predikat koji sluzi za ciscenje ispisa s ekrana
cls :-
	write('\e[H\e[2J').

%predikat u kojem je definiran izbornik, te koji se predikat poziva
%ovisno o odabiru kojeg korisnik napravi
izbornik :-
	cls,
	writeln('PROBLEM STABILNIH BRAKOVA'),
	writeln('~~~~~IZBORNIK~~~~~'),
	writeln('a. Ucitaj datoteku'),
	writeln('b. Upisi vlastite preference '),
	writeln('c. Pomoc'),
	writeln('d. Izlaz'),
	write('Vas izbor:  '), read(Izbor),%cita se korisnikov izbor
	(Izbor=='a' -> (trazi_datoteku),!; %poziva se predikat koji cita podatke iz odabrane datoteke
	(Izbor=='b' -> (cls, unos),!;  %poziva se predikat kojim korisnik moze zapisati vlastite podatke u datoteku koju kasnije moze ucitati
	(Izbor=='c' -> (cls, hlp),!;%poziva se predikat koji prikazuje upute za koristenje programa
	(Izbor=='d' -> halt)))). %prekida se izvodjenje programa

%predikat kojim se cita naziv datoteke iz koje uziamamo parametre i
%prosljedjuje se predikatu koji je glavni dio programa
trazi_datoteku:-
	nl,
	write('Upisite naziv datoteke: '),
	read(D),
	psb(D).%poziva se predikat koji izvodi rjesavanje problema stabilnih brakova


%predikat kojim se obavlja jednostavan nastavak rada programa
nastavak_programa:-
	nl,
	write('Unesite n. za nastavak...  '),
	read(X),
	(X=='n' -> izbornik).%poziva se predikat izbornik

%predikat koji poziva kljucne predikate za rjesavanje
%problema stabilnih brakova
psb(D):-
	cls,
	ucitaj_datoteku(D),%predikat koji ucitava podatke iz odabrane datoteke
	upari_samce,%predikat koji obavlja uparivanje muskaraca i zena
	write('Vrijeme za svadbu, sve najbolje mladencima!'),
	nl,
	vjencaj,%predikat koji podvrduje i "vjencava" uparene muskarce i zene
	nastavak_programa.%predikat koji izvodi nastavak programa

%predikat koji ucitava podatke iz odabrane datoteke
ucitaj_datoteku(D):-
	see(D),
	read(Broj_parova),%cita se broj parova kako bi se znalo koliko je muskaraca a koliko zena
	write('Ukupno muskaraca i zena: '),
	X is Broj_parova * 2,
	writeln(X),
	write('Moguce parova: '),
	writeln(Broj_parova),
	nl,
	writeln('Muskarci i preference:'),
	dohvati_podatke(Broj_parova, Broj_parova, musko),%poziva se predikat koji cita i zapisuje muskarce i njihove preference
	nl,
	writeln('Zene i preference:'),
	dohvati_podatke(Broj_parova, Broj_parova, zensko),%poziva se predikat koji cita i zapisuje muskarce i njihove preference
	nl,
	assert(parovi(Broj_parova)),%zapisuje se koliko je parova
	seen.


dohvati_preference(0,[]).

%predikat koji dohvaca preference i sprema ih u listu
dohvati_preference(Broj, [H|L]):-
	read(H),
	Broj2 is Broj-1,%broj se smanjuje kako bi procitali sve preference
	dohvati_preference(Broj2,L).


dohvati_podatke(_, 0, _).

%predikat koji dohvaca zene i njihove preference
dohvati_podatke(Broj, Broj2, zensko):-
	read(Ime),%cita se ime osobe cije preference trazimo
	dohvati_preference(Broj,L),%citamo preference trenutne osobe
	assert(preferira(Ime,L)),%zapisujemo osobu i njene preference
	assert(zensko(Ime)),%zapisujemo ime zenske osobe
	assert(samac(Ime)),%zapisujemo da je osoba samac
	write('\t'), write(Ime), write(' '), writeln(L),
	Broj3 is Broj2-1,%broj se smanjuje kako bi procitali sve zene i njihove preference
	dohvati_podatke(Broj, Broj3, zensko).

%predikat koji dohvaca muskarce i njihove preference
dohvati_podatke(Broj, Broj2, musko):-
	read(Ime),%cita se ime osobe cije preference trazimo
	dohvati_preference(Broj,L),%citamo preference trenutne osobe
	assert(preferira(Ime,L)),%zapisujemo osobu i njene preference
	assert(musko(Ime)),%zapisujemo ime muske osobe
	assert(samac(Ime)),%zapisujemo da je osoba samac
	write('\t'), write(Ime), write(' '), writeln(L),
	Broj3 is Broj2-1,%broj se smanjuje kako bi procitali sve muskarce i njihove preference
	dohvati_podatke(Broj, Broj3, musko).

%predikat koji uparuje samce(pocetno uparivanje)
upari_samce:-
	samac(Musko),
	samac(Zensko),
	musko(Musko),
	zensko(Zensko),
	assert(zaruceni(Musko,Zensko)),%zapisujemo parove
	write('Trenutno u vezi: '),
	write(Musko), write(' i '), writeln(Zensko),
	retract(samac(Musko)),%brisemo muskarca iz popisa samaca
	retract(samac(Zensko)),%brisemo zenu iz popisa samaca
	upari_samce.

upari_samce:-
	nl,
	zaruci.%nakon sto se obavi pocetno uparivanje krece proces zaruka

nadji(Osoba, [Osoba|_], 1).

%predikat koji trazi preferencu osobe i zapisuje kolika je preferenca
nadji(Osoba, [_|L], Stupanj_preferiranja):-
	nadji(Osoba, L, Broj),
	Stupanj_preferiranja is Broj+1.%zapravo redni broj na listi koji se koristi za usporedbu

%predikat koji trazi da li osoba preferira nekog drugog
nadji_preferencu(Ime1, Ime2, Preferenca):-
	preferira(Ime1, Lista_preferenci),
	nadji(Ime2, Lista_preferenci, Preferenca).%predikat koji trazi preferencu

%predikat koji odraduje preostala uparivanja i zarucuje muskarce i zene
zaruci:-
	zaruceni(Musko1, Zensko1),%uzima se prvi par
	zaruceni(Musko2, Zensko2),%uzima se drugi par
	nadji_preferencu(Musko1, Zensko2, On_preferira),%poziva se predikat koji trazi da li muskarac preferira neku drugu zenu i koliko
	nadji_preferencu(Musko1, Zensko1, On_preferira_staro),%provjerava se koliko muskarac preferira zenu s kojom je trenutno
	nadji_preferencu(Zensko2, Musko1, Ona_preferira),%provjerava se da li zena u drugom paru preferira nekog drugog muskarca i koliko
	nadji_preferencu(Zensko2, Musko2, Ona_preferira_staro),%provjerava se koliko zena preferira muskarca s kojim je trenutno
	On_preferira < On_preferira_staro,%usporedjuju se preference muskarca iz prvog para
	Ona_preferira < Ona_preferira_staro,%usporedjuju se preference zene iz drugog para
	retract(zaruceni(Musko1, Zensko1)),%ukoliko muskarac preferira neku drugu zenu raskidaju se zaruke
	retract(zaruceni(Musko2, Zensko2)),%ukoliko zena preferira nekog drugog muskarca raskidaju se zaruke
	write('Novi par: '),
	write(Musko1), write(' i '), writeln(Zensko2),
	write('Novi par: '),
	write(Musko2), write(' i '), writeln(Zensko1),
	nl,
	assert(zaruceni(Musko1, Zensko2)),%dodaje se novi par
	assert(zaruceni(Musko2, Zensko1)),%dodaje se novi par
	zaruci.

%sve dok ima samaca se ponavlja uparivanje samaca i zarucivanje
zaruci:-
	not(samac(_)).

%predikat koji potvrduje konacne parove
vjencaj:-
	zaruceni(Musko, Zensko),
	retract(zaruceni(Musko, Zensko)),%micu se zaruceni parovi
	assert(vjencani(Musko, Zensko)),%dodaju se vjencani parovi
	write('\t'), write(Musko),write(' i '),write(Zensko), nl,
	vjencaj.

%prekida se izvodjenje kada vjencamo sve zarucene parove
vjencaj:-
	not(zaruceni(_,_)).


%predikat koji omogucuje upis vlastitih preferenci
unos:-
	write('Unesite naziv datoteke: '), read(Datoteka),%uzima se naziv datoteke
	nl,
	write('Unijeti broj parova: '), read(Broj_parova),%uzima se broj parova
	assert(parovi(Broj_parova)),%zapisuje se koliko imamo parova
	nl,
	string_concat(Datoteka, '.txt', Datoteka2),%dodajemo ekstenziju za datoteku
	open(Datoteka2, append, S),%otvaramo novokreiranu datoteku i dodajemo podatke u nju
	write(S,Broj_parova),%zapisujemo broj parova u datoteku
	write(S,'.\n'),%novi red
	writeln('Unesite muskarce i njihove preference: '),
	zapisi_podatke(Broj_parova, S),%poziva se predikat koji upisuje muskarce i njihove preference
	nl,
	writeln('Unesite zene i njihove preference: '),
	zapisi_podatke(Broj_parova, S),%poziva se predikat koji upisuje zene i njihove preference
	close(S),%zatvara se tok podataka
	nl,
	write('Vasi podaci su zapisani u datoteku '),
	writeln(Datoteka2),
	nastavak_programa.%poziva se predikat za jednostavan nastavak programa

zapisi_podatke(0,_).

%predikat koji zapisuje osobe i njihove preference u datoteku
zapisi_podatke(Broj_parova, S):-
	write('Osoba i preference: '),
	read_line_to_codes(user_input, Input),%cita se korisnikov upis
	string_to_atom(Input,IA),%unos pretvaramo u atom
	write(S,IA),%zapisujemo unos
	write(S,'\n'),%nova linija
	Broj_parova2 is Broj_parova-1,%smanjujemo kako bi unijeli tocan broj osoba i preferenci (kao za for petlju)
	zapisi_podatke(Broj_parova2, S).


%predikat koji ispisuje pomoc, odnosno upute za koristenje programa i neke bitne informacije
%koje korisnik treba znati kako bi ucinkovito koristio program
hlp:-
	nl,
	writeln('~~~~~~~~UPUTSTVA ZA KORISTENJE PROGRAMA~~~~~~~~'),
	nl,
	writeln('----------------------------------'),
	writeln('Kratak opis:'),
	nl,
	writeln('Program je namijenjen rjesavanju problema stabilnih brakova'),
	writeln('Cilj je upariti N broj muskaraca i N broj zena prema njihovim preferencama, '),
	writeln('kako bi svaki od njih imao prikladnog para. Princip uparivanja je ostvaren '),
	writeln('pomocu Gale i Shapley algoritma kojem je cilj pokazati kako se iz bilo '),
	writeln('kojeg skupa preferenci mogu ostvariti stabilni brakovi.'),
	writeln('---------------------------------'),
	nl,
	writeln('Neke stvari koje je potrebno znati(Ogranicenja programa i nacin unosa podataka)'),
	nl,
	writeln('1. Odnos preferenci: '),
	write('\t'), writeln('Najpozeljniji/a -----> Najnepozeljniji/a'),
	write('\t'), writeln('    Lijevo      ----->      Desno       '),
	nl,
	writeln('2. Ucitavanje datoteke: '),
	write('\t'), writeln('Potrebno je upisati naziv zajedno sa ekstenzijom unutar jednostrukih navodnika.'),
	write('\t'), writeln('     npr. ''test.txt'''),
	nl,
	writeln('3. Unos osobe i njenih preferenci: '),
	write('\t'), writeln('Prvo se unosi osoba za koju zelimo dodati preference, a zatim slijede preference '),
	write('\t'), writeln('redom od najpozeljnijeg partnera do najnepozeljnijeg partnera. Pritom je potrebno '),
	write('\t'), writeln('nakon svakog imena staviti tocku.'),
	write('\t'), writeln('     npr. pero. ana. sanja. iva.'),
	writeln('---------------------------------'),
	nl,
	writeln('BITNA NAPOMENA!'),
	writeln('DA BI PROGRAM RADIO KAKO TREBA POTREBAN JE JEDNAK BROJ MUSKARACA I ZENA!'),
	nastavak_programa.%poziv predikata koji definira nastavak izvodenja programa
