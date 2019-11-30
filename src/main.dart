// import 'dart:html';

import 'lexer.dart';
import 'node.dart';

void tests() {
  // node_test() ? print("node tests: passed") : throw("node tests: failed");
  // node_test() ? print("node tests: passed") : throw("node tests: failed");
  // node_test() ? print("node tests: passed") : throw("node tests: failed");
  // node_test() ? print("node tests: passed") : throw("node tests: failed");
}

main() {
  tests();  
  // InputElement input = querySelector("#formula-input");
  // input.onChange.listen((_) => {
  //   // print(evaluate(input.value))
  // });
  Node a = new Node.Value(10);
  Node b = new Node.Value(15);
  Node o = new Node.Operator('*');
  o.left = a;
  o.right = b;
  print(o.evaluate());

  Node o2 = new Node.Operator('+');
  Node l2 = new Node.Value(33);
  o2.left = l2;
  o2.right = o;
  print(o2.evaluate());
} 

