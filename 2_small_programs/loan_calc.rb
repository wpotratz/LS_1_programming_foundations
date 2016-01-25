require 'pry'

def prompt_short(message = '')
  print "=> #{message}"
end

def prompt(message = '')
  puts "=> #{message}"
end

def prompt_long(message = '')
  puts "=> #{message}\n\n"
end

def prompt_input(message = '')
  print ": #{message}"
end

def set_name
  name = ''
  loop do
    name = gets.chomp
    if name.empty?
      prompt_short "Sorry, I'm missing your name: "
    else
      break
    end
  end

  name
end

introduction = <<-MSG
  The loan calculator will determine the amount you will pay each month,
  based on the details of your loan.

  You will need to know the total amount of your loan, the length of time you
  have to pay the loan off, and the APR (annual percentage rate) of the
  loan.

  If you have all of this information, we can get started!

  Would you like to begin? (y/n)
  :
MSG

def validate_loan_entry(amount)
  /(^\$?\d+\.?\d*$)|(^\$?\d*\.?\d+$)/.match(amount)
end

def float?(number)
  number.to_f != number.to_i
end

def to_dollars(amount)
  amount.to_i.to_s.reverse
end

def to_cents(amount)
  ((amount - amount.to_i).to_f.round(2).to_s + '00')[2..3]
end

def show_currency(number)
  dollars = to_dollars(number)
  cents = to_cents(number)
  digit_index = 3

  ((dollars.length - 1) / 3).times do
    dollars.insert(digit_index, ',')
    digit_index += 4
  end

  "$#{dollars.reverse}.#{cents}"
end

def set_loan_amount
  amount_entry = ''
  loop do
    prompt_input "$"
    amount_entry = gets.chomp
    break if validate_loan_entry(amount_entry)
    prompt "That doesn't seem like a valid amount. \nMake sure you enter just numbers."
  end
  amount = /\d+\.?\d*$/.match(amount_entry).to_s.to_f
  float?(amount) ? amount.to_f : amount.to_i
end

LOAN_DURATION_INSTRUCTIONS = <<-MSG
Please enter the duration of the loan.
Enter the amount, and then 'month(s)' or 'year(s)' appropriately.
It must be in increments of 1 month. ex) 18 months, 1 year, 2.5 years
MSG

BAD_DURATION_FORMAT_MESSAGE = <<-MSG
That doesn't look right.
Make sure to specify years/months and that it can be represented in whole months.
MSG

BAD_DURATION_AMOUNT_MESSAGE = "Looks like that's wrong. Does that work out to a whole number of months?"

def duration_to_months(duration)
  amount = duration.downcase.split(" ").to_a.first.strip
  unit = duration.downcase.split(" ").to_a.last

  if unit.start_with?('year')
    amount.to_f * 12
  elsif unit.start_with?('month')
    amount.to_f
  else
    false
  end
end

def to_whole_months(number)
  if number == number.to_i
    number.to_i
  else
    false
  end
end

def convert_duration_entry_to_month(entry)
  duration_in_months = duration_to_months(entry)

  unless duration_in_months && to_whole_months(duration_in_months)
    prompt BAD_DURATION_AMOUNT_MESSAGE
    prompt_input
    return false
  end
  to_whole_months(duration_in_months)
end

def validate_duration_format(duration)
  unless /^\d*\.?\d*\s(months?$|years?$)/.match(duration.downcase)
    prompt BAD_DURATION_FORMAT_MESSAGE
    prompt_input
    return false
  end

  duration.downcase
end

def set_loan_duration
  duration_in_whole_months = nil
  until duration_in_whole_months
    duration = gets.chomp
    duration_valid_format = validate_duration_format(duration)
    next unless duration_valid_format
    duration_in_whole_months = convert_duration_entry_to_month(duration_valid_format)
    next unless duration_in_whole_months
  end
  duration_in_whole_months
end

def set_apr
  apr = ''
  loop do
    prompt_short "Please enter the APR for this loan: "
    apr = gets.chomp
    break if /(^\d+\.?\d*%?$)|(^\d*\.?\d+%?$)/.match(apr)
    prompt "That doesn't look right. Make sure you're entering the numeric percentage."
  end
  apr_clean = /\d*\.?\d*/.match(apr).to_s.to_f
  monthly_rate = (apr_clean / 12)

  monthly_rate
end

def calculate_monthly_payment_amount(amount, months, rate)
  amount = amount.to_f
  months = months.to_f
  rate = (rate / 100).to_f
  (amount * (rate * (1 + rate)**months)) / (((1 + rate)**months) - 1)
end

def month_plural?(months)
  months > 1 ? 'months' : 'month'
end

# START!

system 'clear'
prompt_short "Welcome to the loan payment calculator!\nWhat's your name?: "
user_name = set_name
prompt "Hello, #{user_name}"
prompt_short introduction.strip
continue = gets.chomp

loop do # Main Loop
  if continue.downcase != 'y'
    prompt "That's ok, come back when you're ready...\nGoodbye!"
    break
  else
    system 'clear'
    prompt "Ok, #{user_name}, here we go!"
  end

  prompt "Please enter the total amount of your loan."
  loan_amount = set_loan_amount
  prompt_long "Alright, thanks."

  prompt LOAN_DURATION_INSTRUCTIONS.strip
  prompt_input
  loan_duration = set_loan_duration
  prompt_long "Thanks, so the total loan duration will be #{loan_duration} #{month_plural?(loan_duration)}"

  monthly_interest = set_apr
  prompt_long "Got it."

  monthly_payment = calculate_monthly_payment_amount(loan_amount, loan_duration, monthly_interest)

  prompt_long "Alright, based on the data you provided..."
  summary1 = "Your #{loan_duration} month, #{show_currency(loan_amount)} loan, with an APR of #{(monthly_interest * 12).round(3)}%,"
  summary2 = "will require monthly payments of #{show_currency(monthly_payment)}"
  puts "#{summary1} #{summary2}\n\n"
  puts "_________________________________\n\n"

  prompt "Would you like to calculate another loan? (y/n)"
  if gets.chomp.downcase != 'y'
    prompt_long "Thanks for using the loan calculator!"
    break
  end
end
