
minutes = seconds.each { |sec| sec / 60 }
minutes.filter! { |min| min >= 15 }

Editor.configure do |config|
  config.enable_spell_check
  config.enable_line_numbering
  config.indent = 2
  config.syntax = :ruby
end

h = build_a_hash.tap do |h|
  h[:weekday] = :thursday
  h[:meeting] ||= 'Houston.pm'
end

counts = words.each_with_object(Hash.new(0)) do |word, h|
  h[word] += 1
end.tap do |cnts|
    stop_words.each { |word| cnts.delete word }
end
