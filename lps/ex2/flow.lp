1{flow(From,From,Part,N):offer(Part,From,N)}1 :- offer(Part,From,N), root(Part).
1{transportLink(From,From,intrasite,N)}1 :- flow(From,From,Part,N), root(Part).
1{assign(Part,intrasite,N)}1 :- flow(From,From,Part,N),root(Part).



demandSupply(P,L,0) :- not offer(P,L,_), not demand(P,L,_), part(P), location(L).
demandSupply(P,L,O) :- offer(P,L,O).
demandSupply(P,L,D) :- demand(P,L,M), D=M*-1.

#const maxNrParts = 20.
#const maxFreq = 20.

numFlow(1..maxNrParts).
num(0..maxFreq).

% constraints

% Specify possible flow

{flow(From,To,Part,N):numFlow(N),part(Part)} :-route(From,To,_,_,_).

:- flow(From,To,Part,N1), flow(From,To,Part,N2), N1!=N2.
:- flow(From,To,Part,N), demand(Part,From,D).
:- flow(From,To,Part,N), offer(Part,To,D).

% make sure that flow constraints hold
:- DS!=Out-In, In=#sum{N,From:flow(From,Loc,Part,N)}, Out=#sum{N,To:flow(Loc,To,Part,N)}, demandSupply(Part,Loc,DS).

% Specify possible packing lists

{packingList(P,TR,N)}:-  transportCapacity(TR,Cap), Cap>=N, partSize(P,N).
{packingList((P,L),TR,M)}:- packingList(L,TR,T), transportCapacity(TR,Cap), Cap>=M, M=T+N, partSize(P,N).

countPartsInL(Part,Part,1):- packingList(Part,_,_), part(Part).
countPartsInL(Part1,Part2,0):- packingList(Part1,_,_), part(Part2), part(Part1), Part1!=Part2.
countPartsInL((Head,L),Part,V1+V2) :- countPartsInL(L,Part,V2), countPartsInL(Head,Part,V1), packingList((Head,L),_,_).

% based on flow, define transport link with corresponding packing list 

1{transportLink(From,To, L, TR, Freq): packingList(L,TR,_), countPartsInL(L,Part,V),num(V),V>0,num(Freq)} :- flow(From,To,Part,T).

% make sure that transport links conform with flow
:- T!=#sum{N*Freq,L,TR:transportLink(From,To, L, TR, Freq),countPartsInL(L,Part,N)},flow(From,To,Part,T).
:- 0!=#sum{N*Freq,L,TR:transportLink(From,To, L, TR, Freq),countPartsInL(L,Part,N)}, not flow(From,To,Part,_), location(From), location(To), part(Part).

:- transportLink(From,To, L, TR, Freq1), transportLink(From,To, L, TR, Freq2), Freq1!=Freq2.

% symmetry breaking
%numPart(p1,1).
%numPart(p2,2).
:- packingList((P1,P2),TR,N), numPart(P1,V1), numPart(P2,V2), V1>V2.
:- packingList((P1,(P2,L)),TR,N), numPart(P1,V1), numPart(P2,V2), V1>V2.

% optimization on transportation costs
#minimize{Freq*D*C,From,To,TR:transportLink(From,To, L, TR, Freq), route(From,To,TR,D,C)}.
 
#show flow/4.
#show transportLink/5.
