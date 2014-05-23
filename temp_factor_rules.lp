% first approximation, works for monomials only!!
%================================================================================
% distribute: (A+C)*B --> A*B + C*B 
%================================================================================
% 						### RULE CONDITIONS ###
possible(action(data(Root, Sum, Mono), distribute), S) 	:- 	holds(Root, field(nodeOper,mul), S),
																holds(Root, field(parentOf,Sum), S),
																holds(Root, field(parentOf,Mono), S),
																holds(Sum, field(nodeOper, add), S),
																holds(Mono, field(type, mono), S),
																holds(Sum, field(parentOf, A), S),
																holds(Sum, field(parentOf, C), S),
																holds(A, field(type, mono), S),
																Sum < Mono, % TODO: write this as generalized lhs and rhs
																holds(C, field(type, mono), S).

% 						### APPLYING THE RULE ###
update(Root, field(nodeOper, add),S)	:-	_selected(action(data(Root, Sum, Mono), distribute), S).
update(Sum, field(nodeOper, mul),S)		:-	_selected(action(data(Root, Sum, Mono), distribute), S).

% replace child C in Sum  with Mono
createRHS(Child2, Mono,S)				:-	_selected(action(data(Root, Sum, Mono), distribute), S),
											holds(Sum, field(parentOf, Child1), S),
											holds(Sum, field(parentOf, Child2), S),
											Child1 < Child2.
inheritFrom(Child2, Mono, S) 			:- createRHS(Child2, Mono, S).
convertToOperWithKids(Mono, add, 2, S) 	:- createRHS(Child2, Mono, S).

inheritFrom(Child1, LHSTerm, S)	:-	createRHS(LHSTerm, Mono, S),
									newKidOnTheBlock(Mono, Child1, S),
									newKidOnTheBlock(Mono, Child2, S),
									Child1 < Child2.

inheritFrom(Child2, Mono, S)	:-	createRHS(LHSTerm, Mono, S),
									newKidOnTheBlock(Mono, Child1, S),
									newKidOnTheBlock(Mono, Child2, S),
									Child1 < Child2.
											% child is left-most
											

%================================================================================
%================================================================================


%================================================================================
% distribute: (A+C)*B --> A*B + C*B 
%================================================================================
% 						### RULE CONDITIONS ###
possible(action(data(Root, Sum, Mono), distribute), S) 	:- 	holds(Root, field(nodeOper,mul), S),
																holds(Root, field(parentOf,Sum), S),
																holds(Root, field(parentOf,Mono), S),
																holds(Sum, field(nodeOper, add), S),
																holds(Mono, field(type, mono), S),
																holds(Sum, field(parentOf, A), S),
																holds(Sum, field(parentOf, C), S),
																holds(A, field(type, mono), S),
																Sum < Mono, % TODO: write this as generalized lhs and rhs
																holds(C, field(type, mono), S).

% 						### APPLYING THE RULE ###
update(Root, field(nodeOper, add),S)	:-	_selected(action(data(Root, Sum, Mono), distribute), S).
update(Sum, field(nodeOper, mul),S)		:-	_selected(action(data(Root, Sum, Mono), distribute), S).

% replace child C in Sum  with Mono
createRHS(Child2, Mono,S)				:-	_selected(action(data(Root, Sum, Mono), distribute), S),
											holds(Sum, field(parentOf, Child1), S),
											holds(Sum, field(parentOf, Child2), S),
											Child1 < Child2.
inheritFrom(Child2, Mono, S) 			:- createRHS(Child2, Mono, S).
convertToOperWithKids(Mono, add, 2, S) 	:- createRHS(Child2, Mono, S).

inheritFrom(Child1, LHSTerm, S)	:-	createRHS(LHSTerm, Mono, S),
									newKidOnTheBlock(Mono, Child1, S),
									newKidOnTheBlock(Mono, Child2, S),
									Child1 < Child2.

inheritFrom(Child2, Mono, S)	:-	createRHS(LHSTerm, Mono, S),
									newKidOnTheBlock(Mono, Child1, S),
									newKidOnTheBlock(Mono, Child2, S),
									Child1 < Child2.
											% child is left-most
											

%================================================================================
%================================================================================
