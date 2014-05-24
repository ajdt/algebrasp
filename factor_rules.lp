%================================================================================
% multMonom: a*x^b * c*x^d ----> (a+c)*x^(b+d)
%================================================================================
% 						### RULE CONDITIONS ###

% there's a mul poly node with two monomial children 
possible(action(data(MulNode, Mono1, Mono2), multMonom), S) 	:- 	holds(MulNode, field(nodeOper,mul), S),
																	holds(MulNode, field(parentOf,Mono1), S),
																	holds(MulNode, field(parentOf,Mono2), S),
																	holds(Mono1, field(type,mono), S),
																	holds(Mono2, field(type,mono), S),
																	Mono1 != Mono2.
% 						### APPLYING THE RULE ###
% create a temp node to represent the product of monomials.

% generate degree and coefficient fields 
_makeTempField(field(nodeDeg, SumDeg), S)		:-	_selected(action(data(MulNode, Mono1, Mono2), multMonom), S),
													holds(Mono1, field(nodeDeg, D1), S),
													holds(Mono2, field(nodeDeg, D2), S),
													degree(D1),
													degree(D2),
													SumDeg = D1 + D2.

_makeTempField(field(nodeCoef, ProdCoef), S)	:-	_selected(action(data(MulNode, Mono1, Mono2), multMonom), S),
													holds(Mono1, field(nodeCoef, C1), S),
													holds(Mono2, field(nodeCoef, C2), S),
													coeffValue(C1),
													coeffValue(C2),
													ProdCoef = C1 * C2.

% generate type for temp
_makeTempField(field(type, mono), S)			:-	_makeTempField(field(nodeDeg, Deg), S).
holds(temp, field(Name, Value), S)				:-	_makeTempField(field(Name, Value), S).

% contractNodes will remove the temp node and appropriately transform the MulNode subtree
contractNodes(MulNode, Mono1, Mono2, temp, S)	:-	_selected(action(data(MulNode, Mono1, Mono2), multMonom), S). 

%================================================================================
%================================================================================

% first approximation, works for monomials only
%================================================================================
% factor: A*B + C*B --> (A+C)*B
%================================================================================
% 						### RULE CONDITIONS ###
possible(action(data(Root, Prod1, Prod2), factor), S) 	:- 	holds(Root, field(nodeOper,add), S),
																holds(Root, field(parentOf,Prod1), S),
																holds(Root, field(parentOf,Prod2), S),
																holds(Prod1, field(nodeOper, mul), S),
																holds(Prod2, field(nodeOper, mul), S),
																holds(Prod1, field(parentOf, B1), S),
																holds(Prod2, field(parentOf, B2), S),
																equalMonom(B1, B2, S),
																Prod1 < Prod2.

% 						### APPLYING THE RULE ###
update(Root, field(nodeOper, mul),S)	:-	_selected(action(data(Root, Prod1, Prod2), factor), S).
update(Prod1, field(nodeOper, add),S)	:-	_selected(action(data(Root, Prod1, Prod2), factor), S).

% replace the common term (B above) in Prod1 with the other term (C above) in Prod2
replaceCommonTerm(B1, C, Prod2, S)	:-	_selected(action(data(Root, Prod1, Prod2), factor), S),
											holds(Prod1, field(parentOf, B1), S),
											holds(Prod2, field(parentOf, B2), S),
											equalMonom(B1, B2, S),
											holds(Prod2, field(parentOf, C), S),
											C != B2.

inheritFrom(CommonTerm, OtherTermP2, S)		:-	replaceCommonTerm(CommonTerm, OtherTermP2, Prod2, S).
shrinkSubtree(Prod2, OtherTermP2, S)		:-	replaceCommonTerm(CommonTerm, OtherTermP2, Prod2, S).


%================================================================================
%================================================================================


