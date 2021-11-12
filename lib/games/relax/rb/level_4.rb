# Encoding: UTF-8
#                                             #
#                LEVEL 4                      #
#                                             #

class RelaxGame
  class Level4 < LivingRoom
    def initialize
      @num_toys = 50
      @num_kids = 8
      $chingu_window.caption = "                  ______ Level 4 ______"
      super
    end

    def next
      push_game_state(Level5)
    end

    def update
      super
      if @particles.length < 1
        puts "LEVEL 4 COMPLETE."
        push_game_state(Chingu::GameStates::FadeTo.new(Level5.new, :speed => 8))
      end
    end
  end
end