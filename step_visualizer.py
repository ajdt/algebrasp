#!/usr/bin/env python
#
# Author:	Armando Diaz Tolentino <ajdt@cs.washington.edu> 
#
# Desc:		A simple visualizer to show the steps that eqn_solver executes to solve an equation.
#			Reuses much of the code in eqn_vizualizer.py
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
from eqn_vizualizer import *

three_term	= re.compile("(\w+)\(([-\d\w]+),([-\d\w]+),([-\d\w]+)\)")

# used to make a defaultdictionary with a defaultfactory that makes another defaultdictionary. 
# this is all very confusing, and I'm not sure even I understand it.
def makeDefDictList():
	return defaultdict(list)

# forms an equation string for each step
def formEqnStepString(predicates_list):
	# for each dictionary: key (step number) --> dictionary of predicate values at that step
	types, operator			= defaultdict(dict), defaultdict(dict) 		# key is node id in all cases
	mono, degree, coef		= defaultdict(dict), defaultdict(dict), defaultdict(dict)
	children 				= defaultdict(makeDefDictList)
	all_steps 				= set()

	for predicate in predicates_list:
		matching = three_term.match(predicate)
		if matching:
			functor, arg1, arg2, step = matching.groups()
			step = int(step)
			all_steps.add(step)
			addPredicateEntry(types[step], operator[step], mono[step], degree[step], coef[step], children[step], functor, arg1, arg2) ## Ugly, Ugly code, but ehh, it gets the job done :)
	every_step = []
	# for every step, lookup
	for step in sorted(all_steps):
		every_step.append(str(step) + ':\t' + eqnString(types[step], operator[step], mono[step], degree[step], coef[step], children[step]))

	return '\n'.join(every_step) + '\n'

def main():
	clasp_output = ''.join(sys.stdin.xreadlines())
	decoded = json.loads(clasp_output)
	all_soln = decoded['Call'][0]['Witnesses']
	for solution in all_soln:
		print formEqnStepString(solution['Value'])

if __name__ == "__main__":
	main()
