# Генерує всі прямокутники заданої площі
def possible_rectangles(data, size)
  rectangles = []
  data[0].size.downto(1) do |width|
    data.size.downto(1) do |height|
      rectangles << [width, height] if width * height == size
    end
  end
  rectangles
end

# Перевіряє, що позиція вільна у всіх шарах
def empty_position?(arr, y, x)
  arr.all? { |a| a[y][x].nil? }
end

# Знаходить першу вільну позицію для нового шматка
def get_empty_position(arr)
  width = arr[0][0].size
  height = arr[0].size
  (0...height).each do |y|
    (0...width).each do |x|
      return [y, x] if arr.all? { |b| b[y][x].nil? }
    end
  end
  nil
end

# Створює шар заданого розміру, якщо він містить рівно одну родзинку
def get_layer(arr, position, size, data)
  width, height = size
  y, x = position
  return nil if y + height > data.size || x + width > data[y].size

  layer = Array.new(data.size) { Array.new(data[0].size) }
  raisins = 0

  data.each_with_index do |row, yy|
    row.each_with_index do |column, xx|
      next unless yy.between?(y, y + height - 1) && xx.between?(x, x + width - 1)
      return nil unless empty_position?(arr, yy, xx)
      layer[yy][xx] = column
      raisins += 1 if column == 'o'
    end
  end

  return nil if raisins != 1
  layer
end

# Рекурсивний пошук усіх шматків торта
def search(raisins, arr, rectangles, data)
  return arr if raisins.zero?

  position = get_empty_position(arr)

  rectangles.each do |size|
    layer = get_layer(arr, position, size, data)
    next if layer.nil?
    arr << layer
    res = search(raisins - 1, arr, rectangles, data)
    return res unless res.nil?
    arr.pop
  end
  nil
end

# Формує фінальний результат у вигляді рядків
def extract(board)
  board[1..-1].map do |layer|
    layer.map(&:join).reject(&:empty?).join("\n")
  end
end

def cut(cake)
  raisins = cake.count('o')
  data = cake.each_line.map { |line| line.strip.split('') }
  cells = data.size * data[0].size
  return [] unless (cells % raisins).zero?

  result = search(
    raisins,
    [Array.new(data.size) { Array.new(data[0].size) }],
    possible_rectangles(data, cells / raisins),
    data
  )
  result ? extract(result) : []
end

puts "Введіть торт рядок за рядком (порожній рядок для завершення вводу):"

cake_lines = []
loop do
  line = gets.chomp
  break if line.empty?
  cake_lines << line
end

cake = cake_lines.join("\n")

result = cut(cake)

puts "\nРезультат:"
if result.empty?
  puts "Неможливо розрізати торт на рівні шматки з 1 родзинкою."
else
  result.each_with_index do |piece, index|
    puts "\nШматок #{index + 1}:"
    puts piece
  end
end

# приклади вводу

# ........
# ..o.....
# ...o....
# ........

# .o......
# ......o.
# ....o...
# ..o.....

# .o.o....  # тут повинно вивести, що розрізати неможливо
# ........
# ....o...
# ........
# .....o..

# .o......
# ..o.....
# ....o...
# ..o.....
# ....o...
# .o......
# ......o.
# ...o....
