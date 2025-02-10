% assertions
invalidLocation(X) :- netSupplyDemand(_,X,_), not location(X).
invalidTransport(X) :- part(_,X,_,_), not transportResource(X,_,_,_,_).
invalidRoute(X) :- route(X,_,_,_), not location(X).
invalidRoute(X) :- route(_,X,_,_), not location(X).
invalidRoute(X) :- route(_,_,X,_), not transportResource(X,_,_,_,_).
invalidRoute(X) :- route(_,_,_,X), X < 0.


#show invalidLocation/1.
#show invalidTransport/1.
#show invalidRoute/1.