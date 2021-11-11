class ChaosPenguinGame
    class FireLayer < Omega::Sprite

        BASE_COLORS = [
            Omega::Color.new(255, 10, 0),
            Omega::Color.new(255, 210, 0)
        ]

        def initialize
            super("#{ChaosPenguinGame::GAME_ROOT_PATH}/assets/fire.png", :tileable => true)

            @change_colors = true
            @colors = [
                Omega::Color.new(0, 255, 10, 0),
                Omega::Color.new(0, 255, 210, 0)
            ]

            @lerp = 0.03

            @timer = 0

            @blazing = 0
        end

        def update
            @colors[0].alpha -= (@colors[0].alpha - 128) * 0.1
            @colors[1].alpha = @colors[0].alpha
            @blazing = Math::cos((Gosu.milliseconds / 500.0)) * 80
            if @change_colors
                @colors[0].red -= (@colors[0].red - BASE_COLORS[1].red) * @lerp
                @colors[0].green -= (@colors[0].green - BASE_COLORS[1].green) * @lerp
                @colors[0].blue -= (@colors[0].blue - BASE_COLORS[1].blue) * @lerp

                @colors[1].red -= (@colors[1].red - BASE_COLORS[0].red) * @lerp
                @colors[1].green -= (@colors[1].green - BASE_COLORS[0].green) * @lerp
                @colors[1].blue -= (@colors[1].blue - BASE_COLORS[0].blue) * @lerp
            else
                @colors[0].red -= (@colors[0].red - BASE_COLORS[0].red) * @lerp
                @colors[0].green -= (@colors[0].green - BASE_COLORS[0].green) * @lerp
                @colors[0].blue -= (@colors[0].blue - BASE_COLORS[0].blue) * @lerp

                @colors[1].red -= (@colors[1].red - BASE_COLORS[1].red) * @lerp
                @colors[1].green -= (@colors[1].green - BASE_COLORS[1].green) * @lerp
                @colors[1].blue -= (@colors[1].blue - BASE_COLORS[1].blue) * @lerp
            end

            if @timer == 50
                @change_colors = !@change_colors
                @timer = 0
            end
            @timer += 1
        end

        def draw
            @image.draw_as_quad(@position.x - @blazing, @position.y, @colors[0],
                                @position.x - @blazing + self.width_scaled, @position.y, @colors[0],
                                @position.x + self.width_scaled, @position.y + self.height_scaled, @colors[1],
                                @position.x, @position.y + self.height_scaled, @colors[1],
                                100)
        end

    end
end