# Encoding: UTF-8
#                                             #
#                LEVEL 1                      #
#                                             #
class RelaxGame
  class Level1 < LivingRoom
    def initialize
      @num_toys = 6
      @num_kids = 2
      $chingu_window.caption = "                  ______ Level 1 ______"

      super
    end

    def setup
      super
      Chingu::Text.destroy_all
      after(300) {
        @text1 = Chingu::Text.create("Put the stuff in the bin.", :y => 400, :font => "GeosansLight", :size => 45, :color => Colors::White, :zorder => 2000)
        @text1.x = 1100/2 - @text1.width/2 # center text
        @text2 = Chingu::Text.create("Put the stuff in the bin.", :y => 400 + 4, :font => "GeosansLight", :size => 45, :color => Gosu::Color::BLACK, :zorder => 1000)
        @text2.x = 1100/2 - @text2.width/2 + 4# center text
        after(3000) {
          Chingu::Text.destroy_all
        }
      }
    end

    def next
      push_game_state(Level2)
    end

    def update
      super
      if @particles.length < 1
        puts "LEVEL 1 COMPLETE."
        push_game_state(Chingu::GameStates::FadeTo.new(Level2.new, :speed => 8))
      end
    end
  end
end