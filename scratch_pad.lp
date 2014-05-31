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

holds(stdQuadPoly(Plus, children(XSquare, XMonom, Const)), S) :- holds(subtreeTriple(Plus, children(XSquare, XMonom, Const)), S),
																		Plus == 1,
																		holds(Plus, field(nodeOper, add), S),
																		holds(XSquare, field(nodeDeg, 2), S),	
																		holds(XMonom, field(nodeDeg, 1), S),	
																		holds(Const, field(nodeDeg, 0), S),		
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

%================================================================================
% factorQuad: x^2 + b*x + c --> (x + d)*(x + e) 
% where d + e = b, d * e = c
%================================================================================
possible(action(data(Plus, CoefD, CoefE), factorQuad), S)	:-	holds(stdQuadPoly(Plus, children(XSquare, XMonom, Const)), S),
																holds(XSquare, field(nodeCoef, 1), S),
																holds(XMonom, field(nodeCoef, CoefB), S),
																holds(Const, field(nodeCoef, CoefC), S),
																% ensure coefficients have desired properties
																coeffValue(CoefB), CoefB != 0, CoefB != 1,
																coeffValue(CoefC), CoefC != 0,
																coeffValue(CoefD), coeffValue(CoefE),
																CoefB = CoefD + CoefE,
																CoefC = CoefD * CoefE,
																step(S).

% 						### APPLYING THE RULE ###
% root node will be a product of two binomials
update(Plus, field(nodeOper, mul), S)	:-	_selected(action(data(Plus, CoefD, CoefE), factorQuad), S).
% delete constant child
deleteChild(Plus, Const, S)				:-	_selected(action(data(Plus, CoefD, CoefE), factorQuad), S),
											holds(stdQuadPoly(Plus, children(XSquare, XMonom, Const)), S).

% TODO: debug deleteChild() so this line isn't needed!!!
removed(Plus, field(parentOf, Const), S)						:-	_selected(action(data(Plus, CoefD, CoefE), factorQuad), S),
																	holds(stdQuadPoly(Plus, children(XSquare, XMonom, Const)), S).
% convert XSquare and XMonom children to binomials
convertToOperWithKids(XSquare, add, 2, S ; XMonom, add, 2, S )	:-	_selected(action(data(Plus, CoefD, CoefE), factorQuad), S),
																	holds(stdQuadPoly(Plus, children(XSquare, XMonom, Const)), S).
createMono(Kid, 1, 1, S)										:-	newKidOnTheBlock(Parent, Kid, S),
																	Kid == Parent*max_terms + 1.
createMono(Kid, CoefD, 0, S)									:-	_selected(action(data(Plus, CoefD, CoefE), factorQuad), S),
																	holds(stdQuadPoly(Plus, children(XSquare, XMonom, Const)), S),
																	newKidOnTheBlock(XSquare, Kid, S),
																	Kid == XSquare*max_terms + 2.
createMono(Kid, CoefE, 0, S)									:-	_selected(action(data(Plus, CoefD, CoefE), factorQuad), S),
																	holds(stdQuadPoly(Plus, children(XSquare, XMonom, Const)), S),
																	newKidOnTheBlock(XMonom, Kid, S),
																	Kid == XMonom*max_terms + 2.
%================================================================================
%================================================================================
:- not action(factorQuad).
