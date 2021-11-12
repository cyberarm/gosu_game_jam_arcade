class KeepCalmAndBalanceGame
  ACCELERATION = 0.003 # per degree of seasaw angledness
  DECELERATION = 0.001 # cap of deterioration of speed
  SPEED_PRECISION = 3 # rounding precision, affects minimal effective angle

  FALLING_ACCELERATION = 9.8 # gravity-like

  class Barrel
    attr_reader :x, :y
    attr_accessor :speed

    def initialize(seesaw)
      dir_path = File.dirname(__FILE__)
      @image = Gosu::Image.new(dir_path + '/../../media/circle.png')
      @seesaw = seesaw
      reset!
    end

    # Load default setup
    def reset!
      @onseasaw = true
      @position = 0 # along seesaw
      @radius = TILESIZE / 2
      @speed = 0
      @falling_speed = 0
      @time_of_start_of_fall = nil
      update_coords!
    end

    def update()
      if @onseasaw # barrel rolling
        update_speed!
        update_position!
        update_coords!
        check_onseasawness
      else # barrel falling
        update_position! # still apply speed...
        update_coords! # ... from previous rolling
        update_fall!
      end
    end

    # Change speed on seasaw according to previous speed and current angle of seesaw
    def update_speed!
      if @speed >= 0
        decel = [@speed, DECELERATION].min
      else
        decel = [@speed, -DECELERATION].max
      end

      @speed = (@speed - decel + ACCELERATION * @seesaw.angle).round(SPEED_PRECISION)
    end

    # Change position along seesaw according to previous position and current speed
    def update_position!
      @position = (@position + @speed).round(2)
    end

    # Convert position along seasow to general x and y coords
    def update_coords!
      angle_in_radians = -@seesaw.angle * Math::PI / 180 # minus to convert to counterclockwise

      # From seesaw axis to radius-far above seesaw
      ss_vertical_x = Math::sin(angle_in_radians) * (@seesaw.thickness / 2 + @radius)
      ss_vertical_y = Math::cos(angle_in_radians) * (@seesaw.thickness / 2 + @radius)

      # From radius-far above seesaw to barrel axis
      ss_horizontal_x = Math::cos(-angle_in_radians) * @position
      ss_horizontal_y = Math::sin(-angle_in_radians) * @position

      # Combine both parts
      @x = (@seesaw.x - ss_vertical_x + ss_horizontal_x).round(1)
      @y = (@seesaw.y - ss_vertical_y + ss_horizontal_y).round(1)
    end

    # Find out whether barrel is still on seasaw or whether it should start falling
    def check_onseasawness
      if @position < (-@seesaw.length / 2) or
        @position > (@seesaw.length / 2)
        @onseasaw = false
        @time_of_start_of_fall = Gosu.milliseconds
      end
    end

    # When not over seasaw, apply falling speed to y-coords and then accelerate down
    def update_fall!
      seconds_falling = (Gosu.milliseconds - @time_of_start_of_fall) / 1000.0
      fall_accel = FALLING_ACCELERATION * seconds_falling * seconds_falling
      @falling_speed = (@falling_speed + fall_accel).round(SPEED_PRECISION)
      @y = (@y + @falling_speed).round(1)
    end

    def draw
      @image.draw_rot(@x, @y, ZITEMS, angle = 0,
                      center_x = 0.5, center_y = 0.5,
                      scale_x = 1, scale_y = 1,
                      color = Gosu::Color::RED)

      if $debug
        coords = Gosu::Image.from_text("[#{@x}, #{@y}\nv = #{@speed}]", LINE_HEIGHT)
        coords.draw_rot(@x, @y, ZTEXT, angle = 0)
        puts "x = #{@x}, y = #{@y}, v = #{@speed}, pos = #{@position}, " \
            "on = #{@onseasaw}, v_fall = #{@falling_speed}"
      end
    end
  end
end