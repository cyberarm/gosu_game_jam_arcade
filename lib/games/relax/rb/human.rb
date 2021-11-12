# Encoding: UTF-8

class RelaxGame
  class Human < Player
    def setup
      @image = Gosu::Image.new("#{RelaxGame::GAME_ROOT_PATH}/assets/characters/knight.png")
      @shadow = Gosu::Image.new("#{RelaxGame::GAME_ROOT_PATH}/assets/characters/char_shadow.png")
      @boom = Gosu::Sample.new("#{RelaxGame::GAME_ROOT_PATH}/assets/audio/explosion.ogg")

      # This is borked...
      self.input = {  [:holding_left, :holding_a] => :go_left,
                      [:holding_right, :holding_d] => :go_right,
                      [:holding_up, :holding_w] => :go_up,
                      [:holding_down, :holding_s] => :go_down,
                      [:holding_space, :holding_enter] => :drop_toys
                    }

      @x = @y = 300
      @vel_x = @vel_y = @angle = 0.0
      @score = 0
      @direction = 1
      @prev_x = 0
      @prev_y = 0
      @z = @y
      @particles = nil
    end

    def assign_particles(particles)
      @particles = particles
    end

    def collect_toys(particles)
      particles.each do |particle|
        if particle.held < -1
          if Gosu.distance(@x, @y, particle.x, particle.y) < 50
  #          @boom.play # if rand(4) == 1
            particle.held = -1
          end
        end
      end
    end

    def drop_toys
      @particles.each do |particle|
        if particle.held == -1
          particle.held = -2
          particle.x += 40 * @direction
          particle.y -= 40
        end
      end
    end
  end
end