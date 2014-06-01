% Armando Diaz Tolentino <ajdt@cs.washington.edu> 
% 
% This file defines several features that may be selected for
% when generating equations with eqn_generator.lp
%

% why doesn't this work???
%_coeffUsage(Coeff, Usage) :- Usage = #count { holds(Node, field(nodeCoef, C), 0) : node(Node), coeffValue(C), C == Coeff }, coeffValue(Coeff).




%================================================================================
% positive coefficients only
%================================================================================
:-	holds(Node, field(nodeCoef, Coeff), 0),
	posOnly,
	Coeff < 0.

%================================================================================
% don't use zero
%================================================================================
:-	holds(Node, field(nodeCoef, Coeff), 0),
	noZero,
	Coeff == 0.
%================================================================================
% don't use one
%================================================================================
:-	holds(Node, field(nodeCoef, 1), 0),
	Node != one,
	noOne.
%================================================================================
% use/don't use second degree
%================================================================================
:- 0 {holds(Node, field(nodeDeg, 2), 0) : node(Node) } 0, useSecondDeg.
:- 1 {holds(Node, field(nodeDeg, 2), 0) : node(Node) } , noSecondDeg.

%================================================================================
% use/don't use first degree
%================================================================================
:- 0 {holds(Node, field(nodeDeg, 1), 0) : node(Node) } 0, useFirstDeg.
:- 1 {holds(Node, field(nodeDeg, 1), 0) : node(Node) } , noFirstDeg.

%================================================================================
% use/don't use constants
%================================================================================
% note: constant one, always has zero degree, so we exclude it
:- 0 {holds(Node, field(nodeDeg, 0), 0) : node(Node), Node != one } 0, useConstMono.
:- 1 {holds(Node, field(nodeDeg, 0), 0) : node(Node), Node != one } , noConstMono.

%================================================================================
% use/don't use operators
%================================================================================
:- 0 {holds(Node, field(nodeOper, add), 0) : node(Node) } 0, useAddOper.
:- 1 {holds(Node, field(nodeOper, add), 0) : node(Node) } , noAddOper.

:- 0 {holds(Node, field(nodeOper, mul), 0) : node(Node) } 0, useMulOper.
:- 1 {holds(Node, field(nodeOper, mul), 0) : node(Node) } , noMulOper.

:- 0 {holds(Node, field(nodeOper, div), 0) : node(Node) } 0, useDivOper.
:- 1 {holds(Node, field(nodeOper, div), 0) : node(Node) } , noDivOper.

%================================================================================
% 							Equation forms
%================================================================================

%================================================================================
% Complete the Square Features
%================================================================================
feature(compSquareWithoutAddTerm)	:-	_selected(action(data(Plus, XSquare, XMonom, Const), compSquare), S).

feature(compSquareHasAddTerm)		:-	_selected(action(data(Plus, XSquare, XMonom, Const, ResidualCoef), compSquare), S).

%================================================================================
% Factor features
%================================================================================
feature(sumOfSquares)				:-	_selected(action(data(quadNoXTerm(Plus, children(XSquare, Const))), factorQuad), S).

feature(regFactor)					:-	_selected(action(data(Plus, CoefD, CoefE), factorQuad), S).

%================================================================================
% available features
%================================================================================
%posOnly.
%noZero.
%noOne.
%useSecondDeg.
%noSecondDeg.
%useFirstDeg.
%noFirstDeg.
%useConstMono.
%noConstMono.
%useAddOper.
%noAddOper.
%useMulOper.
%noMulOper.
%useDivOper.
%noDivOper.


%================================================================================
% Use only certain rules
%================================================================================
% using only certain rules, any order
% use only certain ruels in specific order (n-gram for n greater than 1)
% don't use certain rules
%:- not action(addCommTerms).
%:- not addCommonThenIdent.

%addCommonThenIdent	:-	_selected(action(X, addCommTerms), S),
%						_selected(action(Y, addIdent), S+1),
%						_selected(action(Z, divInverse), S+2),
%						step(S).

% todo: delete this, adds variety to a bucket (not needed)
%:- 3 { holds(Node, field(nodeCoef, Coeff), 0) : node(Node) }, coeffValue(Coeff).

%:- not sumOfSquares.
