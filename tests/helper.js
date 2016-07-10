assert = function(expected, actual) {
	if (typeof(expected) == 'object' && typeof(actual) == 'object') {
		if (!expected.equals(actual)) {
			throw new Error("Assertion Error: " + expected.toString() + " is not the same as " + actual.toString());
		}
	} else {
		if (expected != actual) {
			throw new Error("Assertion Error: " + expected + " does not equal " + actual);
		}
	}
}

describe = function(objective, test) {
	console.log(objective);
	if (typeof(test) == 'function') {
		test();
		console.log("Tests passed\n");
	} else {
		console.log("No tests written\n");
	}
}

section = function(label, tests) {
	console.log("\n*********************\n" +label +"\n*********************");
	if (typeof(tests) == 'function') {
		tests();
		console.log("\nSection tests passed");
	} else {
		console.log("No tests written for this section");
	}
}
