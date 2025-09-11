def play_game
  
  secret_number = rand(1..100)

  tries = 0

  puts "Спробуйте вгадати число від 1 до 100."

  loop do
    print "Введіть число: "
    player_guess = gets.to_i
    tries += 1

    if player_guess < secret_number
      puts "Більше"
    elsif player_guess > secret_number
      puts "Менше"
    else
      puts "Число вгадано! Було витрачено #{tries} спроб."
      break
    end
  end
end

play_game
