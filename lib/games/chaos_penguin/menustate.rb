class MenuState < Omega::State

    def load
        # Happy parallax
        @parallax = Omega::Parallax.new([
            Omega::Sprite.new("#{ChaosPenguinGame::GAME_ROOT_PATH}/assets/parallax/happy_layer_0.png"),
            Omega::Sprite.new("#{ChaosPenguinGame::GAME_ROOT_PATH}/assets/parallax/happy_layer_1.png"),
            Omega::Sprite.new("#{ChaosPenguinGame::GAME_ROOT_PATH}/assets/parallax/happy_layer_2.png"),
        ])

        @parallax.offset_modifier = 1.8
        @parallax.z_layer = 10

        # Dark Parallax
        @dark_parallax = Omega::Parallax.new([
            Omega::Sprite.new("#{ChaosPenguinGame::GAME_ROOT_PATH}/assets/parallax/layer_0.png"),
            Omega::Sprite.new("#{ChaosPenguinGame::GAME_ROOT_PATH}/assets/parallax/layer_1.png"),
            Omega::Sprite.new("#{ChaosPenguinGame::GAME_ROOT_PATH}/assets/parallax/layer_2.png"),
        ])

        @dark_parallax.offset_modifier = 1.8
        @dark_parallax.z_layer = 10
        @dark_parallax.color.alpha = 0

        @titlescreen = Omega::Sprite.new("#{ChaosPenguinGame::GAME_ROOT_PATH}/assets/titlescreen.png")
        @titlescreen.x = (Omega.width - @titlescreen.width) * 0.5
        @titlescreen.y = 20
        @titlescreen.z = 1000

        # Play musics
        $musics["menu"].play(true)

        # Utils
        @end = false
    end

    def update
        if Omega::just_pressed(Gosu::KB_RETURN) or Omega::just_pressed(Gosu::KB_X) or Omega::just_pressed(Gosu::GP_0_BUTTON_0)
            @end = true
        end

        if @end
            @titlescreen.alpha -= 5 if @titlescreen.alpha > 0
            @dark_parallax.alpha += 5 if @dark_parallax.alpha < 255

            if @dark_parallax.alpha >= 255
                Omega.set_state(ChaosPenguinGame::GameState.new)
            end
        end
    end

    def draw
        @parallax.draw
        @dark_parallax.draw
        @titlescreen.draw
    end

end