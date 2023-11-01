class Node
  attr_accessor :left, :right, :data

  def initialize(data, left = nil, right = nil)
    @data = data
    @left = left
    @right = right
  end

  def leaf?
    @left.nil? && @right.nil?
  end
end

def build(frequencies) #построение дерева
  queue = frequencies.map { |char, freq| Node.new([char, freq]) }

  while queue.length > 1
    queue = queue.sort_by { |node| node.data[1] }
    left = queue.shift
    right = queue.shift
    merged = Node.new([left.data[0] + right.data[0], left.data[1] + right.data[1]], left, right)
    queue.unshift(merged)
  end

  queue[0]
end

def codes(tree, prefix = '') #кодовое представление для символов
  if tree.leaf?
    { tree.data[0] => { code: prefix, count: tree.data[1] } }
  else
    left_codes = codes(tree.left, prefix + '0')
    right_codes = codes(tree.right, prefix + '1')
    left_codes.merge(right_codes)
  end
end

def encode(text) #кодирование текста
  char_frequencies = text.each_char.with_object(Hash.new(0)) { |char, frequencies| frequencies[char] += 1 }
  huffman_tree = build(char_frequencies)
  huffman_codes = codes(huffman_tree)
  encoded_text = text.each_char.map { |char| huffman_codes[char][:code] }.join
  [encoded_text, huffman_tree, huffman_codes]
end

def decode(encoded_text, huffman_tree) #декодирование текста
  current_node = huffman_tree
  decoded_text = ''

  encoded_text.each_char do |bit|
    if bit == '0'
      current_node = current_node.left
    else
      current_node = current_node.right
    end

    if current_node.leaf?
      decoded_text += current_node.data[0]
      current_node = huffman_tree
    end
  end

  decoded_text
end

original = "The sizzling sausages sizzled in the skillet."
encoded, huffman_tree, huffman_codes = encode(original)
decoded = decode(encoded, huffman_tree)

puts "Исходный текст: #{original}"
puts "Закодированный текст: #{encoded}"
puts "Декодированный текст: #{decoded}"

puts "Размер исходного текста: #{original.size * 8} бит"
puts "Размер закодированного текста: #{encoded.size} бит"

huffman_codes.each do |char, data|
  puts "'#{char}' | #{data[:code]} | #{data[:count]}"
end
