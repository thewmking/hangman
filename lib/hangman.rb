require 'yaml'

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
    puts " "
    puts " "
    puts "At any time, type 'save' to save and exit"
    puts "Guess progress: #{@secret_display}"
    puts "Wrong guesses: #{@wrong_guesses}"
    puts "Guesses remaining: #{@guess_count}"
  end

  # prompt player to guess and assign to @guess variable
  def get_player_guess(guess_message)
    puts guess_message
    @guess = gets.chomp.strip.downcase
    case
      when @guess == "quit"
        exit
      when @guess == @secret_word
        winner
      when @guess == "save"
        save
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

  ## load & save

  def save
    Dir.mkdir('save') unless Dir.exists?('save')
    puts "Enter a name for your save file"
    save_name = gets.chomp.downcase.strip
    File.open("./save/#{save_name}.yml", 'w') do |file|
      file.write(YAML::dump(self))
    end
    puts "Game saved"
    exit
  end

  def load
    puts "enter the filename [no .yml or similar file type extensions]"
    load_name  = gets.chomp.downcase.strip
    saved_game = YAML.load(File.open("./save/#{load_name}.yml", 'r'))
    puts "Game loaded!"
    @game = saved_game
    @game.run
  end


  ## actually run the game

  def start
    puts "Load game or start new?"
    puts "Type 'load' to load a previous save, or type 'new' to start a new game."
    game_type = gets.chomp.downcase.strip
    if game_type == "load"
      load
    elsif game_type == "new"
      load_secret_word
      init_guess_count
      @wrong_guesses = []
    else
      start
    end
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
