% transportResource: name, capacity, co2emissions, cost, speed
transportResource(tr1,10,60,56,3).
transportResource(tr2,15,45,42,2).

% Part: name, validTR, size, value
part(p1,tr1,4,1000).
part(p1,tr2,4,1000).
part(p2,tr2,3,600).
part(p2,tr1,3,600).

% knapsack unbound


1{packing(Part,TR,N):num(N)}1 :- part(Part,TR,_,_), transportResource(TR,_,_,_,_).

num(0..10).

{packingPattern(Idx,Part,TR,N):num(Idx)}:- packing(Part,TR,N).


:- packingPattern(Idx,Part,TR,N1), packingPattern(Idx,Part,TR,N2), N1!=N2.
:- packingPattern(Idx,Part1,TR1,N1), packingPattern(Idx,Part2,TR2,N2), TR1!=TR2.
:- packingPattern(Idx1,Part,TR,N), packingPattern(Idx2,Part,TR,N), Idx1!=Idx2.

#minimize{Idx:packingPattern(Idx,_,_,_)}.

#show packingPattern/4.

:- Cap<#sum{S*N,Part: packingPattern(_,Part,TR,N), part(Part,TR,S,_)},  transportResource(TR,Cap,_,_,_).
#maximize{S*N,Part: packingPattern(_,Part,TR,N), part(Part,TR,S,_)}.
% variable for each edge and part, presenting amount of parts transported on edge

{transport(Idx,Part,F,N,From,To,TR,C):packingPattern(Idx,Parts,TR,N), num(F)}1:- route(From,To,TR,_,C).


#show transport/8.