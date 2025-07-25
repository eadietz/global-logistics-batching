%demandSupply(P,L,0) :- not offer(P,L,_), not demand(P,L,_), part(P), location(L), not harbor(L).
%demandSupply(P,L,O) :- offer(P,L,O).
%demandSupply(P,L,D) :- demand(P,L,M), D=M*-1.

#const maxNrParts = 100.
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

route(sacheon,montoirdeBretagne,truckOversizedLowBed,18,81).
route(sacheon,nola,truckOversizedLowBed,18,81).
route(sacheon,montoirdeBretagne,truckLongDistance,18,81).
route(sacheon,nola,truckLongDistance,18,81).

root(eARFullFuselage). 


1{flow(To,To,Part,D)}1:- offer(To,Part,D), root(Part).

1{flow(From,To,Part,N): numFlow(N),N<=O, N<=D}1 :- offer(Part,From,O), demand(Part,To,D), not root(Part). 

:- DS!=#sum{N,From:flow(From,Loc,Part,N)}, demand(Part,Loc,DS).
:- DS!=#sum{N,To:flow(Loc,To,Part,N)}, offer(Part,Loc,DS), not root(Part).

direct(From,To,Part,TR) :- route(From,To,TR,_,_), demand(Part,To,_), offer(Part,From,_), partTR(Part,TR).
via1(From,(Via1,To),Part,(TR1,TR2)) :-  route(From,Via1,TR1,_,_), route(Via1,To,TR2,_,_), harbor(Via1), demand(Part,To,_), offer(Part,From,_),partTR(Part,TR1),partTR(Part,TR2).
via2(From,(Via1,Via2,To),Part,(TR1,TR2,TR3)) :-  route(From,Via1,TR1,_,_), route(Via1,Via2,TR2,_,_), harbor(Via1), harbor(Via2), route(Via2,To,TR3,_,_),  
offer(Part,From,_), demand(Part,To,_),partTR(Part,TR1),partTR(Part,TR2),partTR(Part,TR3).

1{routeflow(From,To,Part,N,TR):
direct(From,To,Part,TR);
routeflow(From,(Via1,To),Part,(N,N),(TR1,TR2)): via1(From,(Via1,To),Part,(TR1,TR2));
routeflow(From,(Via1,Via2,To),Part,(N,N,N),(TR1,TR2,TR3)):via2(From,(Via1,Via2,To),Part,(TR1,TR2,TR3))}1
:- flow(From,To,Part,N), From!=To.

#show routeflow/5.
%#show binByTR/2.
 
%1{assign(Part,TR,B):binByTR(TR,B),routeflow(From,To,Part,N,TR),location(To);
%assign(Part,TR,B):binByTR(TR,B),routeflow(From,(Via1,To),Part,(N,N),(TR1,TR2)),location(To);
%assign(Part,TR,B):binByTR(TR,B),routeflow(From,(Via1,Via2,To),Part,(N,N,N),(TR1,TR2,TR3)),
%location(To)}1 :- flow(From,To,Part,N), From!=To.
%1{transportLink(From,To,TR,B): assign(Part,TR,B), binByTR(TR,B)
%}1 :- routeflow(From,To,Part,N,TR), location(To).%

%1{transportLink(From,(Via1,To),(TR1,TR2),(B1,B2)): assign(Part,TR1,B1), binByTR(T1,B1),assign(Part,TR2,B2), binByTR(TR2,B2)
%}1 :- routeflow(From,(Via1,To),Part,(N,N),(TR1,TR2)), location(To).

%1{transportLink(From,(Via1,Via2,To),(TR1,TR2,TR3),(B1,B2,B3)):assign(Part,TR1,B1), binByTR(TR1,B1),assign(Part,TR2,B2), 
%binByTR(T2,B2),assign(Part,TR3,B3), binByTR(TR3,B3)
%}1 :- routeflow(From,(Via1,Via2,To),Part,(N,N,N),(TR1,TR2,TR3)), location(To).

%#show transportLink/4.

bin(1..15).  
num(1..15).

binByTR(TR,B):- bin(B),transportCapacity(TR,C), C>0.

%:- binByTR(TR,B), transportCapacity(TR,C), C<#sum{Size,Part:assign(Part,TR,B),partSize(Part,Size)}.

{assign(Part,TR,B)} :- binByTR(TR,B),part(Part).

#show assign/3.
#maximize{B,TR:assign(Part,TR,B)}.

 
       
%#show routeflow/4.

%#show flow/4.
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
%:- DS!=#sum{N,From:directFlow(From,Loc,Part,N)}, demandSupply(Part,Loc,DS), DS<0.

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


%%%%%%%%%%%%%%%%%%%%% assertions %%%%%%%%%%%%%%%%%%%%%

%route(From,To,Part) :- flow(From,To,Part,_), direct(From,To,Part,_).
%route(From,To,Part) :- flow(From,To,Part,_), via1(From,(_,To),Part,_).
%route(From,To,Part) :- flow(From,To,Part,_), not via2(From,(_,_,To),Part,_).
%noRoute(From,To,Part) :- not route(From,To,Part), flow(From,To,Part,_).
%#show noRoute/3.