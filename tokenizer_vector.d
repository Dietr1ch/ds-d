import tokenizer;



class VectorTokenizer(Word) : Tokenizer!(Word, size_t) {
	Word[]       alphabet;
	size_t[Word] index;

	size_t encode(Word  w) {
		auto i = w in index;
		if(i)
			return (*i);

		auto t = alphabet.length;
		alphabet ~= w;
		return index[w] = t;
	}
	Word   decode(size_t i) {
		return alphabet[i];
	}
}
