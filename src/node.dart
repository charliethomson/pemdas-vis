import 'dart:math';

enum NodeType {
  Value,
  Operator,
}

class Node {
  Node left, right;
  NodeType type;
  num value;
  OperatorType operatorType;
  
  Node.Value(this.value) {
    this.type = NodeType.Value;
  }

  Node.Operator(String c) {
    this.type = NodeType.Operator;

    this.operatorType = operatorTypeFromChar(c);
    if (this.operatorType == null) {
      throw("Unknown operator character: ${c}");
    }
  }

  num evaluate() {
    if (this.isValue) {
      return this.value;
    } else {
      switch (this.operatorType) {
        case OperatorType.Add:
          return this.left.evaluate() + this.right.evaluate();
        case OperatorType.Sub:
          return this.left.evaluate() - this.right.evaluate();
        case OperatorType.Div:
          return this.left.evaluate() / this.right.evaluate();
        case OperatorType.Mul:
          return this.left.evaluate() * this.right.evaluate();
        case OperatorType.Pow:
          return pow(this.left.evaluate(), this.right.evaluate());
      }
      // This should be unreachable
      throw("This shouldnt happen");
    }
  }

  void renderHtml() {
    // TODO: This :)
    if (this.isValue) {

    } else if (this.isOperator) {
      
    } else {

    }
  }

  bool get hasLeft => this.left != null;
  bool get hasRight => this.right != null;

  bool get isValue => this.type == NodeType.Value;
  bool get isOperator => this.type == NodeType.Operator;
}

enum OperatorType {
  Add,
  Sub,
  Mul,
  Div,
  Pow,
}

OperatorType operatorTypeFromChar(String c) {
  switch (c) {
    case "+":
      return OperatorType.Add;
    case "-":
      return OperatorType.Sub;
    case "*":
      return OperatorType.Mul;
    case "/":
      return OperatorType.Div;
    case "^":
      return OperatorType.Pow;
    default:
      return null;
  }
}