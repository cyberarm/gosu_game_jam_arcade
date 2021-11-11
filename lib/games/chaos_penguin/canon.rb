require_relative "monster" if not defined? Monster

class ChaosPenguinGame
    class Canon < Monster

        def initialize(chaos_penguin, camera)
            @chaos_penguin = chaos_penguin
            super(chaos_penguin, camera, "#{ChaosPenguinGame::GAME_ROOT_PATH}/assets/canon.png", 63, 52)

            @ball_positions = []

            @ball_sprite = Omega::Sprite.new("#{ChaosPenguinGame::GAME_ROOT_PATH}/assets/canonball.png")
            @ball_sprite.set_origin(0.5, 0.5)

            @hp_max = 8
            @hp = @hp_max

            @timer = 0

            @damage = 15

        end

        def update

            return if @hp <= 0 and @scale.x < 0.05

            super()
            update_hitbox()

            if (@chaos_penguin.x - self.x).abs < 350 && @hp > 0 && @timer % 60 == 0 && @timer % 400 > 200
                @ball_positions << Omega::Vector3.new(@position.x, @position.y + height_scaled / 3, -4)
                $sounds["bullet"].play()
            end

            # puts @chaos_penguin.hp if @timer % 2 == 1

            @chaos_penguin.update()

            @timer += 1
        end

        def update_hitbox
            @hitbox.position.x = @position.x-(@width*@scale.x*@origin.x) + 0
            @hitbox.position.y = @position.y-(@height*@scale.y*@origin.y) +0
            @hitbox.width = @width*@scale.x - 0;
            @hitbox.height = @height*@scale.y - 0;
        end

        def draw
            return if @hp <= 0 and @scale.x < 0.05

            last_scale = @scale.clone

            draw_balls()

            if @timer % 400 > 150 && @timer % 400 <= 200
                @scale = Omega::Vector2.new(1 + rand(-1..1)/10.0, 1 + rand(-1..1)/10.0)
            end
            super()
            @scale = last_scale
        end

        def draw_balls
            to_delete = []
            for i in 0...@ball_positions.size
                ball = @ball_positions[i]

                ball.x -= 6
                ball.y += ball.z # Z = velocity Y
                ball.z += 0.1

                @ball_sprite.set_position(ball.x, ball.y, 1000)
                @ball_sprite.draw()

                ball_hitbox = Omega::Rectangle.new(ball.x - @ball_sprite.width / 2,
                                                ball.y - @ball_sprite.height / 2,
                                                @ball_sprite.width,
                                                @ball_sprite.height)

                if @ball_sprite.y - @ball_sprite.height / 2 > Omega.height
                    to_delete << ball
                elsif ball_hitbox.collides?(@chaos_penguin.hitbox)
                    @chaos_penguin.receive_damage(@damage)
                end
            end

            to_delete.each { |b| @ball_positions.delete(b) }
        end

    end
end