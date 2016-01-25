# ask the user for two numbers
# ask the user for an operation to perform
# perform the operation on the two numbers
# display the resulting number

require 'pry'
require 'yaml'

MESSAGES = YAML.load_file('calculator_messages.yml')

LANGUAGE = 'en'

def prompt(message)
  puts "=> #{message}"
end

def prompt_short(message)
  print "=> #{message}"
end

def messages(message, lang = LANGUAGE)
  MESSAGES[lang][message]
end

def valid_number?(input)
  number = input.to_s
  !/[^\d\.]/.match(number) && !/[\d]+[\.]+[\d]*[\.]+/.match(number)
end

def get_number_type(number)
  if /[.]/.match(number)
    number.to_f
  else
    number.to_i
  end
end

def invalid_number_message
  "That doesn't seem like a valid number."
end

def operation_to_message(operator)
  case operator
  when '1'
    "Adding"
  when '2'
    "Subtracting"
  when '3'
    "Multiplying"
  when '4'
    "Dividing"
  end
end

prompt messages 'welcome'
prompt_short messages 'get_name'
name = ''
loop do
  name = gets.chomp
  if name.empty?
    prompt messages 'check_name'
  else
    break
  end
end
prompt "#{messages 'greetings'} #{name} \n\n"

loop do
  number1 = ''
  number2 = ''

  loop do
    prompt_short messages 'request_first_number'
    number1 = gets.chomp
    if valid_number?(number1)
      number1 = get_number_type(number1)
      prompt "#{messages 'show_first_number'} #{number1}.\n\n"
      break
    else
      prompt invalid_number_message
    end
  end

  loop do
    prompt_short messages 'request_second_number'
    number2 = gets.chomp
    if valid_number?(number2)
      number2 = get_number_type(number2)
      prompt "#{messages 'show_second_number'} #{number2}.\n\n"
      break
    else
      prompt invalid_number_message
    end
  end

  prompt_short messages 'request_operator'
  operator = ''
  loop do
    operator = gets.chomp
    if %w(1 2 3 4).any? { |valid_entry| operator == valid_entry }
      break
    else
      prompt "Please choose 1, 2, 3 or 4."
    end
  end

  prompt "#{operation_to_message(operator)} #{number1} and #{number2}."

  result = case operator
           when '1'
             "#{number1} + #{number2} = #{number1 + number2}"
           when '2'
             "#{number1} - #{number2} = #{number1 - number2}"
           when '3'
             "#{number1} x #{number2} = #{number1 * number2}"
           when '4'
             begin
               if number1.to_f % number2.to_f != 0
                 "#{number1} / #{number2} = #{number1.to_f / number2.to_f}"
               else
                 "#{number1} / #{number2} = #{number1 / number2}"
               end
             rescue ZeroDivisionError
               messages 'zero_division_error_message'
             end
           end

  prompt "#{result}\n\n"

  prompt messages 'calculate_again?'
  break unless gets.chomp.downcase.start_with?('y')
end

prompt messages 'farewell'
