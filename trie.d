import tokenizer : Tokenizer;
import tokenizer_vector : VectorTokenizer;

import std.stdio;     // I/O
import std.typecons;  // Nullable
import std.algorithm; // map
import std.array;     // split, (to)array



class TrieNode(Data, Word) {
	Nullable!Data data;
	TrieNode[Word] children;

	const Word word;
	const size_t depth;
	const TrieNode!(Data,Word) parent;

	/**
	 * Only for creating the root
	 */
	this() {
		parent = null;
		depth = 0;
		word = Word.init;
	}
	this(TrieNode p, Word w) {
		assert(p);
		parent = p;
		depth = parent.depth+1;
		word = w;
	}

	nothrow
	bool put(const Word[] path, Data d, size_t i=0) {
		if(path.length==i) {
			// Update leaf
			bool r = data.isNull;
			data = d;
			return r;
		}

		// Look for leaf
		auto w = path[i];
		auto cn = w in children;
		if(cn)  // Inside subtree
			return (*cn).put(path, d, i+1);
		else {  // On new subtree
			auto c = new TrieNode!(Data, Word)(this, w);
			children[w] = c;
			return c.put(path, d, i+1);
		}
	}

	nothrow const
	auto getNode(const Word[] path, size_t i=0) {
		if(path.length==i)
			return this;

		// Look for leaf
		auto cn = path[i] in children;
		if(cn)
			return (*cn).getNode(path, i+1);

		// Not here =/
		return null;
	}

	nothrow const
	Nullable!Data get(const Word[] path, size_t i=0) {
		auto n = getNode(path, i);
		if(n)
			return n.data;
		return Nullable!Data.init;
	}

	nothrow const
	Word[] path() {
		Word[] p;
		return path(p);
	}

	nothrow const
	Word[] path(Word[] pre) {
		if(parent)
			return path(word ~ pre);
		return pre;
	}

	const
	void print(string indent="", bool lastChild=true) {
		// Print tree indent
		string branch = lastChild ? "┕━" : "┝━";
		writef("%s%s `%s`", indent, branch, word);

		// Print data
		if(!data.isNull)
			writef(": '%s'", data);
		writef("\n");

		// Print children
		string newIndent = indent ~ (lastChild ? "  " : "│ ");
		auto i=0;
		auto lastIndex = children.length;
		foreach(c; children)
			c.print(newIndent, ++i==lastIndex);
	}

}



class Trie(Data, Word) {
	TrieNode!(Data, Word) _root;
	size_t _length;

	this() {
		_root = new TrieNode!(Data, Word);
		_length = 0;
	}


	//TODO slice assignment
	//int opIndexAssign(int v, size_t[2] x);  // overloads a[i .. j] = v
	//int[2] opSlice(size_t x, size_t y);     // overloads i .. j

	nothrow
	auto put(const Word[] path, Data d) {
		auto r = _root.put(path, d, 0);
		if (r)
			_length++;
		return r;
	}
	nothrow const
	auto get(const Word[] path) {
		return _root.get(path);
	}

	const
	void print() {
		writef("Trie |%s|:\n", _length);
		auto i=0;
		auto lastIndex = _root.children.length;
		foreach(n; _root.children)
			n.print("", ++i==lastIndex);
	}

	@property nothrow pure
	auto length() {
		return _length;
	}


	unittest {
		auto _trie = new Trie!(string, string);
		assert(_trie.length()==0);
		assert(_trie.get(["http:"]).isNull);
		assert(_trie.length()==0);

		_trie.put(["http:", "", "doge.ing.puc.cl"], "aoeu");
		assert(_trie.get(["http:", "", "doge.ing.puc.cl"])=="aoeu");

		_trie.put(["http:", "", "forum.dlang.org"], "htns");
		assert(_trie.get(["http:", "", "forum.dlang.org"])=="htns");

		assert(_trie.get(["http:"]).isNull);
	}
}



class TokenizedTrie(
	Data,
	Word, Token,
	Compressor: Tokenizer!(Word, Token)
	) : Trie!(Data, Token) {
	Compressor c;

	this() {
		c = new Compressor();
	}
	this(Compressor compressor) {
		c = compressor;
	}

	bool put(const Word[] path, Data d) {
		Token[] tokenPath = path.map!(w => c.encode(w)).array;
		return Trie!(Data, Token).put(tokenPath, d);
	}

	Nullable!Data get(const Word[] path) {
		Token[] tokenPath = path.map!(w => c.encode(w)).array;
		return Trie!(Data, Token).get(tokenPath);
	}


	unittest {
		auto tTrie = new TokenizedTrie!(string, string, size_t, VectorTokenizer!(string));
		tTrie.put(["http:", "", "doge.ing.puc.cl"], "aoeu");
		tTrie.put(["http:", "", "forum.dlang.org"], "htns");
	}
}



class IriTrie(
	Data
	) : TokenizedTrie!(Data,  string, size_t, VectorTokenizer!(string)) {
	bool put(const string iri, Data d) {
		return TokenizedTrie!(Data, string, size_t, VectorTokenizer!(string)).put(iriSplit(iri), d);
	}

	Nullable!Data get(const string iri) {
		return TokenizedTrie!(Data, string, size_t, VectorTokenizer!(string)).get(iriSplit(iri));
	}

	string[] iriSplit(const string iri) {
		return iri.split('/');
	}


	unittest {
		auto iriTrie = new IriTrie!(string);
		iriTrie.put("http://doge.ing.puc.cl", "aoeu");
		iriTrie.put("http://forum.dlang.org", "htns");
		assert(iriTrie.get("http://doge.ing.puc.cl") == "aoeu");
		assert(iriTrie.get("http://forum.dlang.org") == "htns");
	}
}
