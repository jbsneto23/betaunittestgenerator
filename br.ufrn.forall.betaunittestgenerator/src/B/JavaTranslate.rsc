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

Synopsis: Functions that translate B predicates and expressions to Java expressions.

}

module B::JavaTranslate

import B::Syntax;
import String;
import ParseTree;
import IO;

public str translate(str txt, str object) = translatePred(object, parse(#Predicate, txt));
public str translate(str txt) = translatePred("", parse(#Predicate, txt));
public str translateExpression(str txt) = translateExp("", parse(#Expression, txt));

public str translatePred(str object, (Predicate) `(<Predicate p>)`) = "(<translatePred(object, p)>)";
public str translatePred(str object, (Predicate) `not(<Predicate p>)`) = "!(<translatePred(object, p)>)";
public str translatePred(str object, (Predicate) `<Predicate p1>&<Predicate p2>`) = "<translatePred(object, p1)> && <translatePred(object, p2)>";
public str translatePred(str object, (Predicate) `<Predicate p1>or<Predicate p2>`) = "<translatePred(object, p1)> || <translatePred(object, p2)>"; 
public str translatePred(str object, (Predicate) `<Predicate p1>=\><Predicate p2>`) = "!(<translatePred(object, p1)>) || <translatePred(object, p2)>";
public str translatePred(str object, (Predicate) `<Predicate p1>\<=\><Predicate p2>`) = "(<translatePred(object, p1)> && <translatePred(object, p2)>) || (!<translatePred(object, p1)> && !<translatePred(object, p2)>)";
public str translatePred(str object, (Predicate) `<Expression e1>=<Expression e2>`) = "<translateExp(object, e1)> == <translateExp(object, e2)>";
public str translatePred(str object, (Predicate) `<Expression e1>/=<Expression e2>`) = "<translateExp(object, e1)> != <translateExp(object, e2)>";
public str translatePred(str object, (Predicate) `<Expression e1>\<=<Expression e2>`) = "<translateExp(object, e1)> \<= <translateExp(object, e2)>";
public str translatePred(str object, (Predicate) `<Expression e1>\<<Expression e2>`) = "<translateExp(object, e1)> \< <translateExp(object, e2)>";
public str translatePred(str object, (Predicate) `<Expression e1>\>=<Expression e2>`) = "<translateExp(object, e1)> \>= <translateExp(object, e2)>";
public str translatePred(str object, (Predicate) `<Expression e1>\><Expression e2>`) = "<translateExp(object, e1)> \> <translateExp(object, e2)>";
public str translatePred(str object, (Predicate) `<Expression e1>:<Expression e2>`) {
	if((Expression) `<Expression i1>..<Expression i2>` := e2){
		return "<translateExp(object, e1)> \>= <translateExp(object, i1)> && <translateExp(object, e1)> \<= <translateExp(object, i2)>";	
	} else {
		return "<translateExp(object, e1)> != null /* <e1> : <e2> */";
	}
}
// AMM: discutir

public default str translatePred(str object, Predicate p) = "";

public str translateExp(str object, (Expression) `<Ident id>`){
	if(isEmpty(object)){
		return "<id>";
	} else {
		return object + ".get"
				+ toUpperCase(substring("<id>", 0, 1)) 
				+ substring("<id>", 1) + "()";
	}
}

public str translateExp(str object, (Expression) `(<Expression e>)`) = "(<translateExp(object, e)>)";

public str translateExp(str object, (Expression) `TRUE`) = "true";
public str translateExp(str object, (Expression) `FALSE`) = "false";
public str translateExp(str object, (Expression) `bool(<Predicate p>)`) = translatePred(object, p);

public str translateExp(str object, (Expression) `<Integer_literal i>`) = "<i>";
public str translateExp(str object, (Expression) `MAXINT`) = "java.lang.Integer.MAX_VALUE";
public str translateExp(str object, (Expression) `MININT`) = "java.lang.Integer.MIN_VALUE";

public str translateExp(str object, (Expression) `<Expression e1>+<Expression e2>`) = "<translateExp(object, e1)> + <translateExp(object, e2)>";
public str translateExp(str object, (Expression) `<Expression e1>-<Expression e2>`) = "<translateExp(object, e1)> - <translateExp(object, e2)>";
public str translateExp(str object, (Expression) `-<Expression e>`) = "-<translateExp(object, e)>";
public str translateExp(str object, (Expression) `<Expression e1>*<Expression e2>`) = "<translateExp(object, e1)> * <translateExp(object, e2)>";
public str translateExp(str object, (Expression) `<Expression e1>/<Expression e2>`) = "<translateExp(object, e1)> / <translateExp(object, e2)>";
public str translateExp(str object, (Expression) `<Expression e1>mod<Expression e2>`) = "<translateExp(object, e1)> % <translateExp(object, e2)>";
public str translateExp(str object, (Expression) `<Expression e1>**<Expression e2>`) = "java.lang.Math.pow(<translateExp(object, e1)>, <translateExp(object, e2)>)";
public str translateExp(str object, (Expression) `succ(<Expression e>)`) = "(<translateExp(object, e)> + 1)";
public str translateExp(str object, (Expression) `pred(<Expression e>)`) = "(<translateExp(object, e)> - 1)";
public str translateExp(str object, (Expression) `card(<Expression e>)`) = "(<translateExp(object, e)>).size()";
public str translateExp(str object, (Expression) `max(<Expression e>)`) = "java.util.Collections.max(<translateExp(object, e)>)";
public str translateExp(str object, (Expression) `min(<Expression e>)`) = "java.util.Collections.min(<translateExp(object, e)>)";

public default str translateExp(str object, Expression e) = "<e>";
