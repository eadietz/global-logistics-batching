#const maxNrParts = 100.
numFlow(1..maxNrParts).


% constraints


1{flow(From,To,Part,N): numFlow(N),N<=O, N<=D}1 :- offer(Part,From,O), demand(Part,To,D). 

 
:- DS!=#sum{N,From:flow(From,Loc,Part,N)}, demand(Part,Loc,DS).
:- DS!=#sum{N,To:flow(Loc,To,Part,N)}, offer(Part,Loc,DS), not root(Part).


direct(From,To,Part,TR) :- route(From,To,TR,_,_), demand(Part,To,_), offer(Part,From,_), partTR(Part,TR).
via1(From,(Via1,To),Part,(TR1,TR2)) :-  route(From,Via1,TR1,_,_), route(Via1,To,TR2,_,_), demand(Part,To,_), offer(Part,From,_),partTR(Part,TR1),partTR(Part,TR2).
via2(From,(Via1,Via2,To),Part,(TR1,TR2,TR3)) :-  route(From,Via1,TR1,_,_), route(Via1,Via2,TR2,_,_), route(Via2,To,TR3,_,_),  
offer(Part,From,_), demand(Part,To,_),partTR(Part,TR1),partTR(Part,TR2),partTR(Part,TR3).


1{routeflow(From,To,Part,N,TR):
direct(From,To,Part,TR);
routeflow(From,(Via1,To),Part,(N,N),(TR1,TR2)): via1(From,(Via1,To),Part,(TR1,TR2));
routeflow(From,(Via1,Via2,To),Part,(N,N,N),(TR1,TR2,TR3)):via2(From,(Via1,Via2,To),Part,(TR1,TR2,TR3))}1
:- flow(From,To,Part,N), From!=To.

bin(1..20).  
num(1..20).

binTR(B,TR) :- bin(B), partTR(_,TR).
#show binTR/2.
%:- routePackaging(_,_,TR1,_,B,_), routePackaging(_,_,TR2,_,B,_), TR1!=TR2.

%:- routePackaging(_,_,TR,_,B,_), transportCapacity(TR,C), C<#sum{N*Size,Part:routePackaging(_,_,_,Part,B,N),partSize(Part,Size)}, C>0.

1{routePackaging(From,To,TR,Part,B,M):bin(B),num(M)}1 :- routeflow(From,To,Part,N,TR). 

#show routePackaging/6.

%#maximize{B,TR:assign(Part,TR,B)}.

 
%1{routePackaging(From,To,Part,B):assign(Part,TR,B,M)}1 :- routeflow(From,To,Part,N,TR). %, location(To).

%#show routePackaging/4.
%1{transportLink(From,(Via1,To),(TR1,TR2),(B1,B2)): assign(Part,TR1,B1), binByTR(T1,B1),assign(Part,TR2,B2), binByTR(TR2,B2)
%}1 :- routeflow(From,(Via1,To),Part,(N,N),(TR1,TR2)), location(To).

%1{transportLink(From,(Via1,Via2,To),(TR1,TR2,TR3),(B1,B2,B3)):assign(Part,TR1,B1), binByTR(TR1,B1),assign(Part,TR2,B2), 
%binByTR(T2,B2),assign(Part,TR3,B3), binByTR(TR3,B3)
%}1 :- routeflow(From,(Via1,Via2,To),Part,(N,N,N),(TR1,TR2,TR3)), location(To).

%#show transportLink/4.

       
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