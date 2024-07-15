location(l1).
location(l2).
location(l3).
location(l4).
location(l5).
location(l6).

% transportResource: name, capacity, co2emissions, cost, speed
transportResource(tr1,10,60,56,3).
transportResource(tr2,15,45,42,2).

% Part: name, validTR, size, value
part(p1,tr1,4,1000).
part(p1,tr2,4,1000).

% netSupplyDemand
netSupplyDemand(p1,l1,15).
netSupplyDemand(p1,l2,20).
netSupplyDemand(p1,l5,-15).
netSupplyDemand(p1,l6,-20).

% route, from l1 to l2, with tr1 and distance N
route(l1,l2,tr1,1).
route(l1,l2,tr2,2).
route(l1,l3,tr1,3).
route(l1,l3,tr2,4).
route(l1,l4,tr1,4).
route(l1,l4,tr2,8).
route(l2,l3,tr1,1).
route(l2,l3,tr2,2).
route(l2,l4,tr1,2).
route(l2,l4,tr2,6).
route(l2,l6,tr1,2).
route(l3,l5,tr1,1).
route(l3,l5,tr2,3).
route(l3,l6,tr1,1).
route(l3,l6,tr2,2).
route(l4,l5,tr1,2).
route(l4,l5,tr2,4).
route(l4,l6,tr1,3).
route(l4,l6,tr2,5).

% assertions
invalidLocation(X) :- netSupplyDemand(_,X,_), not location(X).
invalidTransport(X) :- part(_,X,_,_), not transportResource(X,_,_,_,_).
invalidRoute(X) :- route(X,_,_,_), not location(X).
invalidRoute(X) :- route(_,X,_,_), not location(X).
invalidRoute(X) :- route(_,_,X,_), not transportResource(X,_,_,_,_).
invalidRoute(X) :- route(_,_,_,X), X < 0.

%

num(100).
num(X-1):- num(X), X>0.

% constraints
{produced(P,L,N)} :- part(P,_,_,_),location(L),num(N).


% fulfill demand
:- netSupplyDemand(P,L,D), S=#sum{N,PL:produced(P,PL,N)}, S+D < 0.

% optimize
#minimize{M,L,P: produced(P,L,M)}.

#show produced/3.



