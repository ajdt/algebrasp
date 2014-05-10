% this is where I'll be testing new rules to add to the solver

%================================================================================
% addIdentity: a*x^b + 0 ----> a*x^b 
%================================================================================
% 						### RULE CONDITIONS ###
% TODO: refactor action data from actions!
% there's an add poly node with two children that are monomials, one of them has coef == 0 
% the only info we remember is the identity of the parent node and the node to remove
possible(action(data(N1, C1, C2), addIdent), S) 	:- 	holds(N1, node(N1), S), 
											holds(N1, type(poly), S),
											holds(N1, nodeOper(add), S),
											holds(N1, parentOf(C1), S),
											holds(N1, parentOf(C2), S),
											holds(C1, type(mono), S), 
											% TODO: can we ignore types and just assume that only monomials have coefs and only parent types hyave children?
											holds(C2, type(mono), S),
											holds(C1, nodeCoef(Coef1), S),
											holds(C2, nodeCoef(0), S),
											C1 != C2.
% 						### APPLYING THE RULE ###
% 						### CASE 1: parent node has more than 2 children ###
% decrement number of children
assigned(N1, numChildren(Kids - 1), S) 	:-	do_action(action(data(N1, C1, C2), addIdent), S),
											holds(N1, numChildren(Kids), S), Kids > 2.


% 						### CASE 2: parent node has exactly 2 children ###
%--------------------------------------------------------------------------------
% 								so parent node becomes monomial.
% remove old facts about parent
removed(N1, Fact, S) 				:-	do_action(action(data(N1, C1, C2), addIdent), S),
										holds(N1, numChildren(Kids), S), Kids == 2,
										holds(C2, Fact, S).
% parent ID is still a node, becomes a monomial, and gains node parameters
% TODO: create concept of replacing parent data with child data, make code less redundant!
assigned(N1, node(N1), S) 			:-	do_action(action(data(N1, C1, C2), addIdent), S),
										holds(N1, numChildren(Kids), S), Kids == 2.
assigned(N1, type(mono), S) 		:-	do_action(action(data(N1, C1, C2), addIdent), S),
										holds(N1, numChildren(Kids), S), Kids == 2.
assigned(N1, nodeCoef(Coef), S) 	:-	do_action(action(data(N1, C1, C2), addIdent), S),
										holds(N1, numChildren(Kids), S), Kids == 2,
										holds(C1, nodeCoef(Coef),  S).
assigned(N1, nodeDeg(Degree), S) 	:-	do_action(action(data(N1, C1, C2), addIdent), S),
										holds(N1, numChildren(Kids), S), Kids == 2,
										holds(C1, nodeDeg(Degree), S) .
% C1 child node is deleted 
removed(C1, Fact, S)				:-	do_action(action(data(N1, C1, C2), addIdent), S),
										holds(N1, numChildren(Kids), S), Kids == 2,
										holds(C1, Fact, S).

%						### BOTH CASES ###
%--------------------------------------------------------------------------------
% completely erase second node											
removed(C2, Fact, S)	:-	do_action(action(data(N1, C1, C2), addIdent), S),
							holds(C2, Fact, S).
%================================================================================
%================================================================================
