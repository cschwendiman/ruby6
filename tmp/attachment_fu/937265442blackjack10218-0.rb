require 'gamebase.rb'  # REMOVE THIS LINE BEFORE UPLOADING

class Card
  attr_reader :rank, :suit, :value
  
  def initialize(value, suit)
    @value = value
    @suit = suit
    case value
      when (2..9): @rank = value.to_s
      when 10: @rank = 'T'
      when 11: @rank = 'J'
      when 12: @rank = 'Q'
      when 13: @rank = 'K'
      else @rank = 'A'
    end
  end
  
  def to_s
    @rank + @suit
  end
end
  
class Deck
  def initialize(no_of_decks=1)
    values = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13]
    suits = %w[h d s c]
    @cards = []
    no_of_decks.times do
      suits.each {|s| values.each {|v| @cards << Card.new(v, s)}}
    end
  end
  
  # O(n) algorithm for uniform distribution
  def shuffle!
    (1...@cards.length).each do |i|
      j = rand(i + 1)
      @cards[i], @cards[j] = @cards[j], @cards[i]
    end
    return self
  end
  
  def deal!
    return @cards.pop
  end
end

class Blackjack < GameBase
  def before_players_ready
    @min_turn_moves = @max_turn_moves = 1
    # initialize data structure to represent the dealt cards
    @player_cards = GameBase::SafeArray.new
    @dealer_cards = GameBase::SafeArray.new
    @state = GameBase::SafeArray.new
    @state[0] = @player_cards
    @state[1] = @dealer_cards
    @state_keys[:player_cards] = 0
    @state_keys[:dealer_cards] = 1
    # variables and Procs for tracking player and dealer sums as cards are dealt
    @player_sum = @dealer_sum = 0
    @player_ace = @dealer_ace = false
    @inc_player = lambda do|v| 
      @player_sum += v
      @player_ace = true if v == 1
    end
    @inc_dealer = lambda do |v| 
      @dealer_sum += v
      @dealer_ace = true if v == 1
    end
    # deal initial cards
    @deck = Deck.new(4)
    @deck.shuffle!
    @player_cards << deal_card(&@inc_player) 
    @dealer_cards << deal_card(&@inc_dealer)
    @player_cards << deal_card(&@inc_player)
    # check for a blackjack
    if best_sum(@player_sum, @player_ace) == 21
      @game_over = true
      @winner = :player
    else
      # dealer gets second card but doesn't reveal it
      @dealer_card2 = deal_card(&@inc_dealer)
      @winner = nil
    end
  end
  
  # helper method for dealing a card
  def deal_card
    card = @deck.deal!
    yield card.value < 10 ? card.value : 10
    return card.to_s
  end
  private :deal_card
  
  # helper method for scoring aces
  def best_sum(sum, ace)
    return sum + 10 if ace and sum < 12
    return sum
  end
  private :best_sum
  
  # treats moves as a hash, adding {move => description} pairs
  def legal_moves(moves)
    moves.clear if moves.length > 0
    moves[:hit] = 'take another card'
    moves[:stand] = 'take no more cards'
    @moves = moves unless @moves
    moves
  end
  
  # process player's moves
  def do_move(move)
    @turn_moves += 1
    # validate move
    err = GameBase::AgentMoveError
    raise err, 'Illegal move', caller unless @moves.key?(move)
    # update state
    case move
      when :hit
        @player_cards << deal_card(&@inc_player)
        if @player_sum > 21
          # player busts
          @winner = :dealer
          @game_over = true
        end
      when :stand
        # reveal dealer's second card
        @dealer_cards << @dealer_card2
        # dealer hits until sum is 17 or more
        while (dealer_sum = best_sum(@dealer_sum, @dealer_ace)) < 17
          @dealer_cards << deal_card(&@inc_dealer)
        end
        if dealer_sum > 21
          # dealer busts
          @winner = :player
        else
          # must compare dealer and winner sums to determine winner
          player_sum = best_sum(@player_sum, @player_ace)
          @winner = :dealer if dealer_sum > player_sum
          @winner = :player if dealer_sum < player_sum
        end
        @game_over = true
    end
    nil
  end

  # record the result of the game
  def after_players_shutdown(game_result, *agent_results)
    game_result.result = (@winner ? "#{@winner} wins" : 'push')
    win = (@winner == :player)
    agent_results[0].result = @winner ? (win ? 'win' : 'loss') : 'push'
    agent_results[0].won_game_bool = win
    Thread.current[:save_game] = @state.dup
  end
end

# REMOVE ALL THE FOLLOWING CODE BEFORE UPLOADING TO WEB-APP BUT KEEP FOR LOCAL TESTING
if __FILE__ == $0
  require 'firstplayer.rb'
  bj = Blackjack.new([FirstPlayer])
  bj.play_game
  gr = Thread.current[:result][0]
  e = gr.exception
  if e
    puts [e.class.to_s, e.message, gr.exception_backtrace]
  else
    puts "RESULTS: #{gr.result}", ''
    puts Thread.current[:result]
    cards = Thread.current[:save_game]
    puts '', "agent cards: #{cards[0].inspect}"
    puts "dealer cards: #{cards[1].inspect}"
  end
end