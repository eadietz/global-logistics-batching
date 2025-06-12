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
offer(p1,l2,2).
%offer(p2,l1,4).

% netSupplyDemand: part name, location, demand/ consumed/able
demand(p1,l5,1).
demand(p1,l6,2).
%demand(p2,l2,1).
%demand(p2,l5,2).
%demand(p2,l6,1).


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

% all possible packing possibilities (knapsack unbound): part, transport mean, #
1{packing(Part,TR,N):num(N)}1 :- part(Part), partTR(Part,TR), transportResource(TR).

num(1..10).
packingPattern(0,t,t,t).

%1{packingPattern(Idx,Part,TR,N):num(Idx),packingPattern(Idx-1,_,_,_)}:- packing(Part,TR,N).

{packingPattern(Idx,Part,TR,N):packingPattern(Idx-1,_,_,_),partTR(Part,TR),num(N)}.


%:- packingPattern(Idx,_,_,N1), packingPattern(Idx,_,_,N2), N1!=N2.
:- packingPattern(Idx,_,TR1,_), packingPattern(Idx,_,TR2,_), TR1!=TR2.
%:- packingPattern(Idx,Part1,_,_), packingPattern(Idx,Part2,_,_), Part1!=Part2.
%:- packingPattern(Idx1,Part,TR,N), packingPattern(Idx2,Part,TR,N), Idx1!=Idx2.

#show packingPattern/4.

% it is not the case the the capacity of the transport resource is smaller than the size * number of time the part
%:- Cap<#sum{S*N,Part: packingPattern(_,Part,TR,N), part(Part)},  transportCapacity(TR,Cap).

%:- Cap<S*N, packingPattern(_,Part,TR,N), part(Part), partSize(Part,S), transportCapacity(TR,Cap).

:- Cap<#sum{N*S,Part:packingPattern(Idx,Part,TR,N),partSize(Part,S)}, num(Idx), transportCapacity(TR,Cap).


%#maximize{S*N,Part: packingPattern(_,Part,TR,N), part(Part)}.
% variable for each edge and part, presenting amount of parts transported on edge


{transportlink((From,To),TR)}:- route(From,To,TR,_,C)

{transport(Idx,Part,F,N,From,To,TR,C):packingPattern(Idx,Part,TR,N), num(F)}1:- route(From,To,TR,_,C).

%{transport(Idx,Part,F,N,From,To,TR,C):packingPattern(Idx,Part,TR,N), num(F)}1:- route(From,To,TR,_,C).

%#show transport/8.
%#show netSupplyDemand/3.
% flow limitation constraint

% flow conservation constraint -> extend to Parts
%:- D!=#sum{F*N:transport(_,Part,F,N,_,To,_,_)},demandSupply(Part,To,D), D<0.
%:- O!=#sum{F*N:transport(_,Part,F,N,From,_,_,_)}, demandSupply(Part,From,O), O>0.

% original

:- D!=#sum{F*N:transport(_,Part,F,N,_,To,_,_)},demand(Part,To,D).
:- O!=#sum{F*N:transport(_,Part,F,N,From,_,_,_)}, offer(Part,From,O).


% minimize transport costs:
#minimize{C*F,Parts,N,From,To,TR:transport(_,Parts,F,N,From,To,TR,C)}.

% translation
demandSupply(Part,Loc,0) :- not offer(Part,Loc,_), not demand(Part,Loc,_), part(Part), location(Loc).
demandSupply(Part,Loc,K) :- offer(Part,Loc,K).
demandSupply(Part,Loc,K) :- demand(Part,Loc,M), K=M*-1.

transportFreq(From, To, TM, Idx, Freq) :- transport(Idx,_,Freq,_,From,To,TM,_).

