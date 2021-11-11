class SceneryState < Omega::State

    def load
        # Load hills mask
        @hills_mask = Omega::Sprite.new("#{ChaosPenguinGame::GAME_ROOT_PATH}/assets/sceneries/bg_hills_mask.png")
        @hills_mask.scale = Omega::Vector2.new(2, 2)
        @heights = []

        for x in 0...@hills_mask.width
            for y in 0...@hills_mask.height
                color = @hills_mask.pixel_at(x, y)
                if color.alpha == 255
                    @heights << y
                    break
                end
            end
        end

        # Sprites
        @sprites = []

        @penguin_range = 0...10
        @flying_bat_range = 10...15

        15.times do |i|
            if @penguin_range.member?(i)
                @sprites << Omega::Sprite.new("#{ChaosPenguinGame::GAME_ROOT_PATH}/assets/sceneries/mini_penguin.png")
            elsif @flying_bat_range.member?(i)
                @sprites << Omega::Sprite.new("#{ChaosPenguinGame::GAME_ROOT_PATH}/assets/sceneries/flying_bat.png")
            end

            @sprites[-1].origin.x = 0.5
            @sprites[-1].origin.y = 1.0
            @sprites[-1].angle = -15
            @sprites[-1].color = Omega::Color::BLACK
            @sprites[-1].x = rand(Omega.width)
            @sprites[-1].y = @heights[@sprites[-1].x / 2] * 2 # Initial position
        end

        # Witch penguin
        @witchs = []
        5.times do |i|
            @witchs << Omega::Sprite.new("#{ChaosPenguinGame::GAME_ROOT_PATH}/assets/sceneries/witch_penguin.png")
            @witchs[-1].x = Omega.width + rand(Omega.width * 2)
            @witchs[-1].y = rand(Omega.height / 2.5)
            @witchs[-1].z = 10
        end

        # The vortex
        @vortex = Gosu::Image.new("#{ChaosPenguinGame::GAME_ROOT_PATH}/assets/sceneries/vortex.png")
        @vortex_angle = 0
        @vortex_scale = 0

        # Utils
        @timer = 0

        # Test
        # p @heights[0..20]
    end

    def update(parallax)
        # puts @penguin_sprite.y
        @timer += 1
    end

    def update_sprite_hill(sprite)
        sprite.x = (sprite.x + Omega.width) % (Omega.width * 3) - Omega.width
        ny = @heights[(sprite.x % Omega.width) / 2] * 2
        sprite.y -= (sprite.y - ny) * 0.2
    end

    def update_sprite(sprite, i)
        sprite.x -= 1 + i % 3
        update_sprite_hill(sprite)


        if @penguin_range.member?(i)
            sprite.angle = -sprite.angle if @timer % 15 == 0
        else
            sprite.y += Math::sin((@timer + i) / 10.0) * 2
        end
    end

    def draw(parallax)
        # Gosu.draw_rect(0, 0, Omega.width, Omega.height, Gosu::Color::WHITE, 0)
        # @hills_mask.draw
        # $font.draw_text("#{@penguin_sprite.x}", 5, 5, 1000)

        draw_vortex()

        i = 0
        @sprites.each do |spr|
            update_sprite(spr, i)
            draw_sprite_hill(parallax, spr)

            i += 1
        end

        i = 0
        @witchs.each do |witch|
            if witch.x + witch.width_scaled < 0
                witch.x = Omega.width + rand(Omega.width * 2)
                witch.y = rand(Omega.height / 2.5)
            end

            witch.x -= 2 + i * 0.5

            witch.draw

            i += 1
        end
    end

    def cosv(nb)
        return Math::cos(Omega::to_rad(nb))
    end

    def sinv(nb)
        return Math::sin(Omega::to_rad(nb))
    end

    def draw_vortex
        rp = Omega::Vector2.new(Omega.width / 2, 30) # Rotating point
        width = @vortex.width * 3 * @vortex_scale
        height = @vortex.height * 0.3 * @vortex_scale
        @vortex.draw_as_quad(
            rp.x + cosv(@vortex_angle) * width, rp.y + sinv(@vortex_angle) * height, Gosu::Color::WHITE,
            rp.x + cosv(@vortex_angle+90) * width, rp.y + sinv(@vortex_angle+90) * height, Gosu::Color::WHITE,
            rp.x + cosv(@vortex_angle+180) * width, rp.y + sinv(@vortex_angle+180) * height, Gosu::Color::WHITE,
            rp.x + cosv(@vortex_angle+270) * width, rp.y + sinv(@vortex_angle+270) * height, Gosu::Color::WHITE,
            10
        )

        @vortex_angle = (@vortex_angle + 1) % 360
        @vortex_scale -= (@vortex_scale - 1.0) * 0.1
    end

    def draw_sprite_hill(parallax, sprite)
        last_x = sprite.x
        sprite.x = (sprite.x + parallax.x * (parallax.offset_modifier**2)) % Omega.width
        sprite.draw
        sprite.x = last_x
    end

end