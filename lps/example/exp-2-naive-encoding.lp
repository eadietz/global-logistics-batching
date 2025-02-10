% location: name
location(l1).
location(l2).

% transportResource: name, capacity, co2emissions, cost, speed
transportResource(tr1).
transportResource(tr2).
transportResource(intrasite).

transportCapacity(tr1,10).
transportCapacity(tr2,15).
transportCapacity(intrasite,1000).

transportCO2(tr1,60).
transportCO2(tr2,45).
transportCO2(intrasite,0).

transportCost(tr1,56).
transportCost(tr2,42).
transportCost(intrasite,0).

transportSpeed(tr1,3).
transportSpeed(tr2,2).
transportSpeed(intrasite,0).

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
offer(p1,l1,3).
offer(p2,l1,2).
%offer(p2,l1,40).

% netSupplyDemand: part name, location, demand/ consumed/able
demand(p1,l2,3).
demand(p2,l2,2).

% route: from, to, transport mean, distance, cost (per 1)
route(l1,l12,tr1,1,56).
route(l12,l2,tr1,1,56).
%route(l1,l2,tr2,2,84).

%intrasite
%route(L,L,intrasite,1,1):- location(L).

% constraints
num(1..20).
packingPattern(0,t,t,t).

{packingPattern(Idx,Part,TR,N):packingPattern(Idx-1,_,_,_),partTR(Part,TR),num(Idx),num(N),partSize(Part,Size)}.

:- packingPattern(Idx,_,TR1,_), packingPattern(Idx,_,TR2,_), TR1!=TR2.
%:- packingPattern(Idx,Part,_,N1), packingPattern(Idx,Part,_,N2), N1!=N2.

:- #sum{N*Size:packingPattern(Idx,Part,TR,N),partSize(Part,Size)}>CAP, packingPattern(Idx,_,_,_),transportCapacity(TR,CAP).

% needs to be adapted!!! either there is an indrect route or there is a direct route where offer is available
{transport(Idx2,From,To,Freq,TR):num(Freq),packingPattern(Idx2,Part,_,_),transport(Idx1,_,From,_,_),
packingPattern(Idx1,Part,_,_),route(From,To,TR,_,_);
transport(Idx,From,To,Freq,TR):num(Freq),packingPattern(Idx,Part,_,_),offer(Part,From,O),route(From,To,TR,_,_)}.

%transport(Idx,From,To,Freq,TR:}1:-packingPattern(Idx,_,_,_).

:- D!=#sum{N*Freq:packingPattern(Idx,Part,_,N),transport(Idx,_,To,Freq,_)},demand(Part,To,D).
:- O!=#sum{N*Freq:packingPattern(Idx,Part,_,N),transport(Idx,_,To,Freq,_)}, offer(Part,From,O).

#minimize{C*D*Freq,Idx:transport(Idx,From,To,Freq,TR),route(From,To,TR,D,C)}.

#show transport/5.
#show packingPattern/4.
