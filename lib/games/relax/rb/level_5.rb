# Encoding: UTF-8
#                                             #
#                LEVEL 5                      #
#                                             #

class RelaxGame
  class Level5 < LivingRoom
    def initialize
      @num_toys = 100
      @num_kids = 14
      $chingu_window.caption = "                  ______ Level 5 ______"
      super
    end

    def next
      push_game_state(Ending)
    end

    def update
      super
      if @particles.length < 1
        puts "YOU'VE WON!"
        push_game_state(Chingu::GameStates::FadeTo.new(Ending.new, :speed => 8))
      end
    end
  end
end