%================================================================================
% multMonom: a*x^b * c*x^d ----> (a*c)*x^(b+d)
%================================================================================
% 						### RULE CONDITIONS ###

% there's a mul poly node with two monomial children 
possible(action(data(MulNode, Mono1, Mono2), multMonom), S) 	:- 	holds(MulNode, field(nodeOper,mul), S),
																	holds(MulNode, field(parentOf,Mono1), S),
																	holds(MulNode, field(parentOf,Mono2), S),
																	holds(Mono1, field(type,mono), S),
																	holds(Mono2, field(type,mono), S),
																	MulNode < Mono1,
																	MulNode < Mono2,
																	Mono1 < Mono2,
																	node(MulNode),
																	node(Mono1),
																	node(Mono2),
																	Mono1 != Mono2.
% 						### APPLYING THE RULE ###
% create a temp node to represent the product of monomials.

% generate degree and coefficient fields 
_makeTempField(field(nodeDeg, SumDeg), S)		:-	_selected(action(data(MulNode, Mono1, Mono2), multMonom), S),
													holds(Mono1, field(nodeDeg, D1), S),
													holds(Mono2, field(nodeDeg, D2), S),
													degree(D1),
													degree(D2),
													node(MulNode),
													node(Mono1),
													node(Mono2),
													SumDeg = D1 + D2.

_makeTempField(field(nodeCoef, ProdCoef), S)	:-	_selected(action(data(MulNode, Mono1, Mono2), multMonom), S),
													holds(MulNode, field(parentOf, Mono1), S),
													holds(MulNode, field(parentOf, Mono2), S),
													holds(Mono1, field(nodeCoef, C1), S),
													holds(Mono2, field(nodeCoef, C2), S),
													% conditions to limit grounding
													holds(MulNode, field(numChildren, Kids), S),
													Mono1 > MulNode*max_terms,
													Mono2 > MulNode*max_terms,
													Mono1 <= MulNode*max_terms + Kids ,
													Mono2 <= MulNode*max_terms + Kids,
													Mono1 < Mono2,
													coeffValue(C1),
													coeffValue(C2),
													node(MulNode),
													node(Mono1),
													node(Mono2),
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
possible(action(data(SumNode, Prod1, Prod2), factor), S) 	:- 	holds(SumNode, field(nodeOper,add), S),
																holds(SumNode, field(parentOf,Prod1), S),
																holds(SumNode, field(parentOf,Prod2), S),
																holds(Prod1, field(nodeOper, mul), S),
																holds(Prod2, field(nodeOper, mul), S),
																holds(Prod1, field(parentOf, CommonTerm1), S),
																holds(Prod2, field(parentOf, CommonTerm2), S),
																equalMonom(CommonTerm1, CommonTerm2, S),
																node(Prod1),
																node(Prod2),
																node(SumNode),
																Prod1 < Prod2.

% 						### APPLYING THE RULE ###
update(SumNode, field(nodeOper, mul),S)	:-	_selected(action(data(SumNode, Prod1, Prod2), factor), S).
update(Prod1, field(nodeOper, add),S)	:-	_selected(action(data(SumNode, Prod1, Prod2), factor), S).

% replace the common term (B above) in Prod1 with the other term (C above) in Prod2
replaceCommonTerm(CommonTerm1, OtherTerm2, Prod2, S)	:-	_selected(action(data(SumNode, Prod1, Prod2), factor), S),
															holds(Prod1, field(parentOf, CommonTerm1), S),
															holds(Prod2, field(parentOf, CommonTerm2), S),
															equalMonom(CommonTerm1, CommonTerm2, S),
															holds(Prod2, field(parentOf, OtherTerm2), S),
															OtherTerm2 != CommonTerm2.

inheritFrom(CommonTerm, OtherTermP2, S)		:-	replaceCommonTerm(CommonTerm, OtherTermP2, Prod2, S).
shrinkSubtree(Prod2, OtherTermP2, S)		:-	replaceCommonTerm(CommonTerm, OtherTermP2, Prod2, S).
%================================================================================
%================================================================================


%================================================================================
% factorMonom: (a*c)*x^p ---> (a*x^q)*(c*x^r)
% where r + q = p
%================================================================================
% 						### RULE CONDITIONS ###

% select any monomial
possible(action(data(Mono), factorMonom), S) 	:- 	holds(Mono, field(type,mono), S),
													node(Mono),
													step(S).


% 						### APPLYING THE RULE ###

% convert monomial to mul operator with 2 children
convertToOperWithKids(Mono, mul, 2, S)	:-	_selected(action(data(Mono), factorMonom), S).

% partition Monomial's coef into a product of two other coeffs, 
% and degree as sum of two other degrees
1 { degSumPartition(Mono, D1, D2, S) 
			:	degree(D1),
				degree(D2),
				holds(Mono, field(nodeDeg, D1 + D2), S)
} 1		:-	_selected(action(data(Mono), factorMonom), S).
										
1 { coefProdPartition(Mono, C1, C2, S) 
			:	coeffValue(C1), 
				coeffValue(C2), 
				holds(Mono, field(nodeCoef, C1*C2), S) 
} 1		:-	_selected(action(data(Mono), factorMonom), S).

% create child monomials based on above partitions
% NOTE: converToOperWithKids creates the child nodes, but doesn't assign fields/values
assigned(Child1, field(nodeDeg, D1), S ; 
		 Child2, field(nodeDeg, D2), S)			:-	_selected(action(data(Mono), factorMonom), S),
													degSumPartition(Mono, D1, D2, S),
													newKidOnTheBlock(Mono, Child1, S),
													newKidOnTheBlock(Mono, Child2, S),
													Child1 < Child2.

assigned(Child1, field(nodeCoef,C1), S ; 
		Child2, field(nodeCoef,C2), S)			:-	_selected(action(data(Mono), factorMonom), S),
													coefProdPartition(Mono, C1, C2, S),
													newKidOnTheBlock(Mono, Child1, S),
													newKidOnTheBlock(Mono, Child2, S),
													Child1 < Child2.

assigned(Child, field(type, mono), S)			:-	_selected(action(data(Mono), factorMonom), S),
													newKidOnTheBlock(Mono, Child, S).

%================================================================================
%================================================================================

