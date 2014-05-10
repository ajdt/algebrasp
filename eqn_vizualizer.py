#!/usr/bin/env python
#
# Author:	Armando Diaz Tolentino <ajdt@cs.washington.edu> 
#
# Desc:		A simple visualizer for the equations generated by the ASP program, eqn_generator.lp
#
# NOTE: 
#		requires asp output in json format. As of gringo4 this is possible with
#		clingo --outf=2 <gringo_file.lp>
#		
#		expects output from stdin, pipe clingo output to this program

import sys
import json
import re
from collections import defaultdict
import pdb


# values is a list of dictionaries, each dictionary contains one solution.
# each dictionary has one key called 'Value' which refers to a list of predicates and their values

two_term = re.compile("(\w+)\(([-\d\w]+),([-\d\w]+)\)")
op_symbols  = { 'div':'/', 'mul':'*', 'add':'+'}

def formEqnString(predicates_list):
	# one dictionary per predicate type
	types, operator			= {}, {} 		# key is node id in all cases
	mono, degree, coef 		= {}, {}, {} 
	children 				= defaultdict(list)

	for predicate in predicates_list:
		matching = two_term.match(predicate)
		if matching:
			functor, arg1, arg2 = matching.groups()
			addPredicateEntry(types, operator,mono, degree, coef, children, functor, arg1, arg2) ## Ugly, Ugly code, but ehh, it gets the job done :)
	return eqnString(types, operator,mono, degree, coef, children)

# add a given entry to coresponding dictionary
def addPredicateEntry(types, operator,mono, degree, coef, children, functor, arg1, arg2):
	if functor == 'type':
		types[arg1] = arg2
	elif functor == 'nodeOper':
		operator[ arg1 ] = arg2
	elif functor == 'parentOf':
		children[ arg1 ].append( arg2 )
	elif functor == 'nodeDeg':
		degree[arg1 ]  = arg2
	elif functor == 'nodeCoef':
		coef[arg1] = arg2

# form the full equation string given dictionaries with data
def eqnString(types, operator,mono, degree, coef, children):
	left	= formPolyString(types, operator,mono, degree, coef, children, '0')
	right	= formPolyString(types, operator,mono, degree, coef, children, '1')
	return  left[1:-1] + '=' + right[1:-1]	# NOTE: slicing to avoid outermost parens

def formPolyString(types, operator,mono, degree, coef, children, root):
	if types[root] == 'mono':
		return '(' + makeMonomialStr(root, coef, degree) + ')'

	child_strings = []
	for child in children[root]:
		child_strings.append( formPolyString(types, operator, mono, degree, coef, children, child) )
	return '(' + op_symbols[operator[root]].join(child_strings) + ')'

def makeMonomialStr(idnum, coef_dict, degree_dict):
	coef, exp = coef_dict[idnum], degree_dict[idnum]
	base = 'x'
	if coef == '0':
		return '0'
	elif exp == '0':
		return coef
	elif exp == '1':
		return coef + '*' + base
	else:
		return coef + '*' + base + '**' + exp

def main():
	clasp_output = ''.join(sys.stdin.xreadlines())
	decoded = json.loads(clasp_output)
	all_soln = decoded['Call'][0]['Witnesses']
	for solution in all_soln:
		print formEqnString(solution['Value'])

if __name__ == "__main__":
	main()
