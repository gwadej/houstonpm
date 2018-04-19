class Example
  attr_reader :name

  def initialize name
    @name = name
  end

  def greet
    puts "Hello, #{name}"
  end

  def do_with_name
    yield name
  rescue => e
    puts "Tried to do with name and failed: #{e.message}"
  end
end
