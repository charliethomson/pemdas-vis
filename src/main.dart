import 'dart:math';

enum Operator {
  Add,
  Sub,
  Mul,
  Div,
  Pow,
}

extension OperatorExtension on Operator {
  num evaluate(num a, b) {
    switch (this) {
      case Operator.Add:
        return a + b;
      case Operator.Sub:
        return a - b;
      case Operator.Mul:
        return a * b;
      case Operator.Div:
        return a / b;
      case Operator.Pow:
        return pow(a, b);
      default:
        return null;
    }
  }

  String symbol() {
    switch (this) {
      case Operator.Add:
        return "+";
      case Operator.Sub:
        return "-";
      case Operator.Mul:
        return "*";
      case Operator.Div:
        return "/";
      case Operator.Pow:
        return "^";
      default:
        return "idk how u did this";
    }
  }
}

Operator operatorFromString(String input) {
  switch (input) {
    case '+':
      return Operator.Add;
    case '-':
      return Operator.Sub;
    case '*':
      return Operator.Mul;
    case '/':
      return Operator.Div;
    case '^':
      return Operator.Pow;
    default:
      return null;
  }
}


class Node {
  
  Operator operator;
  num value;
  Node left, right;

  bool get isEndPoint => operator == null;

  Node(Operator operator) {
    this.operator = operator;
    this.left = null;
    this.right = null;
    this.value = null;
  }

  @override
  String toString() {
    if (this.isEndPoint) {
      return "Node value: ${this.value}";
    } else {
      return "Node ${this.left} ${this.operator.symbol()} ${this.right}";
    }
  }

  num evaluate() {
    if (this.isEndPoint) {
      return this.value;
    } else {
      // left and right exist
      if (this.right != null && this.left != null) {
        var left = this.left.evaluate();
        var right = this.right.evaluate();

        return this.operator.evaluate(left, right);
      } else {
        // only left
        if (this.left != null) {
          return this.left.evaluate();
        // only right
        } else if (this.right != null) {
          return this.right.evaluate();
        // neither, throw error
        } else {
          throw("cannot evaluate node ${this} with no left or right nodes");
        }
      }
    }
  }
}

enum TokenType {
  Number,
  Operator,
  Paren,
}

bool isNumeric(String input) {
  return input.split('').every((char) { return '0123456789.'.split('').contains(char); });
}

bool isOperator(String input) {
  return '+-/*^'.split('').contains(input);
}

bool isParen(String input) {
  return '()'.split('').contains(input);
}

TokenType tokenTypeFromString(String input) {
  if (isOperator(input)) {
    return TokenType.Operator;
  } else if (isNumeric(input)) {
    return TokenType.Number;
  } else if (isParen(input)) {
    return TokenType.Paren;
  } else {
    return null;
  }
}

class Token {
  String literal;
  TokenType type;
  
  Token(String literal) {
    this.literal = literal;
    this.type = tokenTypeFromString(literal);
    if (this.type == null) {
      throw("Could not get a proper token type from literal: '${literal}';");
    }
  }

  @override
  String toString() {
    return "${this.type} -> '${this.literal}';";
  }
} 

int precedence(Token t) {
  switch (operatorFromString(t.literal)) {
    case Operator.Add:
      return 2;
    case Operator.Sub:
      return 2;
    case Operator.Mul:
      return 3;
    case Operator.Div:
      return 3;
    case Operator.Pow:
      return 4;
    default:
      return 0;
  }
}

/// True -> right, False -> left
bool associativity(Token t) {
  return operatorFromString(t.literal) == Operator.Pow;
}

