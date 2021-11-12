# Encoding: UTF-8


class RelaxGame
  class ToyChest < Chingu::GameObject
    attr_reader :x, :y
    trait :timer

    def setup
      empty
      @x = 600
      @y = 530
      @particles = nil
      @contents = []
    end

    def empty
      @image = Gosu::Image.new("#{RelaxGame::GAME_ROOT_PATH}/assets/empty_chest.png")
      @full_chest = false
    end

    def full
      @image = Gosu::Image.new("#{RelaxGame::GAME_ROOT_PATH}/assets/toy_chest.png")
      @full_chest = true
    end

    def play_time
      #play sounds
    end

    def toy_shower(particles)
      @contents.each do |pp|
        next unless rand(40) == 1
        pp.vel_y = rand(10) - 20 # Vertical velocity
        pp.vel_x = rand(20) - 10
        pp.moving = true
        pp.stop_moving
      particles.push(pp)
    end
    @contents.reject! { |pp| particles.include? pp }
    end

    def update_toys(units, particles)
      units.each do |unit|
        if !unit.has_toy && Gosu.distance(@x + 100, @y + 50, unit.x, unit.y) < 40
          toy_shower(particles)
          play_time
        end
      end

      particles.each do |particle|
        next if particle.held != -1
        next if Gosu.distance(@x + 100, @y + 50, particle.x, particle.y) > 40
        particle.held = -2
        @contents.push(particle)
      end

      particles.reject! { |pp| @contents.include? pp }
    end

    def draw
      @image.draw(@x, @y, @y)
    end

  end
end

