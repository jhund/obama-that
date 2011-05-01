directory = ARGV[0]

w = 0
t = 0
Dir.new(directory).each do |f|
  next unless f =~ /.txt/
  
  f = File.read(directory + "/" + f)
  words = f.strip.downcase.split
  thats = words.select{ |w| w == "that" }
  w += words.size
  t += thats.size
  
  # puts [directory, "%.2f%" % (100 * thats.size.to_f / words.size)].join("\t")
  # puts [directory, thats.size, words.size].join("\t")
end

puts t
puts w