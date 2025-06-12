% location: name
location(l1).
location(l2).
location(l3).
location(l4).
location(l5).
location(l6).

% transportResource: name, capacity, co2emissions, cost, speed
transportResource(tr1).
transportResource(tr2).

transportCapacity(tr1,10).
transportCapacity(tr2,15).

transportCO2(tr1,60).
transportCO2(tr2,45).

transportCost(tr1,56).
transportCost(tr2,42).

transportSpeed(tr1,3).
transportSpeed(tr2,2).

% Part: name, validTR, size, value
part(p1).
part(p2).
partSize(p1,4).
partSize(p2,3).
partTR(p1,tr1).
partTR(p1,tr2).
partTR(p2,tr1).
partTR(p2,tr2).
partVal(p1,1000).
partVal(p2,600).


% netSupplyDemand: part name, location, offer/ produced/able
offer(p1,l1,1).
%offer(p1,l2,2).
%offer(p2,l1,4).

% netSupplyDemand: part name, location, demand/ consumed/able
demand(p1,l5,1).
%demand(p1,l6,2).
%demand(p2,l2,1).
%demand(p2,l5,2).
%demand(p2,l6,1).

demandSupply(P,L,0) :- not offer(P,L,_), not demand(P,L,_), part(P), location(L).
demandSupply(P,L,O) :- offer(P,L,O).
demandSupply(P,L,D) :- demand(P,L,M), D=M*-1.

% route: from, to, transport mean, distance, cost (per 1)
route(l1,l2,tr1,1,56).
route(l1,l2,tr2,2,84).
route(l1,l3,tr1,3,168).
route(l1,l3,tr2,4,168).
route(l1,l4,tr1,4,224).
route(l1,l4,tr2,8,336).
route(l2,l3,tr1,1,56).
route(l2,l3,tr2,2,84).
route(l2,l4,tr1,2,112).
route(l2,l4,tr2,6,252).
route(l2,l6,tr1,2,112).
route(l3,l5,tr1,1,56).
route(l3,l5,tr2,3,126).
route(l3,l6,tr1,1,56).
route(l3,l6,tr2,2,84).
route(l4,l5,tr1,2,112).
route(l4,l5,tr2,4,168).
route(l4,l6,tr1,3,168).
route(l4,l6,tr2,5,210).

% constraints

num(1..3).
% all possible packing possibilities (knapsack unbound): part, transport mean, #
1{packing(Part,TR,N):num(N)} :- part(Part), partTR(Part,TR), transportResource(TR).

:- Cap<#sum{N*S,Part:packing(Part,TR,N),partSize(Part,S)}, transportCapacity(TR,Cap).

packingPattern(0,t,t,t).

{packingPattern(Idx,Part,TR,N):num(Idx),packingPattern(Idx-1,_,_,_)} :- packing(Part,TR,N).

:- Cap<#sum{N*S,Part:packingPattern(Idx,Part,TR,N),partSize(Part,S)}, num(Idx), transportCapacity(TR,Cap).

:- packingPattern(Idx,P,_,N1), packingPattern(Idx,P,_,N2), N1!=N2.
:- packingPattern(Idx,_,TR1,_), packingPattern(Idx,_,TR2,_), TR1!=TR2.

{transport((From,To,TR),Freq,Idx):packingPattern(Idx,_,TR,_), num(Freq)}:- route(From,To,TR,_,_).

% flow limitation constraint
:- DS!=Out-In, In=#sum{Freq*N,From:transport((From,Loc,TR),Freq,Idx),packingPattern(Idx,Part,TR,N)},
Out=#sum{Freq*N,To:transport((Loc,To,TR),Freq,Idx),packingPattern(Idx,Part,TR,N)},
demandSupply(Part,Loc,DS).

% minimize transport costs
#minimize{Freq*D*C,From,To,TR:transport((From,To,TR),Freq,_), route(From,To,TR,D,C)}.

% guiding/ heuristic
#maximize{N,Part: packingPattern(_,Part,TR,N), part(Part)}.

#show transport/3.
#show packingPattern/4.

