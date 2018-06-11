puts "hello world"
test_map = Hash.new

str1 = 'ramo1'
str2 = "ramo2"

test_map[str1] = "value1"
test_map[str2] = "value2"

puts "map = #{test_map}"
puts "getting... #{test_map[str1]}"
puts "getting... #{test_map[str2]}"

test_map.delete(str2)

puts "map = #{test_map}"
puts "getting... #{test_map[str1]}"
puts "getting... #{test_map[str2]}"