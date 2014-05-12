% two cases, there are more than two kids or there are exactly two kids
% each operator node is generated with at least two children, so no operator
% should ever have one child.




% this is where I'll be testing new rules to add to the solver

%================================================================================
% AddfracDiffDenom: A/B + C/B--> (A+C)/B
%================================================================================
% 						### RULE CONDITIONS ###
% NOTE: requires that both denominators be monomials: change this later to be more general!
% There's an add node with two div nodes as children
possible(action(data(Plus, Frac1, Num1, Denom1, Frac2, Num2, Denom2), addFracDiffDenom), S) 	:- 	holds(Plus, field(nodeOper,add), S),
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
makePlusDiv(Plus, Frac1, Frac2, S) 		:-	_selected(action(data(Plus, Frac1, Num1, Denom1, Frac2, Num2, Denom2), addFracDiffDenom), S).
update(Plus, field(nodeOper, div), S)	:-	makePlusDiv(Plus, Frac1, Frac2, S).
assigned(Plus, field(numer, Frac1), S) 	:-	makePlusDiv(Plus, Frac1, Frac2, S).
assigned(Plus, field(denom, Frac2), S) 	:-	makePlusDiv(Plus, Frac1, Frac2, S).

% convert right fraction into a product of denominators
makeFracMult(Frac2, Denom1, Num2, Denom2, S) :- _selected(action(data(Plus, Frac1, Num1, Denom1, Frac2, Num2, Denom2), addFracDiffDenom), S).
update(Frac2, field(nodeOper, mul), S) :- makeFracMult(Frac2, Denom1, Num2, Denom2, S).
removed(Frac2, field(numer, Num2), S) :- makeFracMult(Frac2, Denom1, Num2, Denom2, S).
removed(Frac2, field(denom, Denom2), S) :- makeFracMult(Frac2, Denom1, Num2, Denom2, S).
inheritFrom(Num2, Denom1, S) :- makeFracMult(Frac2, Denom1, Num2, Denom2, S).

% make the left side a sum over products of four terms
makeSumOf(Frac1, Num1, Denom1, Num2, Denom2, S) :- _selected(action(data(Plus, Frac1, Num1, Denom1, Frac2, Num2, Denom2), addFracDiffDenom), S).
update(Frac1, field(nodeOper, add), S) :- makeSumOf(Frac1, Num1, Denom1, Num2, Denom2, S).
removed(Frac1, field(numer, Num1), S) :- makeSumOf(Frac1, Num1, Denom1, Num2, Denom2, S).
removed(Frac1, field(denom, Denom1), S) :- makeSumOf(Frac1, Num1, Denom1, Num2, Denom2, S).

% delete these old leaves, they will now be subtrees
delete(Num1, S) :- makeSumOf(Frac1, Num1, Denom1, Num2, Denom2, S).
delete(Denom1, S) :- makeSumOf(Frac1, Num1, Denom1, Num2, Denom2, S).

% give them a new type
assigned(Num1, field(type,poly), S) :- makeSumOf(Frac1, Num1, Denom1, Num2, Denom2, S).
assigned(Denom1, field(type,poly), S) :- makeSumOf(Frac1, Num1, Denom1, Num2, Denom2, S).
% give them an operator
assigned(Num1, field(nodeOper,mul), S) :- makeSumOf(Frac1, Num1, Denom1, Num2, Denom2, S).
assigned(Denom1, field(nodeOper,mul), S) :- makeSumOf(Frac1, Num1, Denom1, Num2, Denom2, S).

% give them a child count
assigned(Num1, field(numChildren,2), S) :- makeSumOf(Frac1, Num1, Denom1, Num2, Denom2, S).
assigned(Denom1, field(numChildren,2), S) :- makeSumOf(Frac1, Num1, Denom1, Num2, Denom2, S).

% give them children
makeChild(Num1, Num1*max_terms + 1, Num1, S) :- makeSumOf(Frac1, Num1, Denom1, Num2, Denom2, S).
makeChild(Num1, Num1*max_terms + 2, Denom2, S) :- makeSumOf(Frac1, Num1, Denom1, Num2, Denom2, S).
makeChild(Denom1, Denom1*max_terms + 1, Num2, S) :- makeSumOf(Frac1, Num1, Denom1, Num2, Denom2, S).
makeChild(Denom1, Denom1*max_terms + 2, Denom1, S) :- makeSumOf(Frac1, Num1, Denom1, Num2, Denom2, S).
assigned(Parent, field(parentOf, ChildNo), S) :- makeChild(Parent, ChildNo, Inherit, S).


% give values to their children
node(ChildNo) 						:- makeChild(Parent, ChildNo, Inherit, S).
inheritFrom(ChildNo, Inherit, S) 	:- makeChild(Parent, ChildNo, Inherit, S).
% field values will be unassigned for the child at this point



% make left fraction into sum over two products








%================================================================================
%================================================================================
