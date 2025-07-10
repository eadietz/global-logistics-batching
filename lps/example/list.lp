element(1..6).
%listLen(empty, 0).
%listLen(cons(E, L), K + 1) :- element(E); listLen(L, K); K < 5.
%is5List(L) :- listLen(L, 5).

num(1..2).
packingList(p1,tr1,4).
part(p1).
part(p2).
transportCapacity(tr1,10).
partSize(p1,4).
partSize(p2,3).

packingList(P,TR,N) :-  transportCapacity(TR,Cap), Cap>=N, partSize(P,N).
packingList((P,L),TR,M):- packingList(L,TR,T), transportCapacity(TR,Cap), Cap>=M, M=T+N, partSize(P,N).


%countPartsInL(Part,Part,1):- part(Part).
%countPartsInL((Part,L),Part,V1+1) :- countPartsInL(L,Part,V1), packingList(L,_,_).


countPartsInL(Part,Part,1):- packingList(Part,_,_), part(Part).
countPartsInL(Part1,Part2,0):- packingList(Part1,_,_), part(Part2), part(Part1), Part1!=Part2.
countPartsInL((Head,L),Part,V1+V2) :- countPartsInL(L,Part,V2), countPartsInL(Head,Part,V1), packingList((Head,L),_,_).

%countPartsInL((Part,L),Part,V1+1) :- countPartsInL(L,Part,V1), packingList(L,_,_).



%#show is5List/1.
#show packingList/3.
#show countPartsInL/3.

%packingList(P,TR,N) :-  transportCapacity(TR,Cap), Cap>=N, partSize(P,N).
%packingList((P,L),TR,M):- packingList(L,TR,T), transportCapacity(TR,Cap), Cap>=M, M=T+N, partSize(P,N).

%1{transportLink((From,To), L, TR, Freq): packingList(L,TR,_), num(Freq)} :- flow((From,To),Part,T).

%:- T!=#sum{N*Freq:transportLink((From,To), L, TR, Freq),packingList(L,TR,N)},flow((From,To),Part,T).
%:- T>#sum{N*Freq:transportLink((From,To), L, Freq),packingList(L,_,N)},flow((From,To),Part,T).

%#minimize{Freq*D*C,From,To,TR:transportLink((From,To), L, TR, Freq),packingList(L,TR,_), route(From,To,TR,D,C)}.
