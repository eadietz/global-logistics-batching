% knapsack unbound
num(1..100).

% transportResource: name, capacity, co2emissions, cost, speed
transportResource(tr1,10,60,56,3).
transportResource(tr2,15,45,42,2).

% Part: name, validTR, size, value
part(p1,tr1,4,1000).
part(p1,tr2,4,1000).
part(p2,tr2,3,600).
part(p2,tr1,3,600).

1{packing(Part,TR,N):num(N)}1 :- part(Part,TR,_,_), transportResource(TR,_,_,_,_).

:- Cap<#sum{S*N,Part: packing(Part,TR,N), part(Part,TR,S,_)},  transportResource(TR,Cap,_,_,_).
%#maximize{S*N,Part: packing(Part,TR,N), part(Part,TR,S,_)}.

#show packing/3.

