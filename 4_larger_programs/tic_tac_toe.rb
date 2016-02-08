# tic_tac_toe.rb
require 'pry'

def prompt(input = '')
  puts input
end

def prompt_short(input = '')
  print input
end

def prompt_long(input = '')
  puts "#{input}\n\n"
end

def greeting
  prompt_long "Welcome to Tic-Tac-Toe! Let's go!"
end

def set_player_name
  loop do
    prompt_short "Please enter your name: "
    player_name = gets.chomp
    return player_name unless player_name.empty?
    prompt "Ooops, did you type anything?"
  end
end

def build_grid
  grid = {}
  (1..9).each { |space| grid[space.to_s] = ' ' }

  grid
end

def draw_board(grid)
  puts " #{grid['1']} | #{grid['2']} | #{grid['3']}"
  puts "---+---+---"
  puts " #{grid['4']} | #{grid['5']} | #{grid['6']}"
  puts "---+---+---"
  puts " #{grid['7']} | #{grid['8']} | #{grid['9']}\n\n"
end

def mark_board(board, marker, position)
  board[position.to_s] = marker
end

def marked_spaces(grid, player)
  grid.select { |_, marker| marker == player[:marker] }.keys
end

WIN = [['1', '2', '3'], ['4', '5', '6'], ['7', '8', '9'], ['1', '4', '7'], ['2', '5', '8'], ['3', '6', '9'], ['1', '5', '9'], ['3', '5', '7']]

def score(player, computer)
  "SCORE: #{player[:name]}: #{player[:score]};  #{computer[:name]}: #{computer[:score]}"
end

def show_game(board, player = {}, computer = {}, top_message = '', bottom_message = '')
  system 'clear'
  prompt score(player, computer)
  prompt_long top_message unless top_message.empty?
  draw_board(board)
  prompt_long "#{bottom_message}" unless bottom_message.empty?
end

def not_integer?(input)
  input.to_i != 0 && input.to_i != input.to_f
end

def valid_move?(grid, position, player, computer)
  if not_integer?(position)
    show_game(grid, player, computer, message_prompt_player_move(player, grid), error_invalid_choice)
    return false
  end

  true
end

def available_spaces(grid)
  grid.select { |_, marker| marker == ' ' }.keys
end

def available_move?(grid, position, player, computer)
  if available_spaces(grid).include?(position)
    return true
  end

  show_game(grid, player, computer, message_prompt_player_move(player, grid), error_invalid_choice)
  false
end

def player_mark_space(grid, player, computer)
  player_position = ''

  loop do
    prompt_short ": "
    player_position = gets.chomp.to_s
    next unless valid_move?(grid, player_position, player, computer)
    next unless available_move?(grid, player_position, player, computer)
    break
  end

  mark_board(grid, player[:marker], player_position)
end

def computer_best_option(grid)
  win_move = two_o_in_a_row(grid).sample.to_s
  defense_move = two_x_in_a_row(grid).sample.to_s
  beneficial_move = top_positions(grid).sample.to_s
  position = [win_move,
              defense_move,
              beneficial_move,
              available_spaces(grid).sample.to_s
             ].detect { |check| !check.empty? }

  position
end

def computer_mark_space(grid, computer_player)
  selected_space = computer_best_option(grid)
  mark_board(grid, computer_player[:marker], selected_space)
end

def win?(grid, player)
  WIN.any? do |winning_spaces|
    winning_spaces.take_while { |space| marked_spaces(grid, player).include?(space) }.length == 3
  end
end

def two_o_in_a_row(grid)
  choices = WIN.select do |line_of_3|
    grid.values_at(*line_of_3).count('O') == 2 && grid.values_at(*line_of_3).count('X') == 0
  end
  choices.flatten!
  choices.uniq!
  choices.keep_if { |choice| available_spaces(grid).include?(choice) }

  choices
end

def two_x_in_a_row(grid)
  choices = WIN.select do |line_of_3|
    grid.values_at(*line_of_3).count('X') == 2 && grid.values_at(*line_of_3).count('O') == 0
  end
  choices.flatten!
  choices.uniq!
  choices.keep_if { |choice| available_spaces(grid).include?(choice) }

  choices
