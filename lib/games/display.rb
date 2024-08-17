module Games
  class Display
    HINTS = {
      correct: ' 🟢 ',
      partial: ' 🟡 ',
      wrong: ' 🔴 '
    }.freeze

    def bye
      puts 'Bye!'
    end

    def play(mode)
      puts "\n\nLet's play as a #{mode}."
    end

    def play_again?
      puts 'Do you want to play again? (y/n)'
    end

    def result(mode, is_winner, code)
      if is_winner
        puts "Yeah, you're the real #{mode}!"
      else
        puts "I'm sorry, you're not the real #{mode}. The code was: #{code}"
      end
    end

    def insert_code
      puts 'Enter a four digit number to make up your code:'
      puts 'All digits must be between 1 and 6.'

      print 'Code: '
    end

    def guess
      print 'Insert a code: '
    end

    def invalid_choice(choisable, choice)
      puts "Invalid #{choisable}: #{choice}"

      send(choisable)
    end

    def attempt(attempt, attempts, hints)
      puts "Attempt #{attempt} of #{attempts}"

      puts '  X   X   X   X   '

      hints_string = hints.map { |key, value| HINTS[key] * value }.join

      puts hints_string

      puts "\n\n"
    end

    def difficulty
      puts '1. Easy   - 12  attempts'
      puts '2. Medium -  8  attempts'
      puts '3. Hard   -  6  attempts'

      choice('difficulty')
    end

    def mode
      puts '1. Codebraker: Guess the correct code.'
      puts '2. Codemaker: Make up a code and the computer will guess it.'

      choice('mode')
    end

    def welcome
      puts 'Welcome to Mastermind'
    end

    private

    def choice(choisable)
      print "Choose a #{choisable}: "
    end
  end
end
