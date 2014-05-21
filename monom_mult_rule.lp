%================================================================================
% multMonom: a*x^b * c*x^d ----> (a+c)*x^(b+d)
%================================================================================
% 						### RULE CONDITIONS ###
sumDeg(C1, C2, D1 + D2, S) :- holds(C1, field(nodeDeg, D1), S), holds(C2,field(nodeDeg, D2), S), degree(D1), degree(D2).
prodCoef(C1, C2, Coef1 * Coef2, S) :- holds(C1, field(nodeCoef, Coef1), S), holds(C2,field(nodeCoef, Coef2), S), coefValue(Coef1), coefValue(Coef2).
% there's an add poly node with two children that are monomials of the same degree
possible(action(data(Root, Mono1, Mono2), multMonom), S) 	:- 	holds(Root, field(nodeOper,mul), S),
																holds(Root, field(parentOf,Mono1), S),
																holds(Root, field(parentOf,Mono2), S),
																holds(Mono1, field(type,mono), S),
																holds(Mono2, field(type,mono), S),
																Mono1 != Mono2.
% 						### APPLYING THE RULE ###
% make a dummy node that represents the new monomial: 
_makeTempNode(ProdCoef,SumDeg, S)				:-	_selected(action(data(Root, Mono1, Mono2), multMonom), S),
											sumDeg(Mono1, Mono2, SumDeg, S),
											prodCoef(Mono1, Mono2, ProdCoef, S).

holds(temp, field(type, mono), S)		:-	_makeTempNode(Coef, Deg,S).
holds(temp, field(nodeCoef, Coef), S)	:-	_makeTempNode(Coef, Deg,S).
holds(temp, field(nodeDeg, Deg), S) 	:-	_makeTempNode(Coef, Deg,S).

% shrinkSubtreeNewValue will remove the temp node and appropriately transform the Root subtree
contractNodes(Root, Mono1, Mono2, temp, S) :-	_selected(action(data(Root, Mono1, Mono2), multMonom), S). 

%================================================================================
%================================================================================
