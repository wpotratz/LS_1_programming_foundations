# twenty1.rb
require 'pry'

SUITS = { 'D' => 'Diamonds', 'C' => 'Clubs', 'S' => 'Spades', 'H' => 'Hearts' }
LABELS = ['2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A']
WINNING_TOTAL = 21
DEALER_MINIMUM = 17

def say(input)
  puts "=> #{input}"
end

def show_bank(money, bet = nil)
  puts "  Bank: #{show_currency(money)}"
  puts "  Your Wager: #{show_currency(bet)}" if bet
  puts "\n"
end

def to_dollars(amount)
  amount.to_i.to_s
end

def to_cents(amount)
  ((amount - amount.to_i).to_f.round(2).to_s + '00')[2..3]
end

def show_currency(number)
  dollars = to_dollars(number)
  # cents = to_cents(number)

  dollars = dollars.reverse.scan(/\d{1,3}/).join(',')

  # "$#{dollars.reverse}.#{cents}"
  "$#{dollars.reverse}"
end

def card_value(card)
  value = card_label(card)

  if value == 'A'
    1
  elsif %w(J Q K).include?(value)
    10
  else
    value.to_i
  end
end

def card_label(card)
  card[1]
end

def card_suit(card)
  card[0]
end

def card_full_suit(card)
  SUITS[card[0]]
end

def build_deck(number_of_decks = 1)
  deck_count = number_of_decks.to_i
  deck = []

  deck_count.times { deck += SUITS.keys.product(LABELS) }

  deck
end

def cards_to_show(cards, show_dealer = true)
  if show_dealer
    cards
  else
    cards[1..cards.size]
  end
end

def show_cards(hand, show_dealer = true)
  cards = cards_to_show(hand, show_dealer)

  puts "[ Hidden Card ]" unless show_dealer
  cards.each { |card| puts "[#{card_label(card)} of #{card_full_suit(card)}]" }
end

def deal_player(hand, deck, number_of_cards = 1)
  cards_dealt = []

  number_of_cards.times do
    new_card = deck.pop
    hand << new_card
    cards_dealt << new_card
  end

  cards_dealt
end

def ask_hit_or_stay
  loop do
    say 'Hit or Stay? (h/s)'
    answer = gets.chomp.downcase
    return answer if %w(h s).include?(answer)
    say 'Try that again...'
  end
end

def hand_total(player_cards, show_dealer = true)
  cards = cards_to_show(player_cards, show_dealer)
  total = cards.inject(0) { |sum, card| sum + card_value(card) }

  if cards.count { |card| card_label(card) == 'A' } > 0 && total + 10 <= 21
    # If there's an Ace in the hand && if the total of the hand with one Ace as 11 is under 21
    # You would never want more than one ace to be 11, so you will only ever add 10 once regardless of ace count
    total + 10
  else
    total
  end
end

def show_table(player_cards, dealer_cards, show_dealer = true)
  puts "_________________________\n"
  puts " Dealer's hand: #{hand_total(dealer_cards, show_dealer)}" + (show_dealer ? '' : ' + ?')
  show_cards(dealer_cards, show_dealer)
  puts "\n Your hand: #{hand_total(player_cards)}"
  show_cards(player_cards)
  puts "_________________________\n\n"
end

def bust?(hand)
  hand_total(hand) > WINNING_TOTAL
end

def black_jack?(hand)
  hand_total(hand) == WINNING_TOTAL
end

def dealer_hit_minimum(hand)
  hand_total(hand) >= DEALER_MINIMUM
end

def result(player_hand, dealer_hand)
  if black_jack?(player_hand)
    1
  elsif bust?(player_hand)
    2
  elsif black_jack?(dealer_hand)
    3
  elsif bust?(dealer_hand)
    4
  elsif dealer_hit_minimum(dealer_hand)
    if hand_total(player_hand) == hand_total(dealer_hand)
      5
    elsif hand_total(player_hand) > hand_total(dealer_hand)
      6
    else
      7
    end
  end
end

