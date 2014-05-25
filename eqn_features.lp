% Armando Diaz Tolentino <ajdt@cs.washington.edu> 
% 
% This file defines several features that may be selected for
% when generating equations with eqn_generator.lp
%

% why doesn't this work???
%_coeffUsage(Coeff, Usage) :- Usage = #count { holds(Node, field(nodeCoef, C), 0) : node(Node), coeffValue(C), C == Coeff }, coeffValue(Coeff).



:- 3 { holds(Node, field(nodeCoef, Coeff), 0) : node(Node) }, coeffValue(Coeff).

% positive coefficients only
posOnly.
:-	holds(Node, field(nodeCoef, Coeff), 0),
	posOnly,
	Coeff < 0.

% don't use zero
noZero.
:-	holds(Node, field(nodeCoef, Coeff), 0),
	noZero,
	Coeff == 0.

% don't use one
%noOne.
%:-	holds(Node, field(nodeCoef, Coeff), 0),
%	noOne,
%	Coeff == 1.


%================================================================================
% use second degree
%================================================================================
useSecondDeg.
:- 0 {holds(Node, field(nodeDeg, Deg), 0) : node(Node), degree(Deg), Deg == 2 } 0, useSecondDeg.

%noSecondDeg.
%:- 1 {holds(Node, field(nodeDeg, Deg), 0) : node(Node), degree(Deg), Deg == 2 } , noSecondDeg.

%================================================================================
% use first degree
%================================================================================
useFirstDeg.
:- 0 {holds(Node, field(nodeDeg, Deg), 0) : node(Node), degree(Deg), Deg == 1 } 0, useFirstDeg.

%noFirstDeg.
%:- 1 {holds(Node, field(nodeDeg, Deg), 0) : node(Node), degree(Deg), Deg == 1 } , noFirstDeg.



%================================================================================
% use constants
%================================================================================
useConstMono.
:- 0 {holds(Node, field(nodeDeg, Deg), 0) : node(Node), degree(Deg), Deg == 0 } 0, useConstMono.

%noConstMono.
%:- 1 {holds(Node, field(nodeDeg, Deg), 0) : node(Node), degree(Deg), Deg == 0 } , noConstMono.


