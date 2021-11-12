# Encoding: UTF-8


class RelaxGame
  class EndPlayer < Chingu::GameObject
    def setup
      @image = Gosu::Image.new("#{RelaxGame::GAME_ROOT_PATH}/characters/knight_left.png")
    end
    def draw
      @image.draw_rot(@x, @y, 200, 90, 0.5, 0.5, 1.5, 1.5)
    end
  end


  #                                             #
  #                ENDING                       #
  #                                             #

  class Ending < Chingu::GameState
    trait :timer
    def setup
      Chingu::Text.destroy_all # destroy any previously existing Text, Player, EndPlayer, and Meteors
      Player.destroy_all
      self.input = { :esc => :close, [:enter, :return] => :next }

      @end_player = EndPlayer.create(:x => 300, :y => 110, :zorder => Z::PLAYER)

      $music = Gosu::Song.new("#{RelaxGame::GAME_ROOT_PATH}/audio/intro_song.ogg")
      $music.volume = 0.8
      $music.play(true)

      @living_room_image = Gosu::Image.new("#{RelaxGame::GAME_ROOT_PATH}/living_room.png")

      after(500) {
        @text = Chingu::Text.create("You win!", :y => 300, :font => "GeosansLight", :size => 45, :color => Colors::Dark_Orange, :zorder => Z::GUI)
        @text.x = 1100/2 - @text.width/2 # center text
        @text0 = Chingu::Text.create("You win!", :y => 300 + 3, :font => "GeosansLight", :size => 45, :color => Colors::Black, :zorder => Z::GUI - 1)
        @text0.x = 1100/2 - @text0.width/2 + 3 # center text

        after(500) {
          @text2 = Chingu::Text.create("Press ENTER to continue.", :y => 400, :font => "GeosansLight", :size => 45, :color => Colors::Dark_Orange, :zorder => Z::GUI)
          @text2.x = 1100/2 - @text2.width/2 # center text
          @text02 = Chingu::Text.create("Press ENTER to continue.", :y => 400 + 3, :font => "GeosansLight", :size => 45, :color => Colors::Black, :zorder => Z::GUI - 1)
          @text02.x = 1100/2 - @text2.width/2 + 3# center text
          after(500) {
  #          @end_player = EndPlayer.create(:x => 300, :y => 110, :zorder => Z::PLAYER)

          }
        }
      }

    end


    def next
      push_game_state(Introduction)
    end



    def draw
      @living_room_image.draw(0, 0, 0)    # Background Image: Raw Gosu Image.draw(x,y,zorder)-call
      super
    end
  end
end