rhsIsZero(S) :- holds(2, field(type, mono), S),
				holds(2, field(nodeCoef, 0), S).
holds(subtreePair(Root, children(Left, Right)), S)	:-	holds(Root, field(parentOf, Left), S),
														holds(Root, field(parentOf, Right), S),
														Left < Right,
														_validChildOf(Root, Left),
														_validChildOf(Root, Right),
														step(S).
holds(quadNoXTerm(Plus, children(XSquare, Const)), S) :- holds(subtreePair(Plus, children(XSquare, Const)), S),
																		Plus == 1,
																		holds(Plus, field(nodeOper, add), S),
																		holds(XSquare, field(nodeDeg, 2), S),	
																		holds(Const, field(nodeDeg, 0), S),		
																		step(S).

%================================================================================
% compSquare: x^2 + b*x + c --> (x + b/2)*(x + b/2) + c - b^2/4
%================================================================================
possible(action(data(Plus, XSquare, XMonom, Const), compSquare), S)	:-	holds(stdQuadPoly(Plus, children(XSquare, XMonom, Const)), S),
																		Plus == 1,
																		rhsIsZero(S),
																		holds(XSquare, field(nodeCoef, 1), S),
																		holds(XMonom, field(nodeCoef, Coef), S),
																		holds(Const, field(nodeCoef, Coef**2/4), S),
																		coeffValue(Coef), Coef != 0, Coef != 1,
																		step(S).

possible(action(data(Plus, XSquare, XMonom, Const, ResidualCoef), compSquare), S)	:-	holds(stdQuadPoly(Plus, children(XSquare, XMonom, Const)), S),
																		Plus == 1,
																		rhsIsZero(S),
																		holds(XSquare, field(nodeCoef, 1), S),
																		holds(XMonom, field(nodeCoef, CoefB), S),
																		holds(Const, field(nodeCoef, CoefC), S),
																		coeffValue(CoefB), CoefB != 0, CoefB != 1, CoefB \ 2 == 0,
																		coeffValue(CoefC), CoefC != 0,
																		ResidualCoef = CoefC - CoefB**2/4,
																		ResidualCoef != 0,
																		coeffValue(ResidualCoef),
																		step(S).

% 						### APPLYING THE RULE ###
% Plus node becomes product of binomials, const node is deleted
update(Plus, field(nodeOper, mul), S)	:-	_selected(action(data(Plus, XSquare, XMonom, Const), compSquare), S).
deleteChild(Plus, Const, S)				:-	_selected(action(data(Plus, XSquare, XMonom, Const), compSquare), S).

% convert XSquare and XMonom to binomials 
convertToOperWithKids(XSquare, add, 2, S ; XMonom, add, 2, S)	:-	_selected(action(data(Plus, XSquare, XMonom, Const), compSquare), S).

% create the x term and constant term to make (x + b/2) binomials
createMono(NewKid, 1, 1, S)					:-	_selected(action(data(Plus, XSquare, XMonom, Const), compSquare), S),
												newKidOnTheBlock(Parent, NewKid, S),
												NewKid == Parent*max_terms + 1.
createMono(NewKid, Coef/2, 0, S)			:-	_selected(action(data(Plus, XSquare, XMonom, Const), compSquare), S),
												holds(XMonom, field(nodeCoef, Coef), S),
												coeffValue(Coef),
												newKidOnTheBlock(Parent, NewKid, S),
												NewKid == Parent*max_terms + 2.

% --version 2
deleteChild(Plus, Const, S)				:-	_selected(action(data(Plus, XSquare, XMonom, Const, ResidualCoef), compSquare), S).
delete(XMonom, S)						:-	_selected(action(data(Plus, XSquare, XMonom, Const, ResidualCoef), compSquare), S).
createMono(XMonom, ResidualCoef, 0, S)	:-	_selected(action(data(Plus, XSquare, XMonom, Const, ResidualCoef), compSquare), S).
convertToOperWithKids(XSquare, mul, 2, S)	:-	_selected(action(data(Plus, XSquare, XMonom, Const, ResidualCoef), compSquare), S).

convertToOperWithKids(Kid, add, 2, S)	:-	_selected(action(data(Plus, XSquare, XMonom, Const, ResidualCoef), compSquare), S),
											newKidOnTheBlock(XSquare, Kid, S).

createMono(Kid, 1, 1, S)	:-	_selected(action(data(Plus, XSquare, XMonom, Const, ResidualCoef), compSquare), S),
											newKidOnTheBlock(Binomial, Kid, S),
											Binomial != XSquare,
											Kid == Binomial*max_terms + 1.

