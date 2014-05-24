% first approximation, works for monomials only!!
%================================================================================
% distribute: (A+C)*B --> A*B + C*B 
%================================================================================
% 						### RULE CONDITIONS ###
%possible(action(data(Root, Sum, Mono), distribute), S) 	:- 	holds(Root, field(nodeOper,mul), S),
%																holds(Root, field(parentOf,Sum), S),
%																holds(Root, field(parentOf,Mono), S),
%																holds(Sum, field(nodeOper, add), S),
%																holds(Mono, field(type, mono), S),
%																holds(Sum, field(parentOf, A), S),
%																holds(Sum, field(parentOf, C), S),
%																holds(A, field(type, mono), S),
%																Sum < Mono, % TODO: write this as generalized lhs and rhs
%																holds(C, field(type, mono), S).
%
%% 						### APPLYING THE RULE ###
%update(Root, field(nodeOper, add),S)	:-	_selected(action(data(Root, Sum, Mono), distribute), S).
%update(Sum, field(nodeOper, mul),S)		:-	_selected(action(data(Root, Sum, Mono), distribute), S).
%
%% replace child C in Sum  with Mono
%createRHS(Child2, Mono,S)				:-	_selected(action(data(Root, Sum, Mono), distribute), S),
%											holds(Sum, field(parentOf, Child1), S),
%											holds(Sum, field(parentOf, Child2), S),
%											Child1 < Child2.
%inheritFrom(Child2, Mono, S) 			:- createRHS(Child2, Mono, S).
%convertToOperWithKids(Mono, add, 2, S) 	:- createRHS(Child2, Mono, S).
%
%inheritFrom(Child1, LHSTerm, S)	:-	createRHS(LHSTerm, Mono, S),
%									newKidOnTheBlock(Mono, Child1, S),
%									newKidOnTheBlock(Mono, Child2, S),
%									Child1 < Child2.
%
%inheritFrom(Child2, Mono, S)	:-	createRHS(LHSTerm, Mono, S),
%									newKidOnTheBlock(Mono, Child1, S),
%									newKidOnTheBlock(Mono, Child2, S),
%									Child1 < Child2.
%											% child is left-most
											

%================================================================================
%================================================================================


%================================================================================
% factorMonom: (a*c)*x^p ---> (a*x^q)*(c*x^r)
% where r + q = p
%================================================================================
% 						### RULE CONDITIONS ###
possible(action(data(Mono), factorMonom), S) 	:- 	holds(Mono, field(type,mono), S),
																node(Mono),
																step(S).


% 						### APPLYING THE RULE ###
convertToOperWithKids(Mono, mul, 2, S)	:-	_selected(action(data(Mono), factorMonom), S).

1 { degAsSum(Mono, D1, D2, S) 
			:	degree(D1),
				degree(D2),
				holds(Mono, field(nodeDeg, D1 + D2), S)
} 1		:-	_selected(action(data(Mono), factorMonom), S).
										
1 { coefAsProd(Mono, C1, C2, S) 
			:	coeffValue(C1), 
				coeffValue(C2), 
				holds(Mono, field(nodeCoef, C1*C2), S) 
} 1		:-	_selected(action(data(Mono), factorMonom), S).


_createMonoDeg(Child1, D1, S; Child2, D2, S)	:-		_selected(action(data(Mono), factorMonom), S),
													degAsSum(Mono, D1, D2, S),
													newKidOnTheBlock(Mono, Child1, S),
													newKidOnTheBlock(Mono, Child2, S),
													Child1 < Child2.

_createMonoCoef(Child1, C1, S; Child2, C2, S)	:-	_selected(action(data(Mono), factorMonom), S),
													coefAsProd(Mono, C1, C2, S),
													newKidOnTheBlock(Mono, Child1, S),
													newKidOnTheBlock(Mono, Child2, S),
													Child1 < Child2.

assigned(Node, field(type, mono), S)	:-	_createMonoDeg(Node, Deg, S).
assigned(Node, field(nodeDeg, Deg), Step)		:- _createMonoDeg(Node, Deg, Step).
assigned(Node, field(nodeCoef, Coef), Step)	:- _createMonoCoef(Node, Coef, Step).

% for testing only. Remove later
_coefAsProd(X,Y,Z,W) :- coefAsProd(X,Y,Z,W).

%================================================================================
%================================================================================
