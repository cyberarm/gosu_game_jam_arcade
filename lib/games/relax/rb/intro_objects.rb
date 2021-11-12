
class RelaxGame

  #
  #  KNIGHT
  #
  class Knight < Chingu::GameObject
    def initialize(options)
      super
      @image = Gosu::Image.new("#{RelaxGame::GAME_ROOT_PATH}/assets/characters/knight.png")
      @voice = Gosu::Sound.new("#{RelaxGame::GAME_ROOT_PATH}/assets/audio/mumble.ogg")
      @velox = 0     # x velocity starts as 0
      @veloy = 0     # y velocity starts as 0
      @factoring = 1 # used for shrinking Knight when he enters the ship
    end
    def movement   # called in Introduction gamestate
      @velox = -9  # move left
    end
    def enter_ship # called in Introduction gamestate
      @veloy = 2
      @factoring = 0.98
    end
    def speak      # called in Introduction gamestate
      @voice.play
    end
    def update
      self.factor *= @factoring
      @x += @velox
      @y += @veloy
      if @x <= 550; @velox = 0; end
      if @y >= 650; @veloy = 0; end
    end
  end





  #
  #  SPARKLE
  #    called in OpeningCredits2 gamestate (Ruby logo)
  class Sparkle < Chingu::GameObject
    def setup
      @image = Gosu::Image.new("#{RelaxGame::GAME_ROOT_PATH}/assets/intro/sparkle.png")
      self.factor = 0.1
      @turning = 0.5
      @factoring = 1.0
      @angle = 35
    end

    def turnify1; @turning = 1.0; @factoring = 1.2;   end
    def turnify2; @turning = 2.8; @factoring = 1.05;  end
    def turnify3; @turning = 8.5; @factoring = 1.00;  end
    def turnify4; @turning = 12.5; @factoring = 1.2;  end
    def turnify5; @turning = 10.4; @factoring = 0.75;  end
    def turnify6; @turning = 6.8; @factoring = 0.25;  end

    def update
      @angle += @turning
      self.factor *= @factoring

      # if self.factor >= 1.1
      #   @factoring = 1.0
      # end
    end
  end

  #
  #  HIGHLIGHT
  #    called in OpeningCredits gamestate (Gosu logo)
  class Highlight < Chingu::GameObject
    def setup
      @image = Gosu::Image.new("#{RelaxGame::GAME_ROOT_PATH}/assets/intro/highlight.png")
    end
    def update
      @x += 5
    end
  end

  #
  #  HIGHLIGHT2
  #    called in OpeningCredits gamestate (Gosu logo)
  class Highlight2 < Chingu::GameObject
    def setup
      @image = Gosu::Image.new("#{RelaxGame::GAME_ROOT_PATH}/assets/intro/highlight2.png")
    end
    def update
      @x += 5
    end
  end
end
