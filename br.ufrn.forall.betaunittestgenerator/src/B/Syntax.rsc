@license{
	Copyright (c) 2014, Ernesto C. B. de Matos, Anamaria M. Moreira, João B. de S. Neto.
	All rights reserved.
	
	Redistribution and use in source and binary forms, with or without modification, are permitted provided that 
	the following conditions are met:
	
	1. Redistributions of source code must retain the above copyright notice, this list of conditions and the 
		following disclaimer.
	
	2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the 
		following disclaimer in the documentation and/or other materials provided with the distribution.
	
	3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote 
		products derived from this software without specific prior written permission.
	
	THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, 
	INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE 
	DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, 
	SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR 
	SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, 
	WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE 
	USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
}
@contributor{João Batista de Souza Neto}

@doc{

Synopsis: Grammar of the B Predicates based on the B Language Grammar of the B Language Reference Manual (http://www.math.pku.edu.cn/teachers/qiuzy/fm_B/Atelier_B/B-manrefb1.8.6.uk.pdf).

ProB B Notation:

Logical predicates:
-------------------
 P & Q       conjunction
 P or Q      disjunction
 P => Q      implication
 P <=> Q     equivalence
 not P       negation
 !(x).(P=>Q) universal quantification
 #(x).(P&Q)  existential quantification

Equality:
---------
 E = F      equality
 E /= F     disequality

Booleans:
---------
 TRUE
 FALSE
 BOOL        set of boolean values ({TRUE,FALSE})
 bool(P)     convert predicate into BOOL value

Sets:
-----
 {}          empty set
 {E}         singleton set
 {E,F}       set enumeration
 {x|P}       comprehension set
 POW(S)      power set
 POW1(S)     set of non-empty subsets
 FIN(S)      set of all finite subsets
 FIN1(S)     set of all non-empty finite subsets
 card(S)     cardinality
 S*T         cartesian product
 S\/T        set union
 S/\T        set intersection
 S-T         set difference
 E:S         element of
 E/:S        not element of
 S<:T        subset of
 S/<:T       not subset of
 S<<:T       strict subset of
 S/<<:T      not strict subset of
 union(S)        generalised union over sets of sets
 inter(S)         generalised intersection over sets of sets
 UNION(z).(P|E)  generalised union with predicate
 INTER(z).(P|E)  generalised intersection with predicate

Numbers:
--------
 INTEGER     set of integers
 NATURAL     set of natural numbers
 NATURAL1    set of non-zero natural numbers
 INT         set of implementable integers (MININT..MAXINT)
 NAT         set of implementable natural numbers
 NAT1        set of non-zero implementable natural numbers
 n..m        set of numbers from n to m
 MININT      the minimum implementable integer
 MAXINT      the maximum implementable integer
 m>n         greater than
 m<n         less than
 m>=n        greater than or equal
 m<=n        less than or equal
 max(S)      maximum of a set of numbers
 min(S)      minimum of a set of numbers
 m+n         addition
 m-n         difference
 m*n         multiplication
 m/n         division
 m**n        power
 m mod n     remainder of division
 PI(z).(P|E)    Set product
 SIGMA(z).(P|E) Set summation
 succ(n)     successor (n+1)
 pred(n)     predecessor (n-1)


Relations:
----------
 S<->T     relation
 E|->F     maplet
 dom(r)    domain of relation
 ran(r)    range of relation
 id(S)     identity relation
 S<|r      domain restriction
 S<<|r     domain subtraction
 r|>S      range restriction
 r|>>S     range subtraction
 r~        inverse of relation
 r[S]      relational image
 r1<+r2    relational overriding (r2 overrides r1)
 r1><r2    direct product {x,(y,z) | x,y:r1 & x,z:r2}
 (r1;r2)     relational composition {x,y| x|->z:r1 & z|->y:r2}
 (r1||r2)    parallel product {((x,v),(y,w)) | x,y:r1 & v,w:r2}
 prj1(S,T)     projection function (usage prj1(Dom,Ran)(Pair))
 prj2(S,T)     projection function (usage prj2(Dom,Ran)(Pair))
 closure1(r)   transitive closure
 closure(r)    reflexive & transitive closure
               (non-standard version: closure({}) = {}; see iterate(r,0) below)
 iterate(r,n)  iteration of r with n>=0 
               (Note: iterate(r,0) = id(s) where s = dom(r)\/ran(r))
 fnc(r)    translate relation A<->B into function A+->POW(B)
 rel(r)    translate relation A<->POW(B) into relation A<->B

Functions:
----------
  S+->T      partial function
  S-->T      total function
  S+->>T     partial surjection
  S-->>T     total surjection
  S>+>T      partial injection
  S>->T      total injection
  S>+>>T     partial bijection
  S>->>T     total bijection
  %x.(P|E)   lambda abstraction
  f(E)       function application
  f(E1,...,En)   is now supported (as well as f(E1|->E2))


Sequences:
----------
  <> or []   empty sequence
  [E]        singleton sequence
  [E,F]      constructed sequence
  seq(S)     set of sequences over Sequence
  seq1(S)    set of non-empty sequences over S
  iseq(S)    set of injective sequences
  iseq1(S)   set of non-empty injective sequences
  perm(S)    set of bijective sequences (permutations)
  size(s)    size of sequence
  s^t        concatenation
  E->s       prepend element
  s<-E       append element
  rev(s)     reverse of sequence
  first(s)   first element
  last(s)    last element
  front(s)   front of sequence (all but last element)
  tail(s)    tail of sequence (all but first element)
  conc(S)    concatenation of sequence of sequences
  s/|\n     take first n elements of sequence
  s\|/n     drop first n elements from sequence
  
Records:
--------
  struct(ID:S,...,ID:S)   set of records with given fields and field types
  rec(ID:E,...,ID:E)      construct a record with given field names and values
  E'ID                    get value of field with name ID

Strings:
--------
  "astring"    a specific string value
  STRING       the set of all strings
               Note: for the moment enumeration of strings is limited (if a variable
               of type STRING is not given a value by the machine, then ProB assumes
               STRING = { "STR1", "STR2" })
Trees:
------
  left, right, tree, btree, ... are recognised by the parser but not yet 
               supported by ProB itself

}

module B::Syntax

layout Whitespaces = [\t\n\ \r\f]*;

lexical Ident = ([a-z A-Z 0-9 _] !<< [a-z A-Z][a-z A-Z 0-9 _]* !>> [a-z A-Z 0-9 _]) \ Keywords; 
lexical Integer_literal = [0-9]+;

keyword Keywords = "not" | "MAXINT" | "MININT" | "TRUE" | "FALSE"
					| "NAT" | "NAT1" | "INT"| "BOOL" | "STRING" 
					| "bool" | "succ" | "pred" | "max" | "min" | "card" 
					| "SIGMA" | "PI" | "POW" | "POW1" | "FIN" | "FIN1"
					| "union" | "inter" | "UNION" | "INTER";

start syntax Predicate
	= bracket Bracketed_predicate: "(" Predicate p ")"
	| Negation_predicate: "not" "(" Predicate p ")"
	| left Conjunction_predicate: Predicate p1 "&" Predicate p2
	| left Disjunction_predicate: Predicate p1 "or" Predicate p2
	| left Implication_predicate: Predicate p1 "=\>" Predicate p2
	| left Equivalence_predicate: Predicate p1 "\<=\>" Predicate p2
	| Predicate_universal: "!" List_ident li "." "(" Predicate p1 "=\>" Predicate p2 ")" // TODO ?
	| Existential_predicate: "#" List_ident li "." "(" Predicate p ")" // TODO ?
	| left Equals_predicate: Expression e1 "=" Expression e2
	| left Predicate_unequal: Expression e1 "/=" Expression e2
	| left Less_than_or_equal_predicate: Expression e1 "\<=" Expression e2
	| left Strictly_less_than_predicate: Expression e1 "\<" Expression e2
	| left Preedicate_greater_than_or_equal: Expression e1 "\>=" Expression e2
	| left Strictly_greater_predicate_than: Expression e1 "\>" Expression e2
	| left Belongs_predicate: Expression e1 ":" Expression e2 // TODO (Partly)
	| left Non_belongs_predicate: Expression e1 "/:" Expression e2 // TODO ?
	| left Predicate_includes: Expression e1 "\<:" Expression e2 // TODO ?
	| left Predicate_includes_strictly: Expression e1 "\<\<:" Expression e2 // TODO ?
	| left Non_inclusion_predicate: Expression e1 "/\<:" Expression e2 // TODO ?
	| left Non_inclusion_predicate_strict: Expression e1 "/\<\<:" Expression e2 // TODO ?
	;

// AMM: os quantificadores sao traduzidos por for, testando cada valor - se o conjunto e grande, se tem mais de uma variavel, precisa usar algum tipo de
// analise para limitar o escopo do for - e um problema com explosao combinatoria

syntax List_ident
	= ID: Ident id
	| List_id: "(" {Ident ","}+ li ")"
	;

syntax Expression 
	= Expressions_primary
	| Expressions_Boolean
	| Expressions_arithmetical
	| Expressions_of_couples
	| Expressions_of_sets
	| Construction_of_sets
	| Expressions_of_relations
	| Expressions_of_functions
	| Construction_of_functions
	| Expressions_of_sequences
	| Construction_of_sequences
	;

syntax Expressions_primary
	= Data: Ident+ id
	| bracket Expr_bracketed: "(" Expression e ")"
	;
	
syntax Expressions_Boolean
	= TRUE: "TRUE"
	| FALSE: "FALSE"
	| Conversion_Bool: "bool" "(" Predicate p ")"
	;

syntax Expressions_arithmetical
	= Integer_lit
	| left Addition: Expression e1 "+" Expression e2
	| left Difference: Expression e1 "-" Expression e2 
	| Unary_minus: "-"Expression  e1
	| left Product: Expression e1 "*" Expression e2
	| left Division: Expression e1 "/" Expression e2
	| left Modulo: Expression e1 "mod" Expression e2
	| left Power_of: Expression e1 "**" Expression e2
	| Successor: "succ" "(" Expression e ")"
	| Predecessor: "pred" "(" Expression e ")"
	| Maximum: "max"  "(" Expression e ")" // TODO ?  AMM: a expressao e deve ter que ser um conjunto - se a linguagem destino nao tem o equivalente
    // de max ou de qualquer funcao do B, precisa definir essas funcoes na linguagem destino
	| Minimum: "min"  "(" Expression e ")" // TODO ? 
	| Cardinal: "card"  "(" Expression e ")" // TODO (Partly)
	| Generalized_sum: "SIGMA" List_ident li "." "(" Predicate p "|" Expression e ")" // TODO ?
	| Generalized_product: "PI" List_ident li "." "(" Predicate p "|" Expression e ")" // TODO ?
	;
	
syntax Integer_lit
	= Integer_literal il
	| MAX_INT: "MAXINT"
	| MIN_INT: "MININT"
	;
	
// TODO
syntax Expressions_of_couples
	= left Couple: Expression e1 "|-\>" Expression e2
	| left Couple2: Expression e1 "," Expression e2
	;
	
syntax Expressions_of_sets
	= Empty_set: "{" "}"
	| Boolean_set: "BOOL"
	| Strings_set: "STRING"
	| Integer_set
	;
	
syntax Integer_set
	= Natural: "NAT"
	| Natural1: "NAT1"
	| Integer: "INT"
	;

// TODO ?
syntax Construction_of_sets
	= Comprehension_set: "{" {Ident ","}+ li "|" Predicate p "}"
	| Subset: "POW" "(" Expression e ")"
	| Subset1: "POW1" "(" Expression e ")" 
	| Finite_subset: "FIN" "(" Expression e ")"
	| Finite_subset1: "FIN1" "(" Expression e ")"
	| Set_extension: "{" {Expression ","}+ li "}"
	| left Interval: Expression e1 ".." Expression e2 // Partly
	| left Union: Expression e1 "\\/" Expression e2
	| left Intersection: Expression e1 "/\\" Expression e2
	| Generalized_union: "union" "(" Expression e ")"
	| Generalized_intersection: "inter" "(" Expression e ")"
	| Quantified_union: "UNION" List_ident li "." "(" Predicate p "|" Expression e ")"
 	| Quantified_intersection: "INTER" List_ident li "." "(" Predicate p "|" Expression e ")"
	;
	
// TODO ?
syntax Expressions_of_relations
	= left Relations: Expression e1 "\<-\>" Expression e2
	| Identity: "id" "(" Expression e ")"
	| Reverse: Expression e "~"
	| First_projection: "prj1" "(" Expression e1 "," Expression e2 ")"
	| Second_projection: "prj2" "(" Expression e1 "," Expression e2 ")"
	| left Composition: Expression e1 ";" Expression e2
	| left Direct_product: Expression e1 "\>\<" Expression e2
	| left Parallel_product:  Expression e1 "||" Expression e2	
	| Iteration: "iterate" "(" Expression e1 "," Expression e2 ")"
	| Reflexive_closure: "closure" "(" Expression e ")"
	| Closure: "closure1" "(" Expression e ")"
	| Domain: "dom" "(" Expression e ")"
	| Range: "ran" "(" Expression e ")"
	| left Image: Expression e1 "[" Expression e2 "]"
	| left Domain_restriction: Expression e1 "\<|" Expression e2
	| left Domain_subtraction: Expression e1 "\<\<|" Expression e2
	| left Range_restriction: Expression e1 "|\>" Expression e2
	| left Range_subtraction:  Expression e1 "|\>\>" Expression e2
	| left Overwrite: Expression e1 "\<+" Expression e2
	;

// TODO ?
syntax Expressions_of_functions
	= Partial_functions: Expression e1 "+-\>" Expression e2
	| Total_functions: Expression e1 "--\>" Expression e2
	| Partial_injections: Expression e1 "\>+\>" Expression e2
	| Total_injections: Expression e1 "\>-\>" Expression e2
	| Partial_surjections: Expression e1 "+-\>\>" Expression e2
	| Total_surjections: Expression e1 "--\>\>" Expression e2
	| Partial_bijections: Expression e1 "\>+\>\>" Expression e2
	| Total_bijections: Expression e1 "\>-\>\>" Expression e2
	;

// TODO ?
syntax Construction_of_functions
	= Lambda_expression: "%" List_ident li "." "(" Predicate p "|" Expression e ")"
	| Evaluation_functions: Expression e "(" {Expression ","}+ li ")"
	| Transformed_function: "fnc" "(" Expression e ")"
	| Transformed_relation: "rel" "(" Expression e ")" 
	;
	
// TODO ?
syntax Expressions_of_sequences 
	= Sequences: "seq" "(" Expression e ")"
	| Non_empty_sequences: "seq1" "(" Expression e ")"
	| Injective_sequences: "iseq" "(" Expression e ")"
	| Non_empty_inj_sequences: "iseq1" "(" Expression e ")"
	| Permutations: "perm" "(" Expression e ")"
	;
	
// TODO
syntax Construction_of_sequences 
	= Empty_sequence: "\<" "\>"
	| Empty_sequence2: "[" "]"
	| Sequence_extension: "\<" {Expression ","}* li "\>"
	| Sequence_extension2: "[" {Expression ","}* li "]"
	| Sequence_size: "size" "(" Expression e ")"
	| Sequence_first_element: "first" "(" Expression e ")"
	| Sequence_last_element: "last" "(" Expression e ")"
	| Sequence_front: "front" "(" Expression e ")"
	| Sequence_tail: "tail" "(" Expression e ")"
	| Reverse_sequence: "rev" "(" Expression e ")"
	| left Concatenation: Expression e1 "^" Expression e2
	| left Insert_front: Expression e1 "-\>" Expression e2
	| left Insert_tail: Expression e1 "\<-" Expression e2
	| left Restrict_front: Expression e1 "/|\\" Expression e2
	| left Restrict_tail: Expression e2 "\\|/" Expression e2 
	| Generalized_concat: "conc" "(" Expression e ")"
	;