class Hangman
  attr_accessor :guess_count, :secret_word, :guess, :secret_display, :wrong_guesses, :game_over

  ### methods ###

  ## setup

  # load dictionary and randomly select word between 5 and 12 characters
  def load_secret_word
    @secret_word = File.readlines('5desk.txt').sample.downcase.strip
    until @secret_word.length > 5 && @secret_word.length < 12
      puts "Choosing secret word..."
      @secret_word = File.readlines('5desk.txt').sample.downcase.strip
    end
    @secret_display = %{#{"_" * @secret_word.length}} # change this to update based on previous guesses
  end

  # set initial guess count equal to 10
  def init_guess_count
    @guess_count = 12
  end


  ## game loop methods

  # show current guess count and secret_display
  def game_display
    puts "Guess progress: #{@secret_display}"
    puts "Wrong guesses: #{@wrong_guesses}"
    puts "Guesses remaining: #{@guess_count}"
  end

  # prompt player to guess and assign to @guess variable
  def get_player_guess(guess_message)
    puts guess_message
    @guess = gets.chomp.strip.downcase
    if @guess == "quit"
      exit
    end
    if @guess == @secret_word
      winner
    end
  end

  # split guess & secret_word, see if guess characters are
  def check_guess(guess, secret_word)
    matches = []
    secret_characters = secret_word.split(//)

    # loop to find matches & wrong letters
    if secret_characters.include? guess
      secret_characters.each_with_index do |char, index|
        if char.include? guess
          @secret_display[index] = char
        end
      end
    else
      @wrong_guesses << guess
      @guess_count -= 1
    end
  end

  def winner
    puts "You guessed the secret word: #{@secret_word}!"
    exit
  end

  def loser
    puts "You lost. The secret word was #{@secret_word}"
    exit
  end


  ## actually run the game

  def start
    load_secret_word
    init_guess_count
    @wrong_guesses = []
  end

  def turn
    game_display
    guess_message = "Enter your guess below. Guess one letter at a time unless you think you know the whole word."
    get_player_guess(guess_message)
    until @guess.length == 1
      guess_message = "Try again with only one letter this time."
      get_player_guess(guess_message)
    end
    until (@secret_display !~ /#{@guess}/) && (@wrong_guesses.join !~ /#{@guess}/)
      guess_message = "You already guessed that letter. Try again."
      get_player_guess(guess_message)
    end
    check_guess(@guess, @secret_word)
    if @secret_display == @secret_word
      winner
    end
  end

  def run
    until @guess_count == 0
      turn
    end
    loser
  end

end

@game = Hangman.new

@game.start
@game.run
