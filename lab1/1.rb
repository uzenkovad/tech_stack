def word_stats(text)
  words = text.split(" ")
  word_count = words.length

  longest = ""
  for w in words
    if w.length > longest.length
      longest = w
    end
  end

  unique = []
  for w in words
    lw = w.downcase
    if !unique.include?(lw)
      unique << lw
    end
  end
  unique_count = unique.length

  puts word_count.to_s + " слів, найдовше: " + longest + ", унікальних: " + unique_count.to_s
end

print "Введіть текст: "
text = gets.chomp

word_stats(text)
