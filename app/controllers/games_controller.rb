# require 'pry-byebug'
require 'open-uri'
require 'json'

URL = 'https://wagon-dictionary.herokuapp.com/'

class GamesController < ApplicationController
  def initialize
    super
    @letters = (0...10).map { ('A'..'Z').to_a[rand(26)] }
  end

  def new
  end

  def score
    word = params['word']
    word_attempt = word.upcase.chars

    if repetead_letters?(word_attempt, number_of_letters(@letters)) || validate_letters?(@letters, word_attempt)
      @message = "Sorry but #{word} can't be built with #{@letters}"
    elsif validate_word?(word)
      @message = "Sorry but #{word} does not seem to be a valid English word"
    else
      @message = "Congratulations! #{word} is a valid English word"
    end
  end

  private

  # return hash with all the number of letters
  def number_of_letters(grid)
    number_of_letters = {}

    grid.each do |letter|
      if number_of_letters.key?(letter.to_sym)
        number_of_letters[letter.to_sym] += 1
      else
        number_of_letters[letter.to_sym] = 1
      end
    end

    number_of_letters
  end

  # return true if there are repetead letters
  def repetead_letters?(attempt, number_of_letters)
    repetead = false

    number_of_letters.each do |letter, number|
      next if number.nil?

      if attempt.count(letter.to_s) > number
        repetead = true
        break
      end
    end

    repetead
  end

  # return hash with the response from the API
  def get_from_api(word)
    json = URI.open("#{URL}#{word}").read

    JSON.parse(json)
  end

  # return true/false depending if the word exists in the dictionnary
  def validate_word?(word)
    validate = get_from_api(word)

    !validate['found']
  end

  # return the error from the API
  def get_error(word)
    error = get_from_api(word)

    error['error']
  end

  # return true if all the letters in the attempt are in the grid
  def validate_letters?(grid, attempt)
    validate = true

    attempt.each do |letter|
      if grid.count(letter).zero?
        validate = false
        break
      end
    end

    validate
  end
end
