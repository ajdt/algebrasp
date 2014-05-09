% Armando Diaz Tolentino <ajdt@cs.washington.edu> 
% 
% A simple ASP program to generate algebraic equations as an expression tree.
% Each node has an id(depth, id_num) predicate that uniquely identifies the node.
% depth refers to the node's depth from the root of the expression tree. 
% id_num is the node's placement in an ordering of it's parent's children.
% We identify a node by node(ID), where ID = id(depth, id_num).
% 
% each node also has a type (i.e. type(ID, mono;poly) ). poly types are internal
% nodes and have operators and children assigned to them. 
% mono types are leaf nodes, and have coefficient and degree values assigned to them.
%



% constants governing monomial values and tree depth
#const max_coeff	= 5.
#const max_degree	= 2.
#const max_depth 	= 2.
#const max_terms	= 3.		% max number of children a

coeff_value(-max_coeff..max_coeff).
degree(0..max_degree).
term_num(2..max_terms). 		% used for numbering children in a subtree

% sides of an equation
side(left;right).
operator(add;mul;div).
node_type(poly;mono).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% ROOT NODES  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
root(id(0,0), left).			% hardcoded left and right roots
root(id(0,1), right).
side(ID, S)		:- root(ID,S).
node(ID) 		:- root(ID,S).


% alternate definition of root nodes
%root( node(id(0,0),S) )	:- 	side(S).							%	every side of an equation has a root, with id(0,0)
%node(ID,S)				:-	root(node(ID,S)).							%	every root node is also an ordinary node

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% ASSIGNING TYPES TO NODES  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% every node has exactly one type
1 { type(id(Depth, IDNum), Type) : node_type(Type) } 1	:-	node(id(Depth, IDNum)), Depth < max_depth. 		% WHY DOESN'T pooling "1 { type(ID, mono;poly) } 1	:-	node(ID)." behave as in gringo3 ??
type(id(Depth, IDNum), mono)							:-	node(id(Depth, IDNum)), Depth >= max_depth. 			

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% POLY NODES  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% poly nodes have a single operator...
1 {node_oper(ID, Op) : operator(Op) } 1 				:-	node(ID), type(ID, poly) .
% ..and some number of children 
1 { num_children(ID, Terms) : term_num(Terms) } 1 		:-	type(ID, poly).
1 { parentOf(id(Depth, PIDNum), id(Depth+1, IDNum)) } 1	:- 	num_children(id(Depth, PIDNum), Num), IDNum = 1..Num. % generate child nodes

% generate child node
node(ID) 		:- parentOf(PID, ID).
% every child has same side as parent...
side(ID, S) 	:- parentOf(PID, ID), side(PID, S).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% MONOMIALS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% monomial nodes have coefficients and a degree
1 { node_coef(ID, Coeff) : coeff_value(Coeff) } 1		:-	type(ID, mono).
1 { node_deg(ID, Degree) : degree(Degree) } 1			:-	type(ID, mono).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% CONSTRAINTS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
:-	node(id(Depth, IdNum)), Depth > max_depth.		% sanity check, can't have nodes beyond max depth

