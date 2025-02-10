

% packing needs to be defined differently ... .
{packing(P,TR,N): N*W<C+1, num(N),part(P,_,W,_);
packing((P1,P2),TR,N): N*(W1+W2)<C+1,
num(N),part(P1,_,W1,_),part(P2,_,W2,_), P1!=P2} :- transportResource(TR,C,_,_,_).

:- packing(P,TR,N), packing(P,TR,M), N!=M.
#show packing/3.


#const total = 1505.
#const max_order = 10.

food(fruit;fries;salad;wings;mozz_sticks;sampler).

cost(fruit,215).
cost(fries,275).
cost(salad,335).
cost(wings,355).
cost(mozz_sticks,420).
cost(sampler,580).

% Have to set an upper bound on the orders for a specific food
num(0..max_order).
% Order some amount (possibly 0) of each type of food
1 { order(Food, Number) : num(Number) } 1 :- food(Food). % We want the prices to sum to the desired total
#sum{(Cost*N),F : order(F,N) : cost(F,Cost), num(N)} == total.