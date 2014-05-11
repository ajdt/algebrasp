% two cases, there are more than two kids or there are exactly two kids
% each operator node is generated with at least two children, so no operator
% should ever have one child.

% TODO: try to make this code more concise Too!!!
delete(ToRemove, S) :- shrinkSubtree(Parent, ToRemove, S).
							
% if have more than two kids, then just decrement num kids
removed(Parent, numChildren(Kids), S)		:-	shrinkSubtree(Parent, ToRemove, S),
												holds(Parent, numChildren(Kids), S),
												Kids > 2.

assigned(Parent, numChildren(Kids - 1), S)	:-	shrinkSubtree(Parent, ToRemove, S),
												holds(Parent, numChildren(Kids), S),
												Kids > 2.

% if exactly two kids, then inherit from last remaining child...
inheritFrom(Parent, SecondKid, S)			:-	shrinkSubtree(Parent, ToRemove, S),
												holds(Parent, numChildren(2), S),
												holds(Parent, parentOf(SecondKid), S),
												SecondKid != ToRemove.
% ...and delete the last remaining child
delete(SecondKid, S)			:-	shrinkSubtree(Parent, ToRemove, S),
									holds(Parent, numChildren(2), S),
									holds(Parent, parentOf(SecondKid), S),
									SecondKid != ToRemove.
% abstracted notion of deleting a node
removed(ToDelete, Fact, S)		:-	delete(ToDelete, S),
									holds(ToDelete, Fact, S) .

% this is where I'll be testing new rules to add to the solver

%================================================================================
% fracCancel: A*C/(B*C) --> A/B
%================================================================================
% 						### RULE CONDITIONS ###
% There's a div node with two mult nodes as children. The mult nodes have children that are equal
possible(action(data(Numer, Top, Denom, Bottom), fracCancel), S) 	:- 	holds(N1, nodeOper(div), S),
											holds(N1, parentOf(Denom), S),
											holds(N1, parentOf(Numer), S),
											Denom != Numer,
											holds(Denom, nodeOper(mul), S),
											holds(Numer, nodeOper(mul), S),
											holds(Numer, parentOf(Top), S),
											holds(Denom, parentOf(Bottom), S),
											holds(Top, nodeCoef(Coef), S),			% top and bottom are equal
											holds(Top, nodeDeg(Deg), S),
											holds(Bottom, nodeCoef(Coef), S),
											holds(Bottom, nodeDeg(Deg), S).

% 						### APPLYING THE RULE ###
% decrement number of children
shrinkSubtree(Numer, Top, S) 		:-	_selected(action(data(Numer, Top, Denom, Bottom), fracCancel), S).
shrinkSubtree(Denom, Bottom, S) 	:-	_selected(action(data(Numer, Top, Denom, Bottom), fracCancel), S).
%================================================================================
%================================================================================
