%================================================================================
% multMonom: a*x^b * c*x^d ----> (a+c)*x^(b+d)
%================================================================================
% 						### RULE CONDITIONS ###
% there's an add poly node with two children that are monomials of the same degree
possible(action(data(Root, Mono1, Mono2, A*C, B+D), multMonom), S) 	:- 	holds(Root, field(nodeOper,mul), S),
																holds(Root, field(parentOf,Mono1), S),
																holds(Root, field(parentOf,Mono2), S),
																holds(Mono1, field(type,mono), S),
																holds(Mono2, field(type,mono), S),
																holds(Mono1, field(nodeCoef,A), S),
																holds(Mono1, field(nodeDeg,B), S),
																holds(Mono2, field(nodeCoef,C), S),
																holds(Mono1, field(nodeDeg,D), S),
																Mono1 != Mono2.
% 						### APPLYING THE RULE ###
% make a dummy node that represents the new monomial: 
makeTempNode(Coef, Deg,S)				:-	_selected(action(data(Root, Mono1, Mono2, Coef, Deg), multMonom), S).
holds(temp, field(type, mono), S)		:-	makeTempNode(Coef, Deg,S).
holds(temp, field(nodeCoef, Coef), S)	:-	makeTempNode(Coef, Deg,S).
holds(temp, field(nodeDeg, Deg), S) 	:-	makeTempNode(Coef, Deg,S).

% shrinkSubtreeNewValue will remove the temp node and appropriately transform the Root subtree
contractNodes(Root, Mono1, Mono2, temp, S) :-	_selected(action(data(Root, Mono1, Mono2, Coef, Deg), multMonom), S). 

%================================================================================
%================================================================================
