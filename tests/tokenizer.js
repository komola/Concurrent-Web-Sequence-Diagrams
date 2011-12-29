Tokenizer = require("../client/assets/script/tokenizer");

exports.testReturnedStructure = function(test) {
  var result = Tokenizer.tokenize("Mensch -> Hund: Hat");
  //test.equal(result.length, 2);
  //test.ok(result[tokens]);
  test.done();
}

exports.testSimpleArrow = function(test) {
  test.deepEqual(Tokenizer.tokenize("Mensch -> Hund: Hat"), ["Mensch", "->", "Hund", ":", "Hat"]);
  test.done();
}

exports.testWhitespaceIgnorant = function(test) {
  test.deepEqual(Tokenizer.tokenize("Mensch    -> Hund:   Hat"), ["Mensch", "->", "Hund", ":", "Hat"]);
  test.done();
}

exports.testWhitespaceMattersWithHyphens = function(test) {
  test.deepEqual(Tokenizer.tokenize("' Mensch'-> Hund:   Hat"), ["Mensch", "->", "Hund", ":", "Hat"]);
  test.done();
}

exports.testHyphensEscapeDelimiter = function(test) {
  test.deepEqual(Tokenizer.tokenize("'Mensch: '-> Hund:   Hat"), ["Mensch:", "->", "Hund", ":", "Hat"]);
  test.deepEqual(Tokenizer.tokenize("'Mensch -> '-> Hund: Hat"), ["Mensch ->", "->", "Hund", ":", "Hat"]);
  test.done();
}

exports.testSimpleArrowNoText = function(test) {
  test.deepEqual(Tokenizer.tokenize("Mensch -> Hund"), ["Mensch", "->", "Hund"]);
  test.done();
}

exports.testProcessString = function(test) {
  test.deepEqual(Tokenizer.tokenize("Mensch: Bla -> Hund:Bla"), ["Mensch", ":", "Bla", "->", "Hund", ":", "Bla"]);
  test.done();
}

exports.testProcessMultiLine = function(test) {
  test.deepEqual(Tokenizer.tokenize("Mensch -> Hund : Bla \n"+
        "Hund -> Mensch: Test"), ["Mensch", "->", "Hund", ":", "Bla", "\n", "Hund", "->", "Mensch", ":", "Test"]);
  test.done();
}

exports.testProcessStringOverSeveralLines = function(test) {
  test.deepEqual(Tokenizer.tokenize("Mensch: Bla -> \r\n"+
        " Hund:Bla"), ["Mensch", ":", "Bla", "->", "Hund", ":", "Bla"]);
  test.done();
}

exports.testOneSingleQuoteRemainsInBuffer = function(test) {
  test.deepEqual(Tokenizer.tokenize("A' -> B: C"), ["A'", "->", "B", ":", "C"]);
  test.deepEqual(Tokenizer.tokenize("A' -> B': C"), ["A'", "->", "B'", ":", "C"]);
  test.done();
}

exports.testTokenizerIsRobust = function(test) {
  test.deepEqual(Tokenizer.tokenize("Mensch -> Hund : asd\nHund"), ["Mensch", "->", "Hund", ":", "asd", "\n", "Hund"]);
  test.deepEqual(Tokenizer.tokenize("Mensch -> : Hund : asd\nHund"), ["Mensch", "->", "Hund", ":", "asd", "\n", "Hund"]);
  test.deepEqual(Tokenizer.tokenize("Mensch -> \n Hund : asd\nHund"), ["Mensch", "->", "Hund", ":", "asd", "\n", "Hund"]);
  test.done();
}

exports.testCanHandleLongProcessString = function(test) {
  test.deepEqual(Tokenizer.tokenize("A -> B\nA->B:Blabla\nB->A\nB:Test->A:Testaaa"), ["A", "->", "B", "\n", "A", "->", "B", ":", "Blabla", "\n", "B", "->", "A", "\n", "B", ":", "Test", "->", "A", ":", "Testaaa"]);
  test.done();
}
