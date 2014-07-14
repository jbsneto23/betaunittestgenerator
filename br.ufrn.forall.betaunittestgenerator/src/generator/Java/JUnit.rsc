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

Synopsis: Functions that create the JUnit test content from a TestSuite.

}

module generator::Java::JUnit

import generator::Model;
import B::Syntax;
import B::JavaTranslate;
import ParseTree;
import String;
import List;

import IO;

@doc{

Synopsis: Function that returns the class name.

}
public str className(TestSuite testSuite){
	return testSuite.machineName + toUpperCase(substring(testSuite.operationUnderTest, 0, 1)) 
			+ substring(testSuite.operationUnderTest, 1) + "Test";
}

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
		declaration = "int";
	} else if (ty == "BOOL") {
		declaration = "boolean";
	} else if(ty == "STRING") {
		declaration = "String";
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
	}
	
	isSet = isSet || size(values) > 1; // if the number of values is greater than 1 the variable is a set (array)
	
	str attribution = "";
	
	if (isSet) {
		if (values[0] == "{-}") { // empty array
			attribution = attribution + "{}";
		} else {
			Expression exp = parse(#Expression, head(values));
			attribution = attribution + "{" + translateExp("", exp); // array with the values
			for (str s <- tail(values)) {
				exp = parse(#Expression, s);
				attribution = attribution + ", " + translateExp("", exp);
			}
			attribution = attribution + "}";
		}
	} else {
		Expression exp = parse(#Expression, head(values));
		attribution = attribution + translateExp("", exp); // simple variable attribution
	}
	return attribution;
}

@doc{

Synopsis: Function that generate a set call of a state variable.

}
private str setCall(str objectName, str identifier) {
	str call = objectName + ".set"
			+ toUpperCase(substring(identifier, 0, 1)) 
			+ substring(identifier, 1) + "(" + identifier + ")";
	return call;
}

@doc{

Synopsis: Function that generate a get call of a state variable.

}
private str getCall(str objectName, str identifier) {
	str call = objectName + ".get"
			+ toUpperCase(substring(identifier, 0, 1)) 
			+ substring(identifier, 1) + "()";
	return call;
}

@doc{

Synopsis: Function that generate the operation call with the operation parameters.

}
private str operationCall(str objectName, str operation, list[Parameter] parameters){
	str call = objectName + "." + operation + "(";
	if(!isEmpty(parameters)){
		call = call + head(parameters).identifier;
		for(Parameter p <- tail(parameters)){
			call = call + ", " + p.identifier;
		}
	}
	call = call + ")";
	return call;
}

@doc{

Synopsis: Function that verify if the check invariant method content isn't empty.

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

Synopsis: Function that create the check invariant method content. Call functions to translate the invariant predicates.

}
private str templateCheckInvariant(TestSuite testSuite){
	return 
		"@After
		'public void checkInvariant() throws Exception {
		'	<for(str p <- testSuite.machineInvariant){>
		'	<if(!isEmpty(translate(p, toLowerCase(testSuite.machineName)))){>
		'	if(!(<translate(p, toLowerCase(testSuite.machineName))>)){
		'		fail(\"The invariant \'<p>\' was unsatisfied\");
		'	}
		'	<} else {>// Predicate \'<p>\' can\'t be automatically translated <}><}>
		'}
		";
}

@doc{

Synopsis: Function that create the test case content. Call other functions to generate variable declaration, set and get declaration and operation call.

}
private str templateTestCase(TestSuite testSuite, TestCase testCase){
	return
		"/**
		'* Test Case <testCase.id>
		'* Formula: <testCase.formula>
		'* <if(testCase.negative){>Negative Test<}else{>Positive Test<}>
		'*/
		'@Test
		'public void testCase<testCase.id>() {
		'	<for(Variable variable <- testCase.stateVariables){>
		'	<variableDeclaration(testSuite, testCase.formula, variable.identifier, variable.values)> = <variableAttribution(testSuite, testCase.formula, variable.identifier, variable.values)>;
		'	<setCall(toLowerCase(testSuite.machineName), variable.identifier)>;
		'	<}> <for(Parameter parameter <- testCase.operationParameters){>
		'	<variableDeclaration(testSuite, testCase.formula, parameter.identifier, parameter.values)> = <variableAttribution(testSuite, testCase.formula, parameter.identifier, parameter.values)>; <}>
		'	<if(!isEmpty(testCase.returnVariables) && ReturnValues() in testSuite.oracleStrategies){>
		'	assertEquals(<operationCall(toLowerCase(testSuite.machineName), testSuite.operationUnderTest, testCase.operationParameters)>, /* Add expected value here */);
		'	<} else {>
		'	<operationCall(toLowerCase(testSuite.machineName), testSuite.operationUnderTest, testCase.operationParameters)>;
		'	<}> <if(StateVariables() in testSuite.oracleStrategies){> <for(Variable variable <- testCase.stateVariables){>
		'	<variableDeclaration(testSuite, testCase.formula, variable.identifier, [])>Expected; // Add expected value here.
		'	assertEquals(<getCall(toLowerCase(testSuite.machineName), variable.identifier)>, <variable.identifier>Expected);			
		'	<}> <}>
		'}
		";
}

@doc{

Synopsis: Main function that create the test content template and call another template functions.

}
public str templateJUnit(TestSuite testSuite){
	return
		"import org.junit.Before;
		'import org.junit.After;
		'import org.junit.Test;
		'import static org.junit.Assert.*;
		'
		'/**
		'* Machine: <testSuite.machineName>
		'* Operation: <testSuite.operationUnderTest>
		'*
		'* Partition Strategy: <testSuite.partitionStrategy>
		'* Combination Strategy: <testSuite.combinatorialCriteria>
		'* Oracle Strategy: <oracleStrategies(testSuite)>
		'*/
		'public class <className(testSuite)> { 
		'
		'	private <testSuite.machineName> <toLowerCase(testSuite.machineName)>;
		'
		'	@Before
		'	public void setUp() throws Exception {
		'		<toLowerCase(testSuite.machineName)> = new <testSuite.machineName>();
		'	} 
		'	<if(StateInvariant() in testSuite.oracleStrategies && hasCheckInvariant(testSuite)){>
		'	<templateCheckInvariant(testSuite)> <}>
		'	<for(TestCase testCase <- testSuite.testCases){>
		'	<templateTestCase(testSuite, testCase)> <}>
		'}
		";
}