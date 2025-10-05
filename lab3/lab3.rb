require 'find'
require 'digest'
require 'json'

root = ARGV[0] || '.'             # каталог для сканування
output_file = 'duplicates.json'   

# Функція побайтного порівняння
def identical?(a, b)
  return false unless File.size(a) == File.size(b)
  File.open(a, 'rb') do |fa|
    File.open(b, 'rb') do |fb|
      until fa.eof?
        return false if fa.read(65536) != fb.read(65536)
      end
    end
  end
  true
end

# Збір усіх файлів
files = []
Find.find(root) do |path|
  next unless File.file?(path)
  files << { path: path, size: File.size(path) }
end

# Групировка за розміром
size_groups = files.group_by { |f| f[:size] }
size_groups.select! { |_, group| group.size > 1 }

# перевірка за хешем і побайтна перевірка
duplicates = []
size_groups.each do |size, group|
  hash_groups = group.group_by do |f|
    Digest::SHA256.file(f[:path]).hexdigest
  rescue
    nil
  end

  hash_groups.each do |hash, list|
    next if hash.nil? || list.size < 2

    # підтвердження дублікатів побайтно
    confirmed = []
    list.combination(2) do |f1, f2|
      if identical?(f1[:path], f2[:path])
        confirmed |= [f1[:path], f2[:path]]
      end
    end

    next if confirmed.size < 2

    duplicates << {
      size_bytes: size,
      saved_if_dedup_bytes: size * (confirmed.size - 1),
      files: confirmed.sort
    }
  end
end

report = {
  scanned_files: files.size,
  groups: duplicates
}

File.write(output_file, JSON.pretty_generate(report))
puts "Проскановано #{files.size} файлів, знайдено #{duplicates.size} груп дублікатів."
puts "Результат збережено у #{output_file}."