end

def top_positions(grid)
  choices = WIN.select do |line_of_3|
    grid.values_at(*line_of_3).count('X') == 0 && grid.values_at(*line_of_3).count('O') == 1
  end.to_a
  choices.flatten!
  choices.uniq!
  choices.keep_if { |choice| available_spaces(grid).include?(choice) }

  available_spaces(grid).include?('5') ? ['5'] : choices
end

def error_invalid_choice
  "It doesn't look like you made a valid choice."
end

def grid_filled?(grid)
  !(grid.values.any? { |space| space == ' ' })
end

def somebody_won?(grid)
  markers_used = grid.values.uniq.select { |marker| marker != ' ' }

  markers_used.any? do |marker|
    WIN.any? do |line_of_3|
      grid.values_at(*line_of_3).count(marker) == 3
    end
  end
end

def who_won?(grid)
  return false unless somebody_won?(grid)

  markers_used = grid.values.uniq.select { |marker| marker != ' ' }
  winning_marker = markers_used.detect do |marker|
    WIN.any? do |line_of_3|
      grid.values_at(*line_of_3).count(marker) == 3
    end
  end

  winning_marker
end

def show_winner(grid, player, computer)
  if somebody_won?(grid)
    winner = [player, computer].select { |person| person[:marker] == who_won?(grid) }[0]
    winner[:score] += 1
    show_game(grid, player, computer, "#{winner[:name]} wins!")
  else
    prompt score(player, computer)
    show_game(grid, player, computer, "Nobody's a winner!")
  end
end

def message_begin
  "Let's go!"
end

def show_available_spaces(grid)
  options = available_spaces(grid)
  last_option = options.pop

  if options.empty?
    last_option
  else
    options.join(', ') + ' or ' + last_option
  end
end

def translate_start_options(selection)
  case selection
  when '1' then true
  when '2' then false
  when '3' then [true, false].sample
  end
end

def choose_start(player, computer)
  answer = nil
  until answer
    prompt_short "Who should start? #{player[:name]} (1), #{computer[:name]} (2) or Random (3)\n: "
    answer = gets.chomp
    break if ['1', '2', '3'].include?(answer)
    answer = nil
    prompt "Please choose 1, 2 or 3"
  end

  translate_start_options(answer)
end

def message_prompt_player_move(player, grid)
  "#{player[:name]}, please choose your move (#{show_available_spaces(grid)})."
end

def message_opponents_move(player)
  "#{player[:name]}'s turn."
end

def message_play_again?
  "Play again? (y/n)"
end

def message_goodbye(player)
  "Thanks for playing, #{player[:name]}! Goodbye."
end

# game_play
loop do
  system 'clear'
  prompt_long message_begin

  player = {}
  computer = {}

  player[:name] = set_player_name
  player[:marker] = 'X'

  computer[:name] = 'Computer'
  computer[:marker] = 'O'

  player[:score] = 0
  computer[:score] = 0

  player_starts = choose_start(player, computer)

  loop do
    system 'clear'

    active_board = build_grid

    loop do
      while player_starts
        prompt score(player, computer)
        show_game(active_board, player, computer, message_prompt_player_move(player, active_board))
        player_mark_space(active_board, player, computer)
        player_starts = nil
      end

      break if somebody_won?(active_board)
      break if grid_filled?(active_board)

      prompt score(player, computer)
      computer_mark_space(active_board, computer)
      show_game(active_board, player, computer, message_opponents_move(computer))

      break if somebody_won?(active_board)
      break if grid_filled?(active_board)

      player_starts = true
    end

    player_starts = if who_won?(active_board) == player[:marker]
                      true
                    elsif who_won?(active_board) == computer[:marker]
                      false
                    else [true, false].sample
                    end

    prompt score(player, computer)
    show_winner(active_board, player, computer)

    prompt message_play_again?
    break if gets.chomp.downcase != 'y'
  end

  prompt_long message_goodbye(player)
  break
end
