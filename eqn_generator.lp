% Armando Diaz Tolentino <ajdt@cs.washington.edu> 
% 
% A simple ASP program to generate algebraic equations as an expression tree.
% Each node has an id numer that is unique and given by the formula: parentID * max_terms + num_term
% Nodes have a depth value, so that we don't create expression trees exceeding some maximum depth.
% 
% each node also has a type (i.e. type(ID, mono;poly) ). poly types are internal
% nodes and have operators and children assigned to them. 
% mono types are leaf nodes, and have coefficient and degree values assigned to them.
%



% constants governing monomial values and tree depth
#const max_coeff	= 5.
#const max_degree	= 2.
#const max_depth 	= 2.
#const max_terms	= 2.		% max number of children a

coeffValue(-max_coeff..max_coeff).
degree(0..max_degree).
termNum(2..max_terms). 		% used for numbering children in a subtree

% sides of an equation
side(left;right).
operator(add;mul;div).
nodeType(poly;mono).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% ROOT NODES  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
root(1, left).			% hardcoded left and right roots
root(2, right).
side(ID, S)		:- root(ID,S).
node(ID) 		:- root(ID,S).
depth(ID,0)		:- root(ID,S). 		% every root starts at depth zero


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% ASSIGNING TYPES TO NODES  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% every node has exactly one type. If below depth threshold, can choose that type, otherwise it's a monomial
1 { type(ID, Type) : nodeType(Type) } 1	:-	node(ID), depth(ID, Depth), Depth < max_depth. 	% TODO: WHY DOESN'T pooling "1 { type(ID, mono;poly) } 1	:-	node(ID)." behave as in gringo3 ??
type(ID, mono)							:-	node(ID), depth(ID, Depth), Depth >= max_depth. 			

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% POLY NODES  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
1 {nodeOper(ID, Op) : operator(Op) } 1 				:-	type(ID, poly) .										% poly nodes have a single operator...
1 { numChildren(ID, Terms) : termNum(Terms) } 1 	:-	type(ID, poly), not nodeOper(ID, div).					% ..and some number of children 
numChildren(ID, 2) 									:-	type(ID, poly), nodeOper(ID, div).						% divison operators have exactly two children

% label numerator and denominator of a fraction separately
numer(ID, Numer) :- nodeOper(ID, div), parentOf(ID, Numer), parentOf(ID, Denom), Numer < Denom.
denom(ID, Denom) :- nodeOper(ID, div), parentOf(ID, Numer), parentOf(ID, Denom), Numer < Denom.

% generate parent relationship.
1 { parentOf(ID, ID*max_terms + IDNum) } 1			:- 	numChildren(ID, Num), IDNum = 1..Num. 

% generate child node
node(ID) 				:- parentOf(PID, ID).
% every child has same side as parent, and depth plus 1...
side(ID, S) 			:- parentOf(PID, ID), side(PID, S).
depth(ChildID, Depth+1)	:-	parentOf(ParentID, ChildID), depth(ParentID, Depth).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% MONOMIALS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% monomial nodes have coefficients and a degree
1 { nodeCoef(ID, Coeff) : coeffValue(Coeff) } 1		:-	type(ID, mono).
1 { nodeDeg(ID, Degree) : degree(Degree) } 1		:-	type(ID, mono).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% CONSTRAINTS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
:-	depth(ID, Depth), Depth > max_depth.		% sanity check, can't have nodes beyond max depth
