
LAMBDA = '\\'
BODY_SEPARATOR = '.'
OPEN_PARAM = '('
CLOSE_PARAM = ')'
LEXEMS = [LAMBDA, BODY_SEPARATOR, OPEN_PARAM, CLOSE_PARAM]

class Token
  attr_reader :name

  def initialize(name)
    @name = name
  end

  def inspect
    "\"#{name}\""
  end
end

def tokenize(source)
  tokens = []
  token = ''
  source.split("").each do |character|
    if character =~ /\s/
      next if token == ''
      tokens << Token.new(token)
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

  tokens << Token.new(token) unless token.empty?
  tokens << Token.new(source) if tokens.empty?
  tokens
end

def reader(tokens)
  tree = []
  stack = []
  puts "tokens: #{tokens.inspect}"
  tokens.each do |token|
    if token == OPEN_PARAM
      list = []
      (stack.last || tree) << list
      stack.push(list)
    elsif token == CLOSE_PARAM
      stack.pop
    else
      (stack.last || tree) << token
    end
  end

  # ['do', tree].tap { |tree| puts "tree: #{tree.inspect}" }
  puts "tree: #{tree.inspect}"
  tree
end

# puts reader(tokenize('(\abc.abc qwe)x')).inspect
# puts reader(tokenize('f g h')).inspect
# puts tokenize('(\x.x) y').inspect
puts reader(tokenize('(\ true false and . and true false) (\ t f . t) (\ t f . f) (\ x y . x y false)')).inspect