createMono(Kid, Coef/2, 0, S)	:-	_selected(action(data(Plus, XSquare, XMonom, Const, ResidualCoef), compSquare), S),
											holds(XMonom, field(nodeCoef, Coef), S),
											newKidOnTheBlock(Binomial, Kid, S),
											Binomial != XSquare,
											Kid == Binomial*max_terms + 2.




%================================================================================
%================================================================================


%================================================================================
% factorQuad: x^2 + b*x + c --> (x + d)*(x + e) 
% where d + e = b, d * e = c
%================================================================================
possible(action(data(Plus, CoefD, CoefE), factorQuad), S)	:-	holds(stdQuadPoly(Plus, children(XSquare, XMonom, Const)), S),
																rhsIsZero(S),
																holds(XSquare, field(nodeCoef, 1), S),
																holds(XMonom, field(nodeCoef, CoefB), S),
																holds(Const, field(nodeCoef, CoefC), S),
																% ensure coefficients have desired properties
																coeffValue(CoefB), CoefB != 0, CoefB != 1,
																coeffValue(CoefC), CoefC != 0,
																coeffValue(CoefD), coeffValue(CoefE),
																CoefB == CoefD + CoefE,
																CoefC == CoefD * CoefE,
																step(S).

% 						### APPLYING THE RULE ###
% root node will be a product of two binomials
update(Plus, field(nodeOper, mul), S)	:-	_selected(action(data(Plus, CoefD, CoefE), factorQuad), S).
% delete constant child
deleteChild(Plus, Const, S)				:-	_selected(action(data(Plus, CoefD, CoefE), factorQuad), S),
											holds(stdQuadPoly(Plus, children(XSquare, XMonom, Const)), S).

% convert XSquare and XMonom children to binomials
convertToOperWithKids(XSquare, add, 2, S ; XMonom, add, 2, S )	:-	_selected(action(data(Plus, CoefD, CoefE), factorQuad), S),
																	holds(stdQuadPoly(Plus, children(XSquare, XMonom, Const)), S).
createMono(Kid, 1, 1, S)										:-	_selected(action(data(Plus, CoefD, CoefE), factorQuad), S),
																	newKidOnTheBlock(Parent, Kid, S),
																	Kid == Parent*max_terms + 1. % first child of parent
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
%================================================================================
% factorQuad: x^2 - c^2 --> (x + c)*(x + c) 
%================================================================================
possible(action(data(quadNoXTerm(Plus, children(XSquare, Const))), factorQuad), S)	:-	holds(quadNoXTerm(Plus, children(XSquare, Const)), S),
																						holds(Plus, field(numChildren, 2), S),
																						rhsIsZero(S),
																						holds(XSquare, field(nodeCoef, 1), S),
																						holds(Const, field(nodeCoef, -CoefC*CoefC), S),
																						coeffValue(CoefC), CoefC != 0,
																						step(S).

% 						### APPLYING THE RULE ###
% root node will be a product of two binomials
update(Plus, field(nodeOper, mul), S)	:-	_selected(action(data(quadNoXTerm(Plus, children(XSquare, Const))), factorQuad), S).
1 { factorDecomp(C1, -1*C1, S) : coeffValue(C1), Coef == C1 * -1 * C1 } 1	:-	_selected(action(data(quadNoXTerm(Plus, children(XSquare, Const))), factorQuad), S),
																						holds(Const, field(nodeCoef, Coef), S), coeffValue(Coef).

% convert XSquare and XMonom children to binomials
convertToOperWithKids(XSquare, add, 2, S ; Const, add, 2, S )	:-	_selected(action(data(quadNoXTerm(Plus, children(XSquare, Const))), factorQuad), S).
createMono(Kid, 1, 1, S)										:-	_selected(action(data(quadNoXTerm(Plus, children(XSquare, Const))), factorQuad), S),
																	newKidOnTheBlock(Parent, Kid, S),
																	Kid == Parent*max_terms + 1. % first child of parent
createMono(Kid, C1, 0, S)									:-	_selected(action(data(quadNoXTerm(Plus, children(XSquare, Const))), factorQuad), S),
																	newKidOnTheBlock(XSquare, Kid, S),
																	factorDecomp(C1, C2, S),
																	Kid == XSquare*max_terms + 2.
createMono(Kid, C2, 0, S)									:-	_selected(action(data(quadNoXTerm(Plus, children(XSquare, Const))), factorQuad), S),
																	newKidOnTheBlock(XMonom, Kid, S),
																	factorDecomp(C1, C2, S),
																	Kid == Const*max_terms + 2.
%================================================================================
%================================================================================
%:- not action(factorQuad).