List<Token> tokenize(String string) {
  var clean_string = string
                      .split('')
                      .where((char) { return '+-/*^0123456789.()'.contains(char);})
                      .toList();
  List<Token> output = new List();
  StringBuffer buf = new StringBuffer();
  for (num i = 0; i < clean_string.length; i++) {
    String item = clean_string[i];
    // If the item is a number, add them to the buffer until it's no longer a number.
    if (isNumeric(item)) {
      buf.write(item);
    // If there is anything in the buffer (and we aren't on a number), it means we
    // just got off of a number, so add the buffer to the output and clear it.
    // We then have to go over this item again (because this iteration made us miss
    // the current item)
    } else if (buf.isNotEmpty) {
      output.add(Token(buf.toString()));
      buf.clear();
      i--;
    // If the item is a Paren or Operator, add it directly to the output and move forward
    } else if (isParen(item) || isOperator(item)) {
      output.add(Token(item));
    // This should be unreachable (we strip out unexpected characters)
    } else {
      throw("Unexpected character: '${item}'");
    }
  }

  // If the last token was a number, it won't be added because it'll be in the buffer, so
  // we need to check for that, here :)
  if (buf.isNotEmpty) {
    output.add(Token(buf.toString()));
  }

  return output;
}

List<Token> reverse_polish(String string) {
  var tokens = tokenize(string);
  List<Token> output = new List();
  List<Token> opstack = new List();

  for (Token token in tokens) {
    switch (token.type) {
      case TokenType.Number:
        output.add(token);
        continue;
      case TokenType.Operator:
        while (
          opstack.length != 0 &&
          ( 
            precedence(token) < precedence(opstack[opstack.length - 1])
            ||
            (precedence(token) == precedence(opstack[opstack.length - 1]) && !associativity(opstack[opstack.length - 1])))
            &&
            (opstack[opstack.length - 1].literal != '(')
          )
            {
              output.add(opstack.removeLast());
        }
        opstack.add(token);
        continue;
      case TokenType.Paren:
        switch (token.literal) {
          case '(':
            opstack.add(token);
            continue;
          case ')':
            while (opstack[opstack.length - 1].literal != '(') {
              if (opstack.length == 0) {
                throw("Mismatched parens!");
              } else {
                output.add(opstack.removeLast());
              }
            }
            opstack.removeLast();
        }
    }
  }

  while (opstack.isNotEmpty) {
    var top = opstack.removeLast();
    if ('()'.split('').contains(top)) {
      throw("Mismatched parens!");
    } else {
      output.add(top);
    }
  }
  return output;
}

class ExpressionTree {
  Node root;
  ExpressionTree(String string) {
    List<Node> stack = new List();
    for (Token token in reverse_polish(string)) {
      if (token.type == TokenType.Number) {
        var value = token.literal.contains('.') ? double.parse(token.literal) : int.parse(token.literal);
        Node n = new Node(null);
        n.value = value;
        stack.add(n);
      } else {
        Node a = new Node(operatorFromString(token.literal));
        a.right = stack.length != 0 ? stack.removeLast() : null;
        a.left = stack.length != 0 ? stack.removeLast() : null;
        stack.add(a);
      }
    }

    if (stack.length != 0) {
      this.root = stack.removeLast();
    } else {
      if (reverse_polish(string).length == 0) {
        throw("Don't pass empty strings cunt");
      } else {
        throw("unknown parsing error: stack empty");
      }
    }

  }
}

main() {
  // Node head = new Node(Operator.Mul);
  // Node a = new Node(Operator.Add);
  // Node b = new Node(Operator.Sub);
  // Node q = new Node(null);
  // Node w = new Node(null);
  // Node e = new Node(null);
  // Node r = new Node(null);
  // q.value = 10;
  // w.value = 15;
  // e.value = 45;
  // r.value = 22;
  
  // a.left = q;
  // a.right = w;
  // b.left = e;
  // b.right = r;

  // head.left = a;
  // head.right = b;

  // print(head);
  // print(head.evaluate());

  // print(tokenTypeFromString("Hello World!")); // null
  // print(tokenTypeFromString("+"));            // Operator
  // print(tokenTypeFromString("0011313"));      // Number
  // print(tokenTypeFromString("00103+031"));    // null
  // print(tokenTypeFromString("("));            // Paren
  // print(tokenTypeFromString("))9"));          // null

  // Node a = new Node(Operator.Add);
  // Node l = new Node(null);
  // l.value = 10;
  // a.left = l;
  // print(a.evaluate());


  var hard = '(9-3*4/6+3)/((8/4)^2+3*7-20)';
  var hard2 = '10*4-2*(4^2/4)/2/(1/2)+9';
  ExpressionTree tree = ExpressionTree(hard);
  print(tree.root.evaluate());
}