def result_message(result_id, player_hand, dealer_hand)
  case result_id
  when 1 then message = 'You have blackjack!'
  when 2 then message = 'You bust!'
  when 3 then message = 'Dealer has blackjack!'
  when 4 then message = 'Dealer busts!'
  when 5..7
    message = "Dealer has #{hand_total(dealer_hand)}, and you have #{hand_total(player_hand)}! "
    case result_id
    when 5 then message += "It's a push"
    when 6 then message += 'You win!'
    when 7 then message += 'Dealer wins.'
    end
  else
    message = nil
  end

  message
end

def game_summary(player, dealer)
  say "Dealer has #{hand_total(dealer)}, and you have #{hand_total(player)}!"
end

def valid_amount(input)
  # /(^\$?\d+\.?\d*$)|(^\$?\d*\.?\d+$)/.match(input)
  /^\$?\d+$/.match(input)
end

def play_again?
  answer = ''
  loop do
    say 'Play again? (y/n)'
    answer = gets.chomp.downcase
    break if %w(y n).include?(answer)
    say 'Try that again...'
  end

  !!(answer == 'y')
end

def reset?
  answer = ''
  loop do
    say 'Reset or Quit (r/q)'
    answer = gets.chomp.downcase
    break if %w(r q).include?(answer)
    say 'Try that again...'
  end

  !!(answer == 'r')
end

def get_wager(player_money)
  show_bank(player_money)
  say "You have #{show_currency(player_money)} to gamble away."
  loop do
    say "How much do you want to bet? (in whole dollars)"
    wager = gets.chomp
    return wager.to_f if valid_amount(wager) &&
                         wager.to_f <= player_money &&
                         wager.to_f == wager.to_f.magnitude
    say "That's not a valid wager."
  end
end

# BEGIN GAME
loop do
  system 'clear'
  # Initialize game
  player_money = 1000
  say "Let's play!\n"
  say "Hit >Enter< to continue..."
  gets.chomp

  loop do
    # Wagers
    system 'clear'

    wager = get_wager(player_money)
    player_money -= wager

    # Build deck and deal
    current_deck = build_deck(2)
    2.times { current_deck.shuffle! }

    player_hand = []
    dealer_hand = []

    deal_player(player_hand, current_deck, 2)
    deal_player(dealer_hand, current_deck, 2)

    system 'clear'
    show_bank(player_money, wager)
    show_table(player_hand, dealer_hand, false)

    loop do # dealing the cards
      # Player's turn
      break if black_jack?(player_hand) || bust?(player_hand)
      hit_or_stay = ''
      loop do
        hit_or_stay = ask_hit_or_stay
        break if hit_or_stay == 's'

        system 'clear'
        new_card = deal_player(player_hand, current_deck)
        show_bank(player_money, wager)
        show_table(player_hand, dealer_hand, false)
        say "You are dealt:"
        show_cards(new_card)
        puts ''
        break if black_jack?(player_hand) || bust?(player_hand)
      end

      break if black_jack?(player_hand) || bust?(player_hand)

      # Dealer's turn
      say "Dealer's turn. > Hit Enter to continue <" if !bust?(player_hand) && hand_total(player_hand) != 21
      gets.chomp
      system 'clear'
      show_bank(player_money, wager)
      show_table(player_hand, dealer_hand)

      loop do
        break if result(player_hand, dealer_hand)

        if dealer_hand.count == 2
          message = 'Dealer will take a card.'
        else
          message = 'Dealer will take another card.'
        end
        message += ' > Hit Enter to continue <'
        say message

        gets.chomp
        system 'clear'

        new_card = deal_player(dealer_hand, current_deck)

        show_bank(player_money, wager)
        show_table(player_hand, dealer_hand)
        show_cards(new_card)
      end
      break
    end # dealing the cards

    show_bank(player_money, wager)
    show_table(player_hand, dealer_hand)

    game_over_id = result(player_hand, dealer_hand)
    say result_message(game_over_id, player_hand, dealer_hand)

    if [1, 4, 6].include?(game_over_id)
      player_money += (wager * 2)
    elsif game_over_id == 5
      player_money += wager
    end

    puts "\n"

    if player_money > 0
      break unless play_again?
    else
      say "You're broke :("
      break
    end
  end

  next if reset?

  if player_money == 0
    say "Better luck next time!"
  elsif player_money < 0
    say "You owe me some money, buddy..."
  else
    say "Don't spend it all in one place!\n"
  end

  say "Goodbye...\n"
  break
end
