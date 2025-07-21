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

1{transport(From,From,intrasite,Part):offer(Part,From,N)}1 :- offer(Part,From,N), root(Part).

1{flow(From,To,Part,N): D<=O, N<=D, numFlow(N);
flow(From,To,Part,N): O<=D, N<=O, numFlow(N)}1 :- offer(Part,From,O), demand(Part,To,D). 

%:- DS!=#sum{N,From:flow(From,Loc,Part,N)}, demand(Part,Loc,DS).
%:- DS!=#sum{N,To:flow(Loc,To,Part,N)}, offer(Part,Loc,DS).


{direct(From,To,Part,TR)} :- route(From,To,TR,_,_), demand(Part,To,_), offer(Part,From,_).
{via1(From,(Via1,To),Part,(TR1,TR2))} :-  route(From,Via1,TR1,_,_), route(Via1,To,TR2,_,_), harbor(Via1), demand(Part,To,_), offer(Part,From,_).
{via2(From,(Via1,Via2,To),Part,(TR1,TR2,TR3))} :-  route(From,Via1,TR1,_,_), route(Via1,Via2,TR2,_,_), harbor(Via1), harbor(Via2), route(Via2,To,TR3,_,_),  offer(Part,From,_), demand(Part,To,_).

1{routeflow(From,To,Part,N,TR):
direct(From,To,Part,TR);
routeflow(From,(Via1,To),Part,(N,N),(TR1,TR2)): via1(From,(Via1,To),Part,(TR1,TR2));
routeflow(From,(Via1,Via2,To),Part,(N,N,N),(TR1,TR2,TR3)):via2(From,(Via1,Via2,To),Part,(TR1,TR2,TR3))}1
:- flow(From,To,Part,N), From!=To.

#show routeflow/5.
%1{transport(From,To,TR,B): assign(Part,TR,B,M), binByTR(TR,B), routeflow(From,To,Part,N); 
%transport(From,(Via1,To),(TR1,TR2),(B1,B2)): routeflow(From,(Via1,To),Part,N),assign(Part,TR1,B1,M), binByTR(T1,B1),assign(Part,TR2,B2,M), binByTR(T2,B2);
%transport(From,(Via1,Via2,To),(TR1,TR2,TR3),(B1,B2,B3)):routeflow(From,(Via1,Via2,To)), assign(Part,TR1,B1,M), binByTR(T1,B1),assign(Part,TR2,B2,M), 
%binByTR(T2,B2),assign(Part,TR3,B3,M), binByTR(T1,B3)
%}1 :- routeflow(From,To,Part,N).

	
#show transport/4.

bin(1).
num(1..5).

binByTR(TR,B):- bin(B),transportCapacity(TR,C), C>0.

:- binByTR(TR,B), transportCapacity(TR,C), C<#sum{N*Size,Part:assign(Part,TR,B,N),partSize(Part,Size)}, C>0.

{assign(Part,TR,B,N)} :- binByTR(TR,B),num(N),part(Part).

#show assign/4.
%#maximize{B,N,TR:assign(Part,TR,B,N)}.

 
       
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


