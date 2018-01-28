
LAMBDA = '\\'
BODY_SEPARATOR = '.'
OPEN_PARAN = '('
CLOSE_PARAN = ')'
LEXEMS = [LAMBDA, BODY_SEPARATOR, OPEN_PARAN, CLOSE_PARAN]

def tokenize(source)
  tokens = []
  token = ''
  source.split("").each do |character|
    if character =~ /\s/
      next if token == ''
      tokens << token
      token = ''
    else
      if LEXEMS.include?(character)
        tokens << token unless token == ''
        tokens << character
        token = ''
      else
        token << character
      end
    end
  end

  tokens << token unless token.empty?
  tokens << source if tokens.empty?
  tokens
end

def reader(tokens)
  tree = []
  stack = []
  # puts "tokens: #{tokens.inspect}"
  tokens.each do |token|
    if token == OPEN_PARAN
      list = []
      (stack.last || tree) << list
      stack.push(list)
    elsif token == CLOSE_PARAN
      stack.pop
    else
      (stack.last || tree) << token
    end
  end

  tree
end

def abstraction?(exp)
  exp[0] == LAMBDA
end

def lambda_variable(exp)
  exp[1]
end

def lambda_body(exp)
  exp[(exp.index(BODY_SEPARATOR)+1)..-1]
end

def substitute(variable:, body:, argument:)
  # puts "variable: #{variable.inspect}"
  # puts "body: #{body.inspect}"
  # puts "argument: #{argument.inspect}"
  body.map do |term|
    if term.is_a? Array
      substitute(variable: variable, body: term, argument: argument)
    elsif term == variable
      argument
    else
      term
    end
  end
end

def find_redex_index(exp)
  return nil if exp.length <= 1

  abstraction_index = exp.index { |term| abstraction?(term) }
  return nil if abstraction_index == exp.length - 1

  abstraction_index
end

def eval(exp)
  # puts "expression: #{exp.inspect}"
  print "expression\t\t: "; print_lambda(exp)

  while (redex_index = find_redex_index(exp))
    print "redex\t\t\t: "; print_lambda([exp[redex_index], exp[redex_index + 1]])

    lambda = exp[redex_index]
    print "lambda\t\t\t: "; print_lambda(lambda)

    argument = exp[redex_index + 1]
    print "argument\t\t: "; print_lambda(argument)

    substitution = substitute(
      variable: lambda_variable(lambda),
      body: lambda_body(lambda),
      argument: argument
    )
    print "substitution\t: "; print_lambda(substitution)

    if exp.length == 2
      exp = substitution
    else
      exp[redex_index] = substitution
      exp.delete_at(redex_index + 1)
    end

    print "reduction step\t: "; print_lambda(exp)
    # puts "reduction step\t: #{exp.inspect}"
  end
end

def print_expression(exp)
  if exp.is_a? Array
    print OPEN_PARAN
    exp.each_with_index do |sub_exp, i|
      print ' ' unless i == 0 || i == exp.length
      print_expression(sub_exp)
    end
    print CLOSE_PARAN
  else
    print exp == LAMBDA ? 'λ' : exp
  end
end

def print_lambda(exp)
  print_expression(exp)
  puts
end

# puts reader(tokenize('(\abc.abc qwe)x')).inspect
# puts reader(tokenize('f g h')).inspect
# puts reader(tokenize('(\x.x) y')).inspect
# puts eval(reader(tokenize('(\x.x) y'))).inspect

print_lambda(eval(reader(tokenize('(\true . \false . (\and . and true true) (\x . \y . x y false)) (\t . \f . t) (\t . \f . f)'))))

# print_lambda(eval(reader(tokenize('(\x.x)y'))))


