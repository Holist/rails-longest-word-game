class WordsController < ApplicationController
  def game
    @grid = generate_grid
  end

  def score
    @attempt = params[:attempt]
    @start_time = params[:time].to_i
    @grid = params[:grid].split('')
    @run_game = run_game
  end

private

  def current_user
    @_current_user ||= session[:current_user_id] &&
    User.find_by(id: session[:current_user_id])
  end

  def generate_grid
    Array.new((8..12).to_a.sample) { ('A'..'Z').to_a.sample }
  end

  def run_game
    end_time = Time.now.to_i
    result = { time: end_time - @start_time }
    score_and_message = score_and_message(@attempt, @grid, result[:time])
    result[:score] = score_and_message.first
    result[:message] = score_and_message.last
    result
  end

  def score_and_message(attempt, grid, time)
    if included?(attempt.upcase, grid)
      if english_word?(attempt)
        score = compute_score(attempt, time)
        [score, "well done"]
      else
        [0, "not an english word"]
      end
    else
      [0, "not in the grid"]
    end
  end

  def included?(guess, grid)
    guess.chars.all? { |letter| guess.count(letter) <= grid.count(letter) }
  end

  def compute_score(attempt, time_taken)
    time_taken > 60.0 ? 0 : attempt.size * (1.0 - time_taken / 60.0)
  end

  def english_word?(word)
    response = open("https://wagon-dictionary.herokuapp.com/#{word}")
    json = JSON.parse(response.read)
    return json['found']
  end

end
