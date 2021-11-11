class ChaosPenguinGame
    class GameState < Omega::State

        def load
            # Camera
            @camera = Omega::Camera.new(false)
            @camera.scale = Omega::Vector2.new(2, 2)
            @camera.position.y = -48

            # Parallax
            @parallax = Omega::Parallax.new([
                Omega::Sprite.new("#{ChaosPenguinGame::GAME_ROOT_PATH}/assets/parallax/layer_0.png"),
                Omega::Sprite.new("#{ChaosPenguinGame::GAME_ROOT_PATH}/assets/parallax/layer_1.png"),
                Omega::Sprite.new("#{ChaosPenguinGame::GAME_ROOT_PATH}/assets/parallax/layer_2.png"),
            ])

            @parallax.offset_modifier = 1.8
            @parallax.z_layer = 10

            # Fire layer
            @fire_layer = FireLayer.new()
            @fire_layer.y = Omega.height - @fire_layer.height_scaled

            # Moon
            @moon = Omega::Sprite.new("#{ChaosPenguinGame::GAME_ROOT_PATH}/assets/moon.png")
            @moon.y = 15
            @moon.x = Omega.width

            # Scenery
            @scenery_state = SceneryState.new()
            @scenery_state.load()

            # Load map
            @map = Omega::Map.new("#{ChaosPenguinGame::GAME_ROOT_PATH}/assets/tileset.png", 32)
            @map.load_layer("solid", "#{ChaosPenguinGame::GAME_ROOT_PATH}/assets/map/map_1.csv")
            @map.set_layer_z("solid", 100)

            @map.set_type(0, "solid")
            @map.set_type(1, "solid")

            # Load mini map
            @minimap = Minimap.new(@map)

            # Load Chaos Penguin
            @chaos_penguin = ChaosPenguin.new(@camera, @map);
            @black_rectangle = Omega::Rectangle.new(0, 0, Omega.width, Omega.height);
            @black_rectangle.position.z = 9999999;
            @black_rectangle.color = Omega::Color.copy(Gosu::Color::BLACK);
            @black_rectangle.color.alpha = 0;

            # Load Monster
            @list_monsters = []; #KnightPenguin.new(@chaos_penguin, @camera);
            for i in 0..@map.width
                if (i%400 == 0 and i > 200 and i < 4500) then
                    monster = (rand(0..1) == 0) ? SoldierPenguin.new(@chaos_penguin, @camera) : KnightPenguin.new(@chaos_penguin, @camera);
                    monster.position.x = i;
                    @list_monsters.push(monster);
                end
            end

            # UI
            @ui_head = Omega::Sprite.new("#{ChaosPenguinGame::GAME_ROOT_PATH}/assets/ui_head.png")

            # Load final boss
            @canon = Canon.new(@chaos_penguin, @camera)

            @canon.set_position(4550, 330)

            @final_boss = FinalBoss.new(@chaos_penguin, @canon, @camera)

            @final_boss.set_position(4700, 258)

            # Play musics
            $musics["game"].play(true)
        end

        # Update all sprites/scenery in the background
        def update_background()
            @fire_layer.update
            @parallax.position.x -= 0.1 if @parallax.position.x > -410
            @camera.position.x = @parallax.position.x * 10
            @fire_layer.x = (@parallax.position.x * 20) % @fire_layer.width_scaled

            @moon.x -= @parallax.offset_modifier * 0.1
            @moon.y = Math::cos(Omega::to_rad(180.0/Omega.width * @moon.x))**2 * 100

            @scenery_state.update(@parallax)

            @final_boss.update()
            @canon.update()
        end

        def update
            update_background();

            for monster in @list_monsters
                monster.update();
            end

            # @soldier_penguin.update();

            @chaos_penguin.update() if @final_boss.hp > 0

            if (@chaos_penguin.is_game_over or @final_boss.hp <= 0) then
                @black_rectangle.color.alpha += 5

                if (@black_rectangle.color.alpha >= 255) then
                    if @final_boss.hp <= 0
                        Omega.set_state(EndingState.new)
                    else
                        Omega.set_state(GameState.new)
                    end
                end

            end

            @minimap.update([@chaos_penguin])
        end

        # Draw all sprites in the background
        def draw_background()
            @parallax.draw()
            @scenery_state.draw(@parallax)

            @moon.draw

            draw_fire_layer()
        end

        def draw
            draw_background();
            draw_game()
            draw_ui()

            if (@chaos_penguin.is_game_over) then
                @black_rectangle.draw();
            end

        end

        def draw_game

            # Draw all elements that have to follow the camera movement
            @camera.draw(Omega.width / @camera.scale.x, Omega.height / @camera.scale.y) do
                @map.draw(Omega::Vector2.new(@camera.position.x + @map.tile_size, @camera.position.y), @camera.scale)
                draw_entities()
            end
        end

        def draw_ui
            z = 10_000

            @ui_head.set_position(10, 5, z)
            @ui_head.draw

            pos = Omega::Vector2.new(80, 10)
            Omega.draw_progress_bar(pos.x, pos.y, z, 400, 24, Gosu::Color::BLACK, Gosu::Color::RED, @chaos_penguin.hp, ChaosPenguin::HP_MAX)
            $font.draw_text("HP : #{@chaos_penguin.hp}", pos.x + 5, pos.y, z, 1, 1, Gosu::Color::WHITE)

            pos = Omega::Vector2.new(80, 40)
            Omega.draw_progress_bar(pos.x, pos.y, z, 300, 24, Gosu::Color::BLACK, Gosu::Color.new(0, 200, 0), @chaos_penguin.stamina, ChaosPenguin::STAMINA_MAX)
            $font.draw_text("Stamina : #{@chaos_penguin.stamina}", pos.x + 5, pos.y, z, 1, 1, Gosu::Color::WHITE)

            @minimap.draw()
        end

        # Draw all monsters and sprites on the foreground
        def draw_entities

            for monster in @list_monsters
                monster.draw();
            end

            # @soldier_penguin.draw();

            @chaos_penguin.draw();

            @final_boss.draw()
            @canon.draw()
        end

        def draw_fire_layer
            @fire_layer.draw()
            @fire_layer.x -= @fire_layer.width_scaled
            @fire_layer.draw()
            @fire_layer.x += @fire_layer.width_scaled
        end

    end
end