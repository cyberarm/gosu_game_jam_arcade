# Encoding: UTF-8
#                                             #
#                LEVEL 2                      #
#                                             #
class RelaxGame
  class Level2 < LivingRoom
    def initialize
      @num_toys = 10
      @num_kids = 4
      $chingu_window.caption = "                  ______ Level 2 ______"
      super
    end

    def next
      push_game_state(Level3)
    end

    def update
      super
      if @particles.length < 1
        puts "LEVEL 2 COMPLETE."
        push_game_state(Chingu::GameStates::FadeTo.new(Level3.new, :speed => 8))
      end
    end
  end
end