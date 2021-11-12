class GosuGameJamArcade
  class Window < Gosu::Permafrost
    def self.current_game
      @@current_game
    end

    def self.current_game=(game)
      @@current_game = game
    end

    def self.instance
      @@arcade_window
    end

    def initialize
      super(Gosu.screen_width, Gosu.screen_height, fullscreen: true)
      # super(1280, 720, fullscreen: true) # Test to fit @bestguigui's display

      @@current_game = GosuGameJamArcade::Interface.new(width: width, height: height)
      @@current_game.current_window = self

      @@arcade_window = self
    end

    def draw
      @@current_game&.draw
    end

    def update
      return unless @@current_game

      @@current_game.update

      self.width = @@current_game.width if @@current_game.width != self.width
      self.height = @@current_game.height if @@current_game.height != self.height
    end

    def button_down(id)
      @@current_game&.button_down(id)
    end

    def button_up(id)
      @@current_game&.button_up(id)
    end

    def needs_cursor?
        @@current_game&.needs_cursor?
    end

    def button_down?(id)
      @@current_game&.button_down?(id)
    end

    def close
      if @@current_game.is_a?(GosuGameJamArcade::Interface)
        close!

        return
      end

      Gosu::Song.current_song&.stop

      @@current_game = GosuGameJamArcade::Interface.new(width: Gosu.screen_width, height: Gosu.screen_height)
      @@current_game.current_window = self
    end
  end
end
