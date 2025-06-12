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
offer(p1,l1,10).
offer(p2,l1,40).
offer(p1,l2,20).

% netSupplyDemand: part name, location, demand/ consumed/able
demand(p2,l2,10).
demand(p1,l5,10).
demand(p2,l5,20).
demand(p1,l6,20).
demand(p2,l6,10).

demandSupply(P,L,0) :- not offer(P,L,_), not demand(P,L,_), part(P), location(L).
demandSupply(P,L,O) :- offer(P,L,O).
demandSupply(P,L,D) :- demand(P,L,M), D=M*-1.

%production plan
productionPlan(p1,p2).

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


#const maxNrParts = 40.
#const maxFreq = 10.

numFlow(1..maxNrParts).
num(1..maxFreq).

{flow((From,To),Part,N):numFlow(N),N<=D,offer(Part,From,D);
flow((From,To),Part,N):numFlow(N),N<=D,demand(Part,To,D);
flow((From,To),Part,N):numFlow(N),flow((_,From),Part,D), N<=D;
flow((From,To),Part,N):numFlow(N),flow((To,_),Part,D), N<=D} :-route(From,To,_,_,_).

:- flow((From,To),Part,N1), flow((From,To),Part,N2), N1!=N2.
:- flow((From,To),Part,N), demand(Part,From,D).
:- flow((From,To),Part,N), offer(Part,To,D).

:- DS!=Out-In, In=#sum{N,From:flow((From,Loc),Part,N)}, Out=#sum{N,To:flow((Loc,To),Part,N)}, demandSupply(Part,Loc,DS).

{packingList(P,TR,N)} :-  transportCapacity(TR,Cap), Cap>=N, partSize(P,N).
{packingList((P,L),TR,M)}:- packingList(L,TR,T), transportCapacity(TR,Cap), Cap>=M, M=T+N, partSize(P,N).

#show packingList/3. 
% symmetry breaking
:- packingList((P1,P2),_,_), productionPlan(P2,P1).

{countPartsInL(Part,Part,1)}:- part(Part).
{countPartsInL((Part,L),Part,V+1)} :- countPartsInL(L,Part,V), packingList(L,_,_).

{transportLink((From,To), L, TR, Freq): packingList(L,TR,_), num(Freq)} :- flow((From,To),Part,T).

:- T!=#sum{N*Freq,TR:transportLink((From,To), L, TR, Freq),countPartsInL(L,Part,N)},flow((From,To),Part,T).

#minimize{Freq*D*C,From,To,TR:transportLink((From,To), L, TR, Freq),packingList(L,TR,_), route(From,To,TR,D,C)}.


#show flow/3.
#show packingPattern/4.
#show transportLink/4.
