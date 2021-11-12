require_relative './background'
require_relative './infopane'

require_relative './../items/barrel'
require_relative './../items/seesaw'

require_relative './../effects/effect_dealer'

class KeepCalmAndBalanceGame
  TILESIZE = 50
  MAPX = 10
  MAPY = MAPX
  LINE_HEIGHT = 20

  WINDOW_WIDTH = MAPX * TILESIZE
  WINDOW_HEIGHT = MAPY * TILESIZE
  CENTRE = MAPX * TILESIZE / 2

  ZBACKGROUND = 0
  ZITEMS = 1
  ZTEXT = 2

  # Main window
  class GameWindow < Gosu::Window
    attr_reader :loss

    def initialize(version,
                  width = WINDOW_WIDTH,
                  height = WINDOW_HEIGHT,
                  fullscreen = false)
      super(width, height, fullscreen)

      # Set version name
      self.caption = "Keep Calm & Balance #{version}"
      $debug = false # debug messages turned off by default
      reset!

      @background = Background.new()
      @infopane = Infopane.new(self)

      @seesaw = Seesaw.new()
      @barrel = Barrel.new(@seesaw)

      @effect_dealer = EffectDealer.new(@infopane, @seesaw, @barrel)
    end

    # Start processing the pushed button
    def button_down(key)
      case key
      when Gosu::KB_ESCAPE then
        self.close
      when Gosu::KB_BACKSPACE then
        reset
      when Gosu::KB_TAB then
        switch_debug!
      else
        @button = key
      end
    end

    # Stop processing the pushed button
    def button_up(key)
      @button = nil
    end

    # Update game state
    def update
      @infopane.update

      unless @loss
        @seesaw.update(@button)
        @barrel.update # let seesaw update first
        check_loss
        @effect_dealer.update
      end
    end

    # Check whether player has lost yet
    def check_loss
      if @barrel.x < 0 or
        @barrel.x > WINDOW_WIDTH or
        @barrel.y < 0 or
        @barrel.y > WINDOW_HEIGHT
        @loss = true
      end
    end

    # Draw scene
    def draw
      @background.draw
      @barrel.draw
      @effect_dealer.draw
      @infopane.draw
      @seesaw.draw
    end

    # Reset scene
    def reset
      reset!
      @barrel.reset!
      @effect_dealer.reset!
      @infopane.reset!
      @seesaw.reset!
    end

    # Load default setup
    def reset!
      @loss = false
    end

    # Switch debug flag
    def switch_debug!
      $debug = !$debug
    end
  end
end