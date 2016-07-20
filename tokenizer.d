import std.algorithm; // map
import std.array;     // (to)array



interface Tokenizer(Word, Token) {
	Token encode(Word  w);
	Word  decode(Token t);

	final:
	Token[] encode(ref const Word[]  ws){
		return ws.map!(w=>encode(w)).array;
	}
	Word[]  decode(ref const Token[] ts){
		return ts.map!(t=>decode(t)).array;
	}
}
