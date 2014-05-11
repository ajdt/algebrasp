% two cases, there are more than two kids or there are exactly two kids
% each operator node is generated with at least two children, so no operator
% should ever have one child.




% this is where I'll be testing new rules to add to the solver

%================================================================================
% fracCancel: A*C/(B*C) --> A/B
%================================================================================
% 						### RULE CONDITIONS ###
% There's a div node with two mult nodes as children. The mult nodes have children that are equal
possible(action(data(Numer, Top, Denom, Bottom), fracCancel), S) 	:- 	holds(N1, field(nodeOper,div), S),
											holds(N1, field(parentOf,Denom), S),
											holds(N1, field(parentOf,Numer), S),
											Denom != Numer,
											holds(Denom, field(nodeOper,mul), S),
											holds(Numer, field(nodeOper,mul), S),
											holds(Numer, field(parentOf,Top), S),
											holds(Denom, field(parentOf,Bottom), S),
											holds(Top, field(nodeCoef,Coef), S),			% top and bottom are equal
											holds(Top, field(nodeDeg,Deg), S),
											holds(Bottom, field(nodeCoef,Coef), S),
											holds(Bottom, field(nodeDeg,Deg), S).

% 						### APPLYING THE RULE ###
% decrement number of children
shrinkSubtree(Numer, Top, S) 		:-	_selected(action(data(Numer, Top, Denom, Bottom), fracCancel), S).
shrinkSubtree(Denom, Bottom, S) 	:-	_selected(action(data(Numer, Top, Denom, Bottom), fracCancel), S).
%================================================================================
%================================================================================
