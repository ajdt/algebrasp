%================================================================================
% multMonom: a*x^b * c*x^d ----> (a+c)*x^(b+d)
%================================================================================
% 						### RULE CONDITIONS ###
sumDeg(C1, C2, D1 + D2, S) :- holds(C1, field(nodeDeg, D1), S), holds(C2,field(nodeDeg, D2), S), degree(D1), degree(D2).
%prodCoef(C1, C2, Coef1 * Coef2, S) :- holds(C1, field(nodeCoef, Coef1), S), holds(C2,field(nodeCoef, Coef2), S), coeffValue(Coef1), coeffValue(Coef2).
% there's an add poly node with two children that are monomials of the same degree
possible(action(data(Root, Mono1, Mono2), multMonom), S) 	:- 	holds(Root, field(nodeOper,mul), S),
																holds(Root, field(parentOf,Mono1), S),
																holds(Root, field(parentOf,Mono2), S),
																holds(Mono1, field(type,mono), S),
																holds(Mono2, field(type,mono), S),
																Mono1 != Mono2.
% 						### APPLYING THE RULE ###
% make a dummy node that represents the new monomial: 
_makeTempNode(field(nodeDeg, SumDeg), S)	:-	_selected(action(data(Root, Mono1, Mono2), multMonom), S),
												sumDeg(Mono1, Mono2, SumDeg, S).

_makeTempNode(field(nodeCoef, ProdCoef), S)	:-	_selected(action(data(Root, Mono1, Mono2), multMonom), S),
												%prodCoef(Mono1, Mono2, ProdCoef, S).
												holds(Mono1, field(nodeCoef, C1), S),
												holds(Mono2, field(nodeCoef, C2), S),
												ProdCoef = C1 * C2.
_makeTempNode(field(type, mono), S) :- _makeTempNode(field(nodeDeg, Deg), S).

holds(temp, field(Name, Value), S) :- _makeTempNode(field(Name, Value), S).

% shrinkSubtreeNewValue will remove the temp node and appropriately transform the Root subtree
contractNodes(Root, Mono1, Mono2, temp, S) :-	_selected(action(data(Root, Mono1, Mono2), multMonom), S). 

%================================================================================
%================================================================================
