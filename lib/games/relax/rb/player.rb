# Encoding: UTF-8


class RelaxGame
  class Player < Chingu::GameObject
    attr_reader :score, :x, :y, :direction
  #  traits :collision_detection, :bounding_box

    def get_coordinates
      @prev_x = @x
      @prev_y = @y
    end

    def go_left
      @vel_x -= 1
      @x -= 5
      @direction = -1
      collision_x
    end

    def go_right
      @vel_x += 1
      @x += 5
      @direction = 1
      collision_x
    end

    def go_up
      @vel_y -= 1
      @y -= 5
      collision_y
    end

    def go_down
      @vel_y += 1
      @y += 5
      collision_y
    end

    def walls
      if @x > 1050 then @x = 1050 end
      if @x < 50 then @x = 50 end
      if @y > 620 then @y = 620 end
      if @y < 70 then @y = 70 end
    end

    def collision_x
      @x = @prev_x if RelaxGame.check_collisions(@x, @y) == true
    end

    def collision_y
      @y = @prev_y if RelaxGame.check_collisions(@x, @y) == true
    end

    def object_collision
      if RelaxGame.check_collisions(@x, @y) == true
        @x = @prev_x
        @y = @prev_y
      end
    end

    # def bounce
    #   puts "bounce"
    # end

    def move
      @x += @vel_x
      collision_x
      @y += @vel_y
      collision_y
      walls
      # object_collision

      @vel_x *= 0.85
      @vel_y *= 0.85
      object_collision
    end

    def draw
      @image.draw_rot(@x, @y, @y + 10, 0, 0.5, 0.5, @direction * 1.25, 1.25)
      @shadow.draw_rot(@x, @y, @y + 9, 0, 0.5, 0.5, @direction * 1.25, 1.25)
  #draw_rot(x, y, z, angle, center_x = 0.5, center_y = 0.5, scale_x = 1, scale_y = 1)
  #    @image.draw_rot(@x, @y, Z::PLAYER, @angle)
    end


    def grab_toy

    end




    def collect_stars(stars, particles)
      stars.reject! do |star|
        if Gosu.distance(@x, @y, star.x, star.y) < 35
          @score += 10
          @boom.play if rand(4) == 1
          3.times {particles.push(Particle.new(@x, @y))}
          true
        else
          false
        end
      end
    end
  end
end