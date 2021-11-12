# Encoding: UTF-8
#                                             #
#                LEVEL 3                      #
#                                             #
class RelaxGame
  class Level3 < LivingRoom
    def initialize
      @num_toys = 20
      @num_kids = 6
      $chingu_window.caption = "                  ______ Level 3 ______"
      super
    end

    def next
      push_game_state(Level4)
    end

    def update
      super
      if @particles.length < 1
        puts "LEVEL 3 COMPLETE."
        push_game_state(Chingu::GameStates::FadeTo.new(Level4.new, :speed => 8))
      end
    end
  end
end