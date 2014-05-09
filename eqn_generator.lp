% Armando Diaz Tolentino <ajdt@cs.washington.edu> 
% 
% A simple ASP program to generate algebraic equations

% constants governing monomials and tree depth
#const max_coeff = 5.
#const max_degree = 2.
#const max_depth = 1.
#const max_terms = 3.

coeff_value(-max_coeff..max_coeff).
degree(0..max_degree).
term_num(2..max_terms). 		% used for numbering terms in a subtree

% sides of an equation
side(left;right).
operator(add;mul;div).

side( id(0,0), left).
side( id(0,1), right).
node(id(0,0)).
node(id(0,1)).

% alternate definition of root nodes
%root( node(id(0,0),S) )	:- 	side(S).							%	every side of an equation has a root, with id(0,0)
%node(ID,S)				:-	root(node(ID,S)).							%	every root node is also an ordinary node

% every node is either a polynomial node or a monomial node
1 {type(ID, poly;mono) } 1	:-	node(ID). 

% poly nodes
1 {operation(ID, Op) : operator(Op) } 1 :- node(ID), type(ID, poly) .
% ..have children
1 { num_children(ID, Terms) : term_num(Terms) } 1 :- type(ID, poly).
1 { childOf(id(Depth, PIDNum), id(Depth+1, IDNum)) } 1 :- num_children(id(Depth, PIDNum), Num), IDNum := 1..Num. % generate child nodes
node(ID) :- childOf(PID, ID).
side(ID, S) :- childOf(PID, ID), side(PID, S).




% constraints:
:-	node(id(Depth, IdNum)), Depth > max_depth.		% can't have nodes beyond max depth
:-	node(ID), 2 { side(ID,S) : side(S) }.			% each node can only be on one side
:-	node(ID), 2 { childOf(PID, ID) : node(PID) }.	% each node can only have one parent

