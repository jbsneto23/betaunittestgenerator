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

Synopsis: Functions that create the CuTest test content from a TestSuite.

}
module generator::C::CuTest

import generator::Model;
import B::Syntax;
import B::CTranslate;
import ParseTree;
import String;
import List;
import IO;

@doc{

Synopsis: Function that returns the oracle strategies names of the test suite.

}
private str oracleStrategies(TestSuite testSuite){
	OracleStrategy first = head(testSuite.oracleStrategies);
	str oss = "";
	switch(first){
		case StateInvariant(): oss = "State Invariant";
		case ReturnValues(): oss = "Return Values";
		case StateVariables(): oss = "State Variables";
		case Exception(): oss = "Exception";
	}
	for(OracleStrategy os <- tail(testSuite.oracleStrategies)){
		switch(os){
			case StateInvariant(): oss = oss + ", State Invariant";
			case ReturnValues(): oss = oss + ", Return Values";
			case StateVariables(): oss = oss + ", State Variables";
			case Exception(): oss = oss + ", Exception";
		}
	}
	return oss;
}

@doc{

Synopsis: Function that generate a variable declaration.

}
private str variableDeclaration(TestSuite testSuite, str formula, str identifier, list[str] values) {
	list[str] predicates = testSuite.machineInvariant + [trim(pr) | str pr <- split("&", formula)]; // get invariant and formula predicates
	
	str ty = "";
	bool isSet = false;
	
	for(str p <- predicates) {
		try{
			Predicate predicate = parse(#Predicate, p);
			Expression expIdent = parse(#Expression, identifier);
			switch(predicate){
				// if the predicate is a belong the variable isn't a set
				case (Predicate) `<Expression e1>:<Expression e2>` : {
					if(e1 == expIdent){
						ty = "<e2>"; // get the variable type
						break;
					}
				}
				// if the predicate is an include the variable is a set (array)
				case (Predicate) `<Expression e1>\<:<Expression e2>` : {
					if(e1 == expIdent){
						ty = "<e2>"; // get the variable type
						isSet = true;
						break;
					}
				}
				// if the predicate is a strictly include the variable is a set (array)
				case (Predicate) `<Expression e1>\<\<:<Expression e2>` : {
					if(e1 == expIdent){
						ty = "<e2>"; // get the variable type
						isSet = true;
						break;
					}
				}
			}
		} catch: ;
	}
	
	isSet = isSet || size(values) > 1; // if the number of values is greater than 1 the variable is a set (array)
	
	if(isEmpty(ty)){
		ty = identifier; // if ty is empty takes identifier value
	}

	str declaration = "";

	if (ty == "INT" || ty == "NAT" || ty == "NAT1"
			|| ty == "INTEGER" || ty == "NATURAL"
			|| contains(ty, "MAXINT") || contains(ty, "MININT")
			|| contains(ty, "..")) {
		declaration = "int32_t";
	} else if (ty == "BOOL") {
		declaration = "bool";
	} else if(ty == "STRING") {
		declaration = "char*";
	} else {
		declaration = ty;
	}

	if (isSet) {
		declaration = declaration + "[]";
	}

	declaration = declaration + " " + identifier;

	return declaration;
}

@doc{

Synopsis: Function that generate a variable attribution.

}
public str variableAttribution(TestSuite testSuite, str formula, str identifier, list[str] values) {
	list[str] predicates = testSuite.machineInvariant + [trim(pr) | str pr <- split("&", formula)]; // get invariant and formula predicates
	
	bool isSet = false;
	
	for(str p <- predicates) {
		try {
			Predicate predicate = parse(#Predicate, p);
			Expression expIdent = parse(#Expression, identifier);
			switch(predicate){
				// if the predicate is an include the variable is a set
				case (Predicate) `<Expression e1>\<:<Expression e2>` : {
					if(e1 == expIdent){
						isSet = true;
						break;
					}
				}
				// if the predicate is a strictly include the variable is a set
				case (Predicate) `<Expression e1>\<\<:<Expression e2>` : {
					if(e1 == expIdent){
						isSet = true;
						break;
					}
				}
			}
		} catch: ;
	}
	
	isSet = isSet || size(values) > 1; // if the number of values is greater than 1 the variable is a set (array)
	
	str attribution = "";
	
	if (isSet) {
		if (values[0] == "{-}" || isEmpty(values)) { // empty array
			attribution = attribution + "{}";
		} else {
			Expression exp = parse(#Expression, head(values)); // array with the values
			attribution = attribution + "{" + translateExp("", exp);
			for (str s <- tail(values)) {
				exp = parse(#Expression, s);
				attribution = attribution + ", " + translateExp("", exp);
			}
			attribution = attribution + "}";
		}
	} else {
		if(!isEmpty(values)){
			str val = head(values);
			if(val == "{-}")
				val = "{}";
			Expression exp = parse(#Expression, val);
			attribution = attribution + translateExp("", exp); // simple variable attribution
		}
	}
	return attribution;
}

@doc{

Synopsis: Function that generate the operation call with the operation parameters and return variables.

}
private str operationCall(TestSuite testSuite, TestCase testCase){
	str call = testSuite.machineName + "$" + testSuite.operationUnderTest + "(&" + toLowerCase(testSuite.machineName);
	if(!isEmpty(testCase.operationParameters)){
		for(Parameter p <- testCase.operationParameters){
			call = call + ", " + p.identifier;
		}
	}
	if(!isEmpty(testCase.returnVariables)){
		for(Variable v <- testCase.returnVariables){
			call = call + ", " + v.identifier;
		}
	}
	call = call + ")";
	return call;
}

@doc{

Synopsis: Function that verify if the check invariant function content isn't empty.

}
private bool hasCheckInvariant(TestSuite testSuite){
	bool has = false;
	for(str p <- testSuite.machineInvariant){
		if(!isEmpty(translate(p, toLowerCase(testSuite.machineName)))){
			has = true;
		}
	}
	return has;
}

@doc{

Synopsis: Function that create the check invariant function content. Call functions to translate the invariant predicates.

}
private str templateCheckInvariant(TestSuite testSuite){
	return 
		"void check_invariant(CuTest* tc, <testSuite.machineName>$state$ <toLowerCase(testSuite.machineName)>) {
		'	<for(str p <- testSuite.machineInvariant){><if(!isEmpty(translate(p, toLowerCase(testSuite.machineName)))){>
		'	if(!(<translate(p, toLowerCase(testSuite.machineName))>)){
		'		CuFail(tc, \"The invariant \'<p>\' was unsatisfied\");
		'	}
		'	<} else {>// Predicate \'<p>\' can\'t be automatically translated <}><}>
		'}
		";
}

@doc{

Synopsis: Function that create the test case content. Call other functions to generate variable declaration and operation call.

}
private str templateTestCase(TestSuite testSuite, TestCase testCase){
	return
		"/**
		'* Test Case <testCase.id>
		'* Formula: <testCase.formula>
		'* <if(testCase.negative){>Negative Test<}else{>Positive Test<}>
		'*/
		'void <testSuite.machineName>_<testSuite.operationUnderTest>_test_case_<testCase.id>(CuTest* tc)
		'{
		'	<testSuite.machineName>$init$(&<toLowerCase(testSuite.machineName)>);
		'	<for(Variable variable <- testCase.stateVariables){>
		'	<variableDeclaration(testSuite, testCase.formula, variable.identifier, variable.values)> = <variableAttribution(testSuite, testCase.formula, variable.identifier, variable.values)>; 
		'	<toLowerCase(testSuite.machineName)>.<variable.identifier> = <variable.identifier>; <}>
		'	<for(Parameter parameter <- testCase.operationParameters){>
		'	<variableDeclaration(testSuite, testCase.formula, parameter.identifier, parameter.values)> = <variableAttribution(testSuite, testCase.formula, parameter.identifier, parameter.values)>; <}>
		'	<for(Variable v <- testCase.returnVariables){>
		'	// <v.identifier> return variable declaration <}>
		'	<operationCall(testSuite, testCase)>;
		'	<if(!isEmpty(testCase.returnVariables) && ReturnValues() in testSuite.oracleStrategies){>
		'	<for(Variable v <- testCase.returnVariables){> 
		'	CuAssertTrue(tc, <v.identifier> == /* Add expected value here */);<}><}>
		'	<if(StateVariables() in testSuite.oracleStrategies){> <for(Variable variable <- testCase.expectedStateValues){>
		'	<variableDeclaration(testSuite, testCase.formula, variable.identifier, [])>Expected<if(testCase.negative){>; // Add expected value here.<} else {> = <variableAttribution(testSuite, testCase.formula, variable.identifier, variable.values)>;<}>
		'	CuAssertTrue(tc, <toLowerCase(testSuite.machineName)>.<variable.identifier> == <variable.identifier>Expected);			
		'	<}> <}>
		'	<if(StateInvariant() in testSuite.oracleStrategies && hasCheckInvariant(testSuite)){>check_invariant(tc, <toLowerCase(testSuite.machineName)>);<}>
		'}
		";
}

@doc{

Synopsis: Main function that create the test content template and call another template functions.

}
public str templateCuTest(TestSuite testSuite){
	return
		"#include \<stdio.h\>
		'#include \<string.h\>
		'#include \<stdint.h\>
		'#include \"CuTest.h\"
		'#include \"<testSuite.machineName>.h\"
		'
		'<testSuite.machineName>$state$ <toLowerCase(testSuite.machineName)>;
		'<if(StateInvariant() in testSuite.oracleStrategies && hasCheckInvariant(testSuite)){>
		'<templateCheckInvariant(testSuite)> <}>
		'<for(TestCase testCase <- testSuite.testCases){>
		'<templateTestCase(testSuite, testCase)> <}>
		'/**
		'* Test Suite
		'* Machine: <testSuite.machineName>
		'* Operation: <testSuite.operationUnderTest>
		'*
		'* Partition Strategy: <testSuite.partitionStrategy>
		'* Combination Strategy: <testSuite.combinatorialCriteria>
		'* Oracle Strategy: <oracleStrategies(testSuite)>
		'*/
		'CuSuite* <testSuite.machineName>_<testSuite.operationUnderTest>_test_suite(void)
		'{
		'	CuSuite* suite = CuSuiteNew();
		'	<for(TestCase tc <- testSuite.testCases){>
		'	SUITE_ADD_TEST(suite, <testSuite.machineName>_<testSuite.operationUnderTest>_test_case_<tc.id>);<}>
		'	
		'	return suite;
		'}
		"
		;
}