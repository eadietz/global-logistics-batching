%demandSupply(P,L,0) :- not offer(P,L,_), not demand(P,L,_), part(P), location(L), not harbor(L).
%demandSupply(P,L,O) :- offer(P,L,O).
%demandSupply(P,L,D) :- demand(P,L,M), D=M*-1.

#const maxNrParts = 53.
numFlow(1..maxNrParts).

% constraints

% Specify possible flow

%{flow(From,To,Part,N):numFlow(N),part(Part),demand(Part,To,N);
%flow(From,To,Part,N):numFlow(N),part(Part),offer(Part,From,N);
%flow(From,To,Part,N):flow(To,Via,Part,N),harbor(To;Via),not harbor(From);
%flow(From,To,Part,N):flow(Via,From,Part,N),harbor(Via;From),not harbor(To);
%flow(From,To,Part,N):flow(_,From,Part,N), harbor(From;To),flow(To,_,Part,N)
%} :- route(From,To,_,_,_).

transportResource(intrasite). 
transportCO2(intrasite,0). 
transportCost(intrasite,0).
transportCapacity(intrasite,2000000000000).
partTR(Part,intrasite) :- part(Part).

root(eARFullFuselage).
1{flow(From,(),Part,N):offer(Part,From,N)}1 :- offer(Part,From,N), root(Part).


1{flowDO(From,To,Part,N): D<=O, N<=D, numFlow(N);
flowDO(From,To,Part,N): O<=D, N<=O, numFlow(N)}1 :- offer(Part,From,O), demand(Part,To,D). 

#show flowDO/4.
%:- not flowDO(From,_,Part,_), offer(Part,From,O).

direct(From,To,Part) :- route(From,To,_,_,_), demand(Part,To,_), offer(Part,From,_).
via1(From,(Via1,To),Part) :-  route(From,Via1,_,_,_), route(Via1,To,_,_,_), demand(Part,To,_), offer(Part,From,_).
via2(From,(Via1,Via2,To),Part) :-  route(From,Via1,_,_,_), route(Via1,Via2,_,_,_), route(Via2,To,_,_,_),  
                                           offer(Part,From,_), demand(Part,To,_).
        

%packingList(P,TR,N):-  transportCapacity(TR,Cap), Cap>=N, partSize(P,N).
%packingList((P,L),TR,M):- packingList(L,TR,T), transportCapacity(TR,Cap), Cap>=M, M=T+N, partSize(P,N).
%#show packingList/3.

%countPartsInL(Part,Part,1):- packingList(Part,_,_), part(Part).
%countPartsInL(Part1,Part2,0):- packingList(Part1,_,_), part(Part2), part(Part1), Part1!=Part2.
%countPartsInL((Head,L),Part,V1+V2) :- countPartsInL(L,Part,V2), countPartsInL(Head,Part,V1), packingList((Head,L),_,_).

1{flow(From,To,Part,N):
direct(From,To,Part);
flow(From,(Via1,To),Part,N): via1(From,(Via1,To),Part);
flow(From,(Via1,Via2,To),Part,(N,N,N)):via2(From,(Via1,Via2,To),Part)}1
:- flowDO(From,To,Part,N).

#show flow/4.
%:- flow(From,_,Part,N), offer(Part,From,O), O<N.
%:- flow(_,To,Part,N), demand(Part,From,D), N>D.
%:- flow(From,Part,(Via1,Via2,To),(N,M,P)), offer(Part,From,O), O<N.
%:- flow(From,Part,(Via1,Via2,To),(N,M,P)), demand(Part,To,D), P>D.

%#show flow/4.
%directFlow(From,To,Part) :- flow(From,To,Part,N), location(To).
%directFlow(From,To,Part) :- flow(From,(Via1,To),Part,(N,N)), location(To).
%directFlow(From,To,Part) :- flow(From,Part,(Via1,Via2,To),(_,N,N)), location(To).

%#show flow/4.
%#show offer/3.
%:- offer(Part,From,_), not flow(From,_,Part,_).
%:- offer(Part,From,_), not directFlow(From,_,Part).

% make sure that flow constraints hold
:- DS!=#sum{N,From:directFlow(From,Loc,Part,N)}, demandSupply(Part,Loc,DS), DS<0.

%#show directFlow/4.
%#show demandSupply/3.
%:- DS!=#sum{N,From:directFlow(From,Loc,Part,N)},
% demandSupply(Part,Loc,DS), DS<0.


%:- DS!=#sum{N,From:flow(From,Loc,Part,N)}, demand(Part,Loc,DS).
%:- DS!=Direct+Via1C+Via2C, Direct=#sum{N,To:flow(Loc,To,Part,N)},
%Via2C=#sum{N,Via1,Via2,To:flow(Loc,(Via1,Via2,To),Part,N)},
%Via1C=#sum{N,Via1,To:flow(Loc,(Via1,To),Part,N)}, 
% offer(Part,Loc,DS).
%:- In!=Out,Out=#sum{N,To:flow(Loc,To,Part,N)},In=#sum{N,From:flow(From,Loc,Part,N)}, harbor(Loc).


