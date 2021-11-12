class KeepCalmAndBalanceGame
  ANGLE_CHANGE = 0.3

  class Seesaw
    attr_reader :x, :y, :angle
    attr_accessor :scale_x, :scale_y

    def initialize()
      dir_path = File.dirname(__FILE__)
      @image = Gosu::Image.new(dir_path + '/../../media/square.png')
      reset!
    end

    # Load default setup
    def reset!
      @x = CENTRE
      @y = CENTRE
      @angle = 0
      @scale_x = 6
      @scale_y = 0.5
    end

    def update(button)
      case button
      when Gosu::KB_LEFT, Gosu::KB_A, Gosu::KB_NUMPAD_4 then
        @angle -= ANGLE_CHANGE
      when Gosu::KB_RIGHT, Gosu::KB_D, Gosu::KB_NUMPAD_6 then
        @angle += ANGLE_CHANGE
      end
      @angle = @angle.round(1)
    end

    def draw
      @image.draw_rot(@x, @y, ZITEMS, @angle,
                      center_x = 0.5, center_y = 0.5,
                      @scale_x, @scale_y,
                      color = Gosu::Color::AQUA)

      if $debug
        coords = Gosu::Image.from_text("[#{@x}, #{@y}, #{@angle}°]", LINE_HEIGHT)
        coords.draw_rot(@x, @y, ZTEXT, @angle)
      end
    end

    def length
      TILESIZE * @scale_x
    end

    def thickness
      TILESIZE * @scale_y
    end
  end
end