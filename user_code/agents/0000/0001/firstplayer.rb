# an instance of FirstPlayer always selects the first available move
class FirstPlayer < AgentBase
  def get_ready
    @moves_hash = {}
  end
  def take_turn(reward=nil, is_terminal=false)
    @game.legal_moves(@moves_hash)  # what moves can I do?
    @game.do_move(@moves_hash.keys[0])  # arbitrarily do first possible move
  end
end
