% two cases, there are more than two kids or there are exactly two kids
% each operator node is generated with at least two children, so no operator
% should ever have one child.




holds(subtreeTriple(Root, children(Left, Middle, Right)), S)	:-	holds(Root, field(parentOf, Left), S),
															holds(Root, field(parentOf, Middle), S),
															holds(Root, field(parentOf, Right), S),
															Left < Middle,
															Middle < Right,
															_validChildOf(Root, Left),
															_validChildOf(Root, Middle),
															_validChildOf(Root, Right),
															step(S).
%================================================================================
% compSquare: x^2 + b*x + c --> (x + b/2)*(x + b/2) + c - b^2/4
%================================================================================
possible(action(data(Plus, XSquare, XMonom, Const), compSquare), S)	:-	holds(subtreeTriple(Plus, children(XSquare, XMonom, Const)), S),
																		Plus == 1,
																		holds(Plus, field(nodeOper, add), S),
																		holds(XSquare, field(nodeDeg, 2), S),	% x^2
																		holds(XSquare, field(nodeCoef, 1), S),
																		holds(XMonom, field(nodeDeg, 1), S),	% B*x
																		holds(XMonom, field(nodeCoef, Coef), S),
																		coeffValue(Coef), Coef != 0, Coef != 1,
																		holds(Const, field(nodeDeg, 0), S),		% B^2/4
																		holds(Const, field(nodeCoef, Coef**2/4), S),
																		step(S).

% 						### APPLYING THE RULE ###
% delete the second fraction's numerator: now it's a single node containing
update(Plus, field(nodeOper, mul), S)	:-	_selected(action(data(Plus, XSquare, XMonom, Const), compSquare), S).
deleteChild(Plus, Const, S)				:-	_selected(action(data(Plus, XSquare, XMonom, Const), compSquare), S).
% todo: parentOf field isn't being updated properly when delete child is applied!
removed(Plus, field(parentOf, Const), S):-	_selected(action(data(Plus, XSquare, XMonom, Const), compSquare), S).
deleteChild(Plus, Const, S)				:-	_selected(action(data(Plus, XSquare, XMonom, Const), compSquare), S).

convertToOperWithKids(XSquare, add, 2, S ; XMonom, add, 2, S)	:-	_selected(action(data(Plus, XSquare, XMonom, Const), compSquare), S).

% each monomial
createMono(NewKid, 1, 1, S)					:-	_selected(action(data(Plus, XSquare, XMonom, Const), compSquare), S),
												newKidOnTheBlock(Parent, NewKid, S),
												NewKid == Parent*max_terms + 1.
createMono(NewKid, Coef/2, 0, S)			:-	_selected(action(data(Plus, XSquare, XMonom, Const), compSquare), S),
												holds(XMonom, field(nodeCoef, Coef), S),
												coeffValue(Coef),
												newKidOnTheBlock(Parent, NewKid, S),
												NewKid == Parent*max_terms + 2.

%================================================================================
%================================================================================
