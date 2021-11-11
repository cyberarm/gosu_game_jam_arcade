require_relative "monster" if not defined? Monster

class ChaosPenguinGame
    class FinalBoss < Monster

        def initialize(chaos_penguin, canon, camera)
            super(chaos_penguin, camera, "#{ChaosPenguinGame::GAME_ROOT_PATH}/assets/castle_front.png", 151, 190)
            @hp_max = 15
            @hp = @hp_max
            @canon = canon

            @king_sprite = Omega::Sprite.new("#{ChaosPenguinGame::GAME_ROOT_PATH}/assets/king.png")
            @king_sprite.set_origin(0.5, 1.0)
            # @king_sprite.angle = 15

            @timer = 0

            # @can_draw_hitbox = true
        end

        def update
            super()
            @king_sprite.angle = 10 if @canon.hp <= 0 && @king_sprite.angle.to_i == 0
            @king_sprite.angle = -@king_sprite.angle if @timer % 5 == 0
            @timer += 1
        end

        def update_hitbox
            @hitbox.position.x = @position.x-(@width*@scale.x*@origin.x) + 0
            @hitbox.position.y = @position.y-(@height*@scale.y*@origin.y) +0
            @hitbox.width = @width*@scale.x - 0;
            @hitbox.height = @height*@scale.y - 0;
        end

        def draw
            @position.z = 1000
            @king_sprite.position.x = @position.x - 10
            @king_sprite.position.y = @position.y - 40
            @king_sprite.position.z = @position.z
            @king_sprite.draw if @hp > 0
            super()
        end

    end
end