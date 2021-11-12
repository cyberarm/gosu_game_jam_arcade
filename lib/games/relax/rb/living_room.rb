# Encoding: UTF-8
#                                             #
#                                             #
#               Living Room                   #
#                                             #
#                                             #


class RelaxGame
  class LivingRoom < Chingu::GameState
    trait :timer
    def initialize
      super

      self.input = { :p => Pause, :r => lambda{ current_game_state.setup },
                    :n => :next }

      @img_back = Gosu::Image.new("#{RelaxGame::GAME_ROOT_PATH}/assets/living_room.png")

      @particles = []
      @num_toys.times do
        ppp = Particle.create(:x => rand(1100), :y => rand(700))
        while ppp.has_collisions
          ppp.x = rand(1100)
          ppp.y = rand(700)
        end
        @particles.push(ppp)
      end
      @toy_chest = ToyChest.create(:x => 600, :y => 530, :zorder => 530)

      @human = Human.create(:x => 300, :y => 300, :zorder => Z::PLAYER)
      @human.assign_particles(@particles)
      @units = []
      @num_kids.times { @units.push(Unit.create) }
      @units.each { |unit| unit.new_spot }

  #   @human.input = { :holding_space => make_particles }
      @font1 = Gosu::Font.new(20)
      @font2 = Gosu::Font.new(20)

    end

    def setup
      $music = Gosu::Song.new("#{RelaxGame::GAME_ROOT_PATH}/assets/audio/stageoids.ogg")
      $music.volume = 0.3
      $music.play(true)

      @bumping = false
      after(100) {@bumping = true}

      @shaking = true                 # screen_shake cooldown
      after(1000) {@shaking = false}
    end



    def make_particles
      5.times { @particles.push(Particle.create(:x => @human.x, :y => @human.y)) } #new(@human.x, @human.y)) }
    end

    def destroy_particles(particles)
      particles.reject! do |particle|
        if particle.y > 1100
          true
        end
      end
    end


    def update
      super

      @human.get_coordinates
      @human.move

      @human.collect_toys(@particles)

      @units.each_with_index do |unit, index|
        unit.get_coordinates
        unit.move
        if @bumping == true
          unit.bump_others(@units, @particles) #, @human) }
        end
        unit.grab_toy(@particles, index) if rand(6) == 1
      end

      @toy_chest.update_toys(@units, @particles)

      @particles.each do |particle|
        particle.get_coordinates
        particle.movement
        if particle.held == -1
          particle.moving = false
          particle.x = @human.x
          particle.y = @human.y
          particle.direction = @human.direction
        elsif particle.held >= 0
          particle.moving = false
          unit = @units[particle.held]
          particle.x = unit.x
          particle.y = unit.y
          particle.direction = unit.direction
        end
      end

    end



    def draw
      super
      @img_back.draw(0, 0, Z::BACKGROUND)
      @toy_chest.draw

      @human.draw
      @units.each { |unit| unit.draw }
      @particles.each { |particle| particle.draw }
      @font1.draw_text("Stuff: #{@particles.length}", 12, 12, Z::UI, 1.0, 1.0, Gosu::Color::YELLOW)
      @font1.draw_text("Stuff: #{@particles.length}", 14, 14, Z::UI - 1, 1.0, 1.0, Gosu::Color::BLACK)
    end
  end
end
