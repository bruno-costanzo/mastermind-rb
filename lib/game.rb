# frozen_string_literal: true

require_relative './games/display'
require 'debug'

class Game
  MODE = {
    '1' => :codebreaker,
    '2' => :codemaker
  }.freeze

  DIFFICULTY = {
    '1' => { name: :easy, attempts: 12 },
    '2' => { name: :medium, attempts: 8 },
    '3' => { name: :hard, attempts: 6 }
  }.freeze

  def initialize
    @mode = nil
    @difficulty = nil
    @code = nil
    @attempt = 0
  end

  def run
    setup
    play
    bye
  end

  private

  attr_reader :mode, :difficulty

  def bye
    display.bye
  end

  def setup
    display.welcome
    select :mode
    select :difficulty
  end

  def play
    loop do
      display.play(@mode)
      display.result(@mode, send(@mode), @code)
      display.play_again?

      break if gets.chomp == 'n'

      @attempt = 0
      @possible_combinations = nil
    end
  end

  def codemaker
    @code = insert_code
    guess = Array.new(4) { 0 }

    until @attempt == difficulty[:attempts]
      hints = hints guess

      return true if hints[:correct] == @code.size

      @attempt += 1

      display.attempt(@attempt, difficulty[:attempts], hints)

      guess = new_guess(hints, guess)

      puts "\n\n"

      puts "Code: #{@code}"
      puts "Guess: #{guess}"
      sleep 2
    end
  end

  def codebreaker
    @code = Array.new(4) { rand(1..6) }
    guess = Array.new(4) { 0 }

    until @attempt == difficulty[:attempts]
      hints = hints guess

      return true if hints[:correct] == @code.size

      @attempt += 1

      display.attempt(@attempt, difficulty[:attempts], hints)

      guess = new_guess
    end

    false
  end

  def insert_code
    loop do
      display.insert_code

      code = gets.chomp.chars.map(&:to_i)

      break code if valid_code?(code)

      display.invalid_choice 'code', code
    end
  end

  def new_guess(hints = nil, guess = nil)
    case @mode
    when :codemaker then computer_guess(hints, guess)
    when :codebreaker then human_guess
    end
  end

  def computer_guess(last_guess_hints, last_guess)
    return possible_combinations.sample if @attempt == 1

    @possible_combinations = possible_combinations.filter do |combination|
      combination_hints_against_guess = hints(combination, last_guess)

      (combination_hints_against_guess[:correct] == last_guess_hints[:correct]) &&
        (combination_hints_against_guess[:partial] == last_guess_hints[:partial]) &&
        (combination_hints_against_guess[:wrong] == last_guess_hints[:wrong])
    end

    @possible_combinations.sample
  end

  def possible_combinations
    @possible_combinations ||= (1..6).to_a.repeated_permutation(4).to_a
  end

  def human_guess
    return Array.new(4) { 0 } if @attempt.zero?

    display.guess

    loop do
      guess = gets.chomp.chars.map(&:to_i)

      break guess if valid_code?(guess)

      display.invalid_choice 'guess', guess
    end
  end

  def valid_code?(code)
    code.size == 4 && code.all? { |value| value.between?(1, 6) }
  end

  def hints(guess, code = @code)
    guess = guess.dup
    code = code.dup

    results = { correct: 0, partial: 0, wrong: 0 }

    # Check for exact matches
    code.each.with_index do |value, index|
      if value == guess[index]
        results[:correct] += 1
        code[index] = nil
        guess[index] = nil
      end
    end

    # Check for partial matches
    guess.each do |value|
      next if value.nil?

      if code.include?(value)
        results[:partial] += 1
        code[code.index(value)] = nil
      end
    end

    # Check for wrong matches
    results[:wrong] = code.size - results[:correct] - results[:partial]

    results
  end

  def select(selectable_name)
    current_value = instance_variable_get("@#{selectable_name}")

    return current_value unless current_value.nil?

    choice = loop do
      display.send(selectable_name)

      constant = self.class.const_get(selectable_name.upcase)

      player_selection = gets.chomp.to_s

      break constant[player_selection] if constant.key?(player_selection)

      display.invalid_choice selectable_name, player_selection
    end

    # Set the instance variable
    instance_variable_set("@#{selectable_name}", choice)
  end

  def display
    @display ||= Games::Display.new
  end
end

Game.new.run
