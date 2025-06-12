% location: name
location(l1).
location(l2).
location(l3).
location(l4).
location(l5).
location(l6).

transportResource(tr1).
transportResource(tr2).
transportResource(intrasite).

transportCapacity(tr1,10).
transportCapacity(tr2,15).
transportCapacity(intrasite,100).

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
partTR(p1,intrasite).
partTR(p2,intrasite).

partVal(p1,1000).
partVal(p2,600).

% netSupplyDemand: part name, location, offer/ produced/able
offer(p1,l1,1).
offer(p1,l2,2).
offer(p2,l1,4).

% netSupplyDemand: part name, location, demand/ consumed/able
demand(p1,l5,1).
demand(p1,l6,2).
demand(p2,l2,1).
demand(p2,l5,2).
demand(p2,l6,1).


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
#const n=5.
num(1..n).
packingPattern(0,t,t,t).

{packingPattern(Idx,Part,TR,N):num(N),packingPattern(Idx-1,_,_,_),partTR(Part,TR),num(Idx)}.
:- packingPattern(Idx,_,TR1,_), packingPattern(Idx,_,TR2,_), TR1!=TR2.
:- packingPattern(Idx,Part,_,N1), packingPattern(Idx,Part,_,N2), N1!=N2.

:- #sum{N*Size,Part:packingPattern(Idx,Part,TR,N),partSize(Part,Size)}>CAP, packingPattern(Idx,_,_,_),transportCapacity(TR,CAP).

direct(From,To,TR) :- route(From,To,TR,_,_), From!=To.
via1(From,(Via1,To),(TR1,TR2)) :- route(From,Via1,TR1,_,_), route(Via1,To,TR2,_,_), 
location(From), location(Via1), location(To), From!=To, Via1!=To.

1{path((Idx,Idx),(From,From,From),(0,1)): location(From), num(N), packingPattern(Idx,Part,intrasite,N), To=From,offer(Part,From,_);
path((Idx,Idx),(From,From,To),(1,N)): direct(From,To,TR), packingPattern(Idx,Part,TR,M), num(N),M*N<=A, offer(Part,From,O);
path((Idx1,Idx2),(From,Via,To),(N1,N2)): via1(From,(Via,To),(TR1,TR2)), 
packingPattern(Idx1,Part,TR1,M1), num(N1), offer(Part,From,O),
packingPattern(Idx2,Part,TR2,M2), num(N2) 
}1 :- demand(Part,To,A).

:- D!=#sum{M2*N2,(Idx1,Idx2),(N1,N2), From, Via: path((Idx1,Idx2),(From,Via,To),(N1,N2)),packingPattern(Idx2,Part,_,M2)}, 
demand(Part,To,D).
:- O!=#sum{M1*N1,(Idx1,Idx2),(N1,N2), Via, To: path((Idx1,Idx2),(From,Via,To),(N1,N2)),packingPattern(Idx1,Part,_,M1)}, 
offer(Part,From,O).


#show demand/3.
#show path/3.
#show packingPattern/4.

#minimize{F1+F2,Idx1,Idx2,From,Via,To:path((Idx1,Idx2),(From,Via,To),(F1,F2))}.





%:- O!=A, partAtLocation(Part,To,A), demand(Part,To,D).


%:- Demand!=#sum{F1*N1+F2*N2,From,Via:path((Idx1,Idx2),(From,Via,To),(F1,F2)),
%packingPattern(Idx1,Part,_,N1),packingPattern(Idx2,Part,_,N2)}, demand(Part,To,Demand).

%:- Offer!=#sum{F1*N1+F2*N2,To,Via:path((Idx1,Idx2),(From,Via,To),(F1,F2)),
%packingPattern(Idx1,Part,_,N1),packingPattern(Idx2,Part,_,N2)}, offer(Part,From,Offer).


%&diff{Freq1*N1-Freq2*N2} <=0 :- transport(Idx2,From,_,Freq2),packingPattern(Idx2,Part,_,N2),
%                    transport(Idx1,_,From,Freq1), packingPattern(Idx1,Part,_,N1),
%                    T1=Freq1*N1,T2=Freq2*N2.
%&diff{Freq*N-O} <=0 :- transport(Idx,From,_,Freq),packingPattern(Idx,Part,_,N),offer(Part,From,O),T=Freq*N.

%:- transport(Idx,From,_,Freq1), packingPattern(Idx,Part,_,N1), 
%Freq1*N1>TT+O, 
%offer(Part,From,O), 
%TT=#sum{Freq2*N2: transport(Idx,_,From,Freq2), packingPattern(Idx,Part,_,N2)}.

%:- D!=A1+A2, A1=#sum{N*Freq,Idx:packingPattern(Idx,Part,_,N),transport(Idx,_,To,Freq)},
%A2=#sum{N1*Freq1+N2*Freq2,(Idx1,Idx2):packingPattern(Idx1,Part,_,N1),
%packingPattern(Idx2,Part,_,N2),transport((Idx1,Idx2),_,(_,To),(Freq1,Freq2))}, 
%demand(Part,To,D).
%:- O!=#sum{N*Freq,Idx:packingPattern(Idx,Part,_,N),transport(Idx,From,_,Freq)}, offer(Part,From,O).


%&diff{O-D} = 0 :- demand(Part,_,D),offer(Part,_,O).



%1{transport(Idx,From,To,Freq): direct(From,To,TR), packingPattern(Idx,Part,TR,M), num(M), num(Freq), 
%route(From,To,TR,_,_);
%transport((Idx1,Idx2),From,(Via, To),(Freq1,Freq2)): via1(From,(Via,To),(TR1,TR2)),
%packingPattern(Idx1,Part,TR1,M1), num(Freq1),num(M1),num(M2),
%packingPattern(Idx2,Part,TR2,M2), num(Freq2)
%;
%transport((Idx1,Idx2,Idx3),From,((Via1,Via2), To),(Freq1,Freq2,Freq3): 
%via2(From,((Via1,Via2),To),(TR1,TR2,TR3)),
%packingPattern(Idx1,Part,TR1,M1), num(Freq1),num(M1),num(M2),num(M3),
%packingPattern(Idx2,Part,TR2,M2), num(Freq2),
%packingPattern(Idx3,Part,TR3,M3), num(Freq3)
%} :- offer(Part,From,_),  demand(Part,To,_).

%the next ones seem wrong
%&sum{M; -D}=0 :- demand(Part,To,D),M=#sum{T: arrivedAt(Part,To,T)}.
%&sum{M; -O}=0 :- offer(Part,From,O),M=#sum{T: leftFrom(Part,From,T)}.
