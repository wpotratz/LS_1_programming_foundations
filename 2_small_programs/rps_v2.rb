# rps.rb
require 'pry'

# VALID_CHOICES = { choice_name => [[primary abbrev options, ...other abbrev options], %w(killable opponent choices)]
VALID_CHOICES = { 'lizard' => { input: %w(l li liz liza lizar), 
                                defeats: %w(paper spock) }, 
                  'rock' => { input: %w(r ro roc), 
                              defeats: %w(lizard scissors) }, 
                  'paper' => { input: %w(p pa pap pape), 
                               defeats: %w(rock spock) }, 
                  'scissors' => { input: %w(sc sci scis sciss scisso scissor), 
                                  defeats: %w(paper lizard) }, 
                  'spock' => { input: %w(sp spo spoc), 
                               defeats: %w(rock scissors) }
                }
INVALID_CHOICES = ['s']
POINTS_TO_WIN = 5

def choice_abbreviation(choice_name)
  VALID_CHOICES[choice_name][:input].first
end

def list_valid_choices
  VALID_CHOICES.keys.collect do |choice|
    choice.capitalize + '(' + choice_abbreviation(choice) + ')'
  end.join(', ')
end

def prompt(message)
  puts "\n=> #{message}"
end

def prompt_short(message)
  puts "=> #{message}"
end

def show(choice)
  choice.capitalize
end

def prompt_player_name
  loop do
    prompt "What's your name?"
    player_name = gets.chomp
    return player_name unless player_name.empty?
    prompt "Looks like you didn't type anything..."
  end
end

def get_player_choice(player_name)
  loop do
    prompt "#{player_name}, choose one: #{list_valid_choices}"
    player_choice = gets.chomp.downcase
    valid_choice = standardize_choice(player_choice)
    return valid_choice if valid_choice
    prompt "That's not a valid choice."
  end
end

def standardize_choice(player_choice)
  return nil if INVALID_CHOICES.include?(player_choice)
  
  valid_choices = VALID_CHOICES.keys
  valid_choice = valid_choices.detect { |choice| choice.match player_choice }
  return valid_choice if valid_choice
  nil
end

def results(player_choice, opponent_choice, player_name, opponent_name)
  if player_choice == opponent_choice
    "It's a tie!"
  elsif win_round?(player_choice, opponent_choice)
    "#{player_name} wins!"
  else
    "#{opponent_name} wins."
  end
end

def win_round?(player_choice, opponent_choice)
  VALID_CHOICES.any? do |choice, choice_attributes|
    choice == player_choice && choice_attributes[:defeats].include?(opponent_choice)
  end
end

def game_over?(player_tally, opponent_tally)
  [player_tally, opponent_tally].any? { |player| player.to_i >= POINTS_TO_WIN }
end

# START GAME!

prompt "Welcome to Paper, Rock, Scissors\n\n"

player_name = prompt_player_name
opponent_name = 'Computer'

player_points = 0
opponent_points = 0

loop do
  prompt "THE SCORE IS: #{player_name} #{player_points}; #{opponent_name} #{opponent_points}"

  player_choice = get_player_choice(player_name)
  opponent_choice = VALID_CHOICES.keys.sample

  prompt "#{player_name} chose #{show player_choice}; #{opponent_name} chose #{show opponent_choice}."
  prompt_short results(player_choice, opponent_choice, player_name, opponent_name)

  if win_round?(player_choice, opponent_choice)
    player_points += 1
  elsif win_round?(opponent_choice, player_choice)
    opponent_points += 1
  end

  if game_over?(player_points, opponent_points)
    case POINTS_TO_WIN
    when player_points
      prompt_short "#{player_name} won the game!"
    when opponent_points
      prompt_short "#{opponent_name} won the game."
    end

    player_points = 0
    opponent_points = 0

    prompt "Play another game? (y/n)"
  else
    prompt "Go again? (y/n)"
  end

  break if gets.chomp.downcase != 'y'
end

prompt "Thanks for playing! Goodbye."
