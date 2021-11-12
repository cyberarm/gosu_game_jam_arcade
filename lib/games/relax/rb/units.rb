# Encoding: UTF-8


class RelaxGame
  class Unit < Player
    attr_reader :has_toy
    trait :timer
  #  traits :collision_detection, :bounding_box
    # trait :bounding_circle, :collision_detection #, :debug => true
    # traits :velocity, :collision_detection

    def setup
      char_num = 1 + rand(14)
      @char = Gosu::Image.new("#{RelaxGame::GAME_ROOT_PATH}/assets/characters/char" + char_num.to_s + ".png")
      @boom = Gosu::Sample.new("#{RelaxGame::GAME_ROOT_PATH}/assets/audio/explosion.ogg")
      @dust0 = Gosu::Image.new("#{RelaxGame::GAME_ROOT_PATH}/assets/dust/dust0.png")
      @dust1 = Gosu::Image.new("#{RelaxGame::GAME_ROOT_PATH}/assets/dust/dust1.png")
      @dust2 = Gosu::Image.new("#{RelaxGame::GAME_ROOT_PATH}/assets/dust/dust2.png")
      @dust3 = Gosu::Image.new("#{RelaxGame::GAME_ROOT_PATH}/assets/dust/dust3.png")
      @dust = false
      @dust_img = @dust3
      @x = rand(1000) + 50
      @y = rand(600) + 50
      @z = @y
      @vel_x = @vel_y = @angle = 0.0
      @score = 0
      @direction = 1
      @rate = 10
      @steps = 0    # step counter
      @max_steps = 10
      @left = false
      @right = false
      @up = false
      @down = false
      # @directions = {left: false, right: false, up: false, down: false}
      @walking = false
      @has_toy = nil
      @bumps = 0
    end

    def ai
      count_steps
      return if @walking == true
      if rand(@rate) == 2
        @walking = true
        case rand(8) + 1
        when 1; @left = true
        when 2; @right = true
        when 3; @up = true
        when 4; @down = true
        when 5; @left = true; @up = true
        when 6; @left = true; @down = true
        when 7; @right = true; @up = true
        when 8; @right = true; @down = true
        end
        @left = false if @x < 50
        @right = true if @x < 50
        @right = false if @x > 1050
        @left = true if @x > 1050
        @up = false if @y < 50
        @down = true if @y < 50
        @down = false if @y > 650
        @up = true if @y > 650
      end
    end

    def count_steps
      @steps += 1
      if @steps >= @max_steps
        @steps = 0
        @walking = false
        @left = false
        @right = false
        @up = false
        @down = false
        @max_steps = rand(10) + 1
      end
    end

    def new_spot
      if RelaxGame.check_collisions(@x, @y) == true
        @x = 600 - rand(50)
        @y = 200 - rand(50)
      end
    end

    def remove_dust
      after(200) { @dust = false }
    end

    def bump_others(units, particles) #, player)
      units.each do |unit| #, player|
        how_far = Gosu.distance(@x, @y, unit.x, unit.y)
        if how_far < 35 && how_far > 10 # || how_far2 < 35
          @boom.play if rand(50) == 1
          @dust = true
          remove_dust

          @x = @prev_x
          @y = @prev_y
          @vel_x = -@vel_x * 1.2
          @x += 5 if rand(4) == 1
          @x -= 5 if rand(4) == 1
          collision_x
          @vel_y = -@vel_y * 1.2
          @y += 3 if rand(4) == 1
          @y -= 3 if rand(4) == 1
          collision_y

          if @has_toy != nil
            @bumps += 1
            if @bumps > 4
              throw_toy
            end
          end
        end
      end
    end

    def throw_toy
      @has_toy.held = -2
      @has_toy.moving = true
      @has_toy.stop_moving
      if rand(2) == 1
        @has_toy.x += 35
        @has_toy.vel_x = rand(15)
      elsif
        @has_toy.x -= 35
        @has_toy.vel_x = -rand(15)
      end
      if rand(2) == 1
        @has_toy.y += 35
        @has_toy.vel_y = rand(15)
      elsif
        @has_toy.y -= 35
        @has_toy.vel_y = -rand(15)
      end
      @has_toy = nil
    end


    def move
      ai
      go_left if @left == true
      go_right if @right == true
      @x += @vel_x
      collision_x
      go_up if @up == true
      go_down if @down == true
      @y += @vel_y
      collision_y
      walls
  #    object_collision
      if @has_toy != nil && rand(200) == 1
        throw_toy
      end

      @vel_x *= 0.85
      @vel_y *= 0.85
    end

    def draw
      @char.draw_rot(@x, @y, @y - 5, 0, 0.5, 0.5, @direction * 0.75, 0.75)
      if @dust == true
        @dust3.draw_rot(@x * @direction, @y - 30, @y, 0, 0.5, 0.5, @direction, 1)
        @dust2.draw_rot(@x + 20 * @direction, @y, @y, 0, 0.5, 0.5, @direction, 1)
  #      @dust1.draw_rot(@x - 15 * @direction, @y - 10, @y, -45, 0.5, 0.5, @direction, 1)

      end
  #    @dust_img = @dust0
    end

    def grab_toy(particles, index)
      particles.each do |particle|
        return if @has_toy != nil
        if particle.held < 0
          if Gosu.distance(@x, @y, particle.x, particle.y) < 35
            particle.held = index
            @has_toy = particle
          end
        end
      end
    end
  end
end