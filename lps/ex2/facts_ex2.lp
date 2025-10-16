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

% 'real' simple example including production plan constraints
% productionPlan(fullFuselageShort,section34).
%productionPlan(fullFuselageShort,section1).
%productionPlan(fullFuselageShort,section34).
%productionPlan(fullFuselageShort,section67).
%productionPlan(section34,section3).
%productionPlan(section34,section4).
%productionPlan(section67,section7).
%productionPlan(section67,section6).

%offer(l1,fullFuselageShort,10).
%demand(l1,section1,10).
%demand(l1,section34,10).
%demand(l1,section67,10).

%offer(l2,section1,10).

%offer(l4,section34,10).
%demand(l4,section3,10).
%demand(l4,section4,10).

%offer(l6,section67,10).
%demand(l6,section6,10).
%demand(l6,section7,10).

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