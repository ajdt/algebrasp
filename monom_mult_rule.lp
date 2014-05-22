%================================================================================
% multMonom: a*x^b * c*x^d ----> (a+c)*x^(b+d)
%================================================================================
% 						### RULE CONDITIONS ###

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
												holds(Mono1, field(nodeDeg, D1), S),
												holds(Mono2, field(nodeDeg, D2), S),
												degree(D1),
												degree(D2),
												SumDeg = D1 + D2.

_makeTempNode(field(nodeCoef, ProdCoef), S)	:-	_selected(action(data(Root, Mono1, Mono2), multMonom), S),
												holds(Mono1, field(nodeCoef, C1), S),
												holds(Mono2, field(nodeCoef, C2), S),
												coeffValue(C1),
												coeffValue(C2),
												ProdCoef = C1 * C2.
_makeTempNode(field(type, mono), S) :- _makeTempNode(field(nodeDeg, Deg), S).

holds(temp, field(Name, Value), S) :- _makeTempNode(field(Name, Value), S).

% shrinkSubtreeNewValue will remove the temp node and appropriately transform the Root subtree
contractNodes(Root, Mono1, Mono2, temp, S) :-	_selected(action(data(Root, Mono1, Mono2), multMonom), S). 

%================================================================================
%================================================================================
