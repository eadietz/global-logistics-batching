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
part(fullFuselage).
part(mCA1).
part(mCA2).
part(mCA3).
partSize(fullFuselage,12).
partSize(mCA1,3).
partSize(mCA2,4).
partSize(mCA3,5).
partTR(mCA1,tr1).
partTR(mCA1,tr2).
partTR(mCA2,tr1).
partTR(mCA2,tr2).
partTR(mCA3,tr1).
partTR(mCA2,tr2).
partVal(mCA1,1000).
partVal(mCA2,600).
partVal(mCA3,600).
partVal(fullFuselage,2200).


% fixed where is what produced
producedAt(mCA1,l1,1).
producedAt(mCA2,l1,2).
producedAt(mCA1,l4,2).
producedAt(mCA2,l4,1).
producedAt(mCA3,l4,2).
producedAt(mCA3,l3,1).
producedAt(fullFuselage,l2,1).
producedAt(fullFuselage,l5,2).
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

%production plan
productionPlan(fullFuselage,mCA1).
productionPlan(fullFuselage,mCA2).
productionPlan(fullFuselage,mCA3).