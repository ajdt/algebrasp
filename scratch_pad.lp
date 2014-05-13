% two cases, there are more than two kids or there are exactly two kids
% each operator node is generated with at least two children, so no operator
% should ever have one child.




% this is where I'll be testing new rules to add to the solver

%================================================================================
% AddfracDiffDenom: A/B + C/D--> (AD+BC)/BD
%================================================================================
% 						### RULE CONDITIONS ###
% NOTE: requires that both denominators be monomials: change this later to be more general!
% There's an add node with two div nodes as children
possible(action(data(Plus, Frac1, Frac2, frac1(Num1, Denom1), frac2(Num2, Denom2)), addFracDiffDenom), S) 	:- 	holds(Plus, field(nodeOper,add), S),
											holds(Plus, field(parentOf, Frac1), S),
											holds(Plus, field(parentOf, Frac2), S),
											Frac1 < Frac2, % ensure the two fractions aren't the same subtree
											holds(Frac1, field(numer,Num1), S),
											holds(Frac1, field(denom,Denom1), S),
											holds(Frac2, field(numer,Num2), S),
											holds(Frac2, field(denom,Denom2), S).

% 						### APPLYING THE RULE ###
% delete the second fraction's numerator: now it's a single node containing

% make the Plus node into a div node
makeRootDiv(Plus, Frac1, Frac2, S) 		:-	_selected(action(data(Plus, Frac1, Frac2, _, _), addFracDiffDenom), S).
update(Plus, field(nodeOper, div), S)	:-	makeRootDiv(Plus, Frac1, Frac2, S).
addFracFields(Plus, Frac1, Frac2)		:-	makeRootDiv(Plus, Frac1, Frac2, S).

% convert right fraction into a product of denominators
makeRightMult(Frac2, Denom1, Num2, S) :- _selected(action(data(Plus, Frac1, Frac2, frac1(Num1, Denom1), frac2(Num2, Denom2)), addFracDiffDenom), S).
update(Frac2, field(nodeOper, mul), S) :- makeRightMult(Frac2, Denom1, Num2, S).
deleteFracFields(Frac2, S) :- makeRightMult(Frac2, Denom1, Num2, S).
inheritFrom(Num2, Denom1, S) :- makeRightMult(Frac2, Denom1, Num2, S).

% make the left side a sum over products of four terms
makeSumOf(Frac1, Num1, Denom1, Num2, Denom2, S) :- _selected(action(data(Plus, Frac1, Frac2, frac1(Num1, Denom1), frac2(Num2, Denom2)), addFracDiffDenom), S).
update(Frac1, field(nodeOper, add), S) :- makeSumOf(Frac1, Num1, Denom1, Num2, Denom2, S).
deleteFracFields(Frac1, S) :- makeSumOf(Frac1, Num1, Denom1, Num2, Denom2, S).

% convert old leaves to mul nodes
convertToOperWithKids(Num1, mul, 2, S) :- makeSumOf(Frac1, Num1, Denom1, Num2, Denom2, S).
convertToOperWithKids(Denom1, mul, 2, S) :- makeSumOf(Frac1, Num1, Denom1, Num2, Denom2, S).

% counting on convertToOperWithKids() to create these children
inheritFrom(Num1*max_terms + 1, Num1, S) :- makeSumOf(Frac1, Num1, Denom1, Num2, Denom2, S).
inheritFrom(Num1*max_terms + 2, Denom2, S) :- makeSumOf(Frac1, Num1, Denom1, Num2, Denom2, S).
inheritFrom(Denom1*max_terms + 1, Denom1, S) :- makeSumOf(Frac1, Num1, Denom1, Num2, Denom2, S).
inheritFrom(Denom1*max_terms + 2, Num2, S) :- makeSumOf(Frac1, Num1, Denom1, Num2, Denom2, S).
%================================================================================
%================================================================================
