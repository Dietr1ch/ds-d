#!/usr/bin/env rdmd

struct Set(T) {

private:
  struct Set_DummyMapValue {}
  Set_DummyMapValue[T] elems;

public:
  void add(T t) {
    elems[t] = Set_DummyMapValue();
  }
  bool contains(T t) {
    return (t in elems) !is null;
  }
  bool remove(T t) {
    return elems.remove(t);
  }

  T[] toArray() {
    return elems.keys();
  }

  @property
  auto values() {
    return elems.byKey();
  }

  @property
  void rehash() {
    elems.rehash();
  }
  void clear() {
    elems.clear();
  }

  @property
  auto length() {
    return elems.length;
  }

  unittest {
    Set!string stringSet;
    assert(stringSet.length==0);

    stringSet.add("aoeu");
    assert(stringSet.length==1);
    assert(stringSet.contains("aoeu"));
    assert(!stringSet.contains("AOEU"));

    stringSet.add("snth");
    assert(stringSet.length==2);

    stringSet.remove("aoeu");
    assert(stringSet.length==1);

    stringSet.add("AOEU");
    assert(stringSet.length==2);

    stringSet.clear();
    assert(stringSet.length==0);
  }

}
