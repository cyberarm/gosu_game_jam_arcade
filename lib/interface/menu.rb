class GosuGameJamArcade
  class Interface
    class Menu < CyberarmEngine::GuiState
      FRAME_PADDING = 32
      FRAME_THICKNESS = 4

      def setup
        window.show_cursor = true

        @background_image = get_image("#{GosuGameJamArcade::GAME_ROOT_PATH}/media/background.png")
        @gosu_game_jam_logo = get_image("#{GosuGameJamArcade::GAME_ROOT_PATH}/media/gosu_game_jam_logo_large.png")

        @gosu_game_jam_logo_scale = 0.25

        @gosu_game_jam_logo_position = CyberarmEngine::Vector.new(
          window.width - (@gosu_game_jam_logo.width * @gosu_game_jam_logo_scale) / 2 - (FRAME_PADDING + FRAME_THICKNESS * 2),
          (FRAME_PADDING + FRAME_THICKNESS * 2) + (@gosu_game_jam_logo.height * @gosu_game_jam_logo_scale) / 2,
          10
        )

        flow(width: 1.0, height: 1.0, margin: FRAME_THICKNESS + FRAME_PADDING) do
          banner "<b>Gosu Arcade</b>", width: 1.0, text_align: :center, text_size: 144, text_border: false, text_shadow: true, text_shadow_size: 1, text_shadow_color: 0xff_000000
        end

        @cards = [
          GosuGameJamArcade::Interface::Card.new(
            title: "Pet Peeve",
            description: "The pet must finish making a mess before time runs out!",
            authors: "AUTHOR and AUTHOR",
            banner: "pet_peeve.png",
            color_hint: 0x88_800000
          ) do
            GosuGameJamArcade::Window.current_game = PetPeeve::GameWindow.new
            GosuGameJamArcade::Window.current_game.current_window = GosuGameJamArcade::Window.instance
          end,

          GosuGameJamArcade::Interface::Card.new(
            title: "Boxes !",
            description: "The pet must finish making a mess before time runs out!",
            authors: "AUTHOR and AUTHOR",
            banner: "boxes.png",
            color_hint: 0x88_884422
          ) do
            GosuGameJamArcade::Window.current_game = BoxesGame::Window.new
            GosuGameJamArcade::Window.current_game.current_window = GosuGameJamArcade::Window.instance
          end,

          GosuGameJamArcade::Interface::Card.new(
            title: "Relax",
            description: "The pet must finish making a mess before time runs out!",
            authors: "AUTHOR and AUTHOR",
            banner: "relax.png",
            color_hint: 0x88_ff8800
          ) do
            GosuGameJamArcade::Window.current_game = RelaxGame::Game.new
            GosuGameJamArcade::Window.current_game.current_window = GosuGameJamArcade::Window.instance
          end,

          GosuGameJamArcade::Interface::Card.new(
            title: "Butterfly Surfer",
            description: "The pet must finish making a mess before time runs out!",
            authors: "AUTHOR and AUTHOR",
            banner: "butterfly_surfer.png",
            color_hint: 0x88_000000
          ) do
            GosuGameJamArcade::Window.current_game = ButterflySurferGame::ButterflySurfer.new
            GosuGameJamArcade::Window.current_game.current_window = GosuGameJamArcade::Window.instance
          end,

          GosuGameJamArcade::Interface::Card.new(
            title: "Chaos Penguin",
            description: "The pet must finish making a mess before time runs out!",
            authors: "AUTHOR and AUTHOR",
            banner: "chaos_penguin.png",
            color_hint: 0x88_000080
          ) do
            Omega.run(ChaosPenguinGame::Game, "#{ChaosPenguinGame::GAME_ROOT_PATH}/config.json")

            GosuGameJamArcade::Window.current_game = Omega.window
            GosuGameJamArcade::Window.current_game.current_window = GosuGameJamArcade::Window.instance
          end,

          GosuGameJamArcade::Interface::Card.new(
            title: "Scheduler",
            description: "The pet must finish making a mess before time runs out!",
            authors: "AUTHOR and AUTHOR",
            banner: "scheduler.png",
            color_hint: 0x88_255025
          ) do
            GosuGameJamArcade::Window.current_game = SchedulerGame::Window.new(width: window.width, height: window.height)
            GosuGameJamArcade::Window.current_game.current_window = GosuGameJamArcade::Window.instance
          end,

          GosuGameJamArcade::Interface::Card.new(
            title: "Keep Calm & Balance",
            description: "The pet must finish making a mess before time runs out!",
            authors: "AUTHOR and AUTHOR",
            banner: "keep_calm_and_balance.png",
            color_hint: 0x88_404080
          ) do
            GosuGameJamArcade::Window.current_game = KeepCalmAndBalanceGame::GameWindow.new(KeepCalmAndBalanceGame::VERSION)
            GosuGameJamArcade::Window.current_game.current_window = GosuGameJamArcade::Window.instance
          end,

          GosuGameJamArcade::Interface::Card.new(
            title: "Ruby Brickland",
            description: "The pet must finish making a mess before time runs out!",
            authors: "AUTHOR and AUTHOR",
            banner: "ruby_brickland.png",
            color_hint: 0x44_ff8800
          ) do
            GosuGameJamArcade::Window.current_game = BricksGameGame::BricksGame.new
            GosuGameJamArcade::Window.current_game.current_window = GosuGameJamArcade::Window.instance
          end
        ]

        @card_index = 0
      end

      def draw
        bg_scale = [
          @background_image.width / window.width.to_f,
          @background_image.width / window.height.to_f
        ].min

        @background_image.draw(
          0,
          0,
          0,
          bg_scale,
          bg_scale
        )

        prev_card = @cards[(@card_index - 1) % @cards.size]
        card = @cards[@card_index]
        next_card = @cards[(@card_index + 1) % @cards.size]

        fill(0x44_222222) # Dim background image a tad
        fill(card.color_hint) # Color Hint

        Gosu.clip_to(FRAME_PADDING + FRAME_THICKNESS, FRAME_PADDING + FRAME_THICKNESS,
                     window.width - ((FRAME_PADDING + FRAME_THICKNESS) * 2), window.height - ((FRAME_PADDING + FRAME_THICKNESS) * 2)) do
          Gosu.translate(-prev_card.width / 2, window.height / 2 - prev_card.height / 2) do
            prev_card.draw
          end

          Gosu.translate(window.width / 2 - card.width / 2, window.height / 2 - card.height / 2) do
            card.draw
          end

          Gosu.translate(window.width - next_card.width / 2, window.height / 2 - next_card.height / 2) do
            next_card.draw
          end
        end

        Gosu.draw_rect(
          FRAME_PADDING, FRAME_PADDING,
          window.width - FRAME_PADDING * 2, FRAME_THICKNESS,
          Gosu::Color::BLACK
        )
        Gosu.draw_rect(
          window.width - (FRAME_PADDING + FRAME_THICKNESS), FRAME_PADDING,
          FRAME_THICKNESS, window.height - FRAME_PADDING * 2,
          Gosu::Color::BLACK
        )
        Gosu.draw_rect(
          FRAME_PADDING, window.height - (FRAME_PADDING + FRAME_THICKNESS),
          window.width - FRAME_PADDING * 2, FRAME_THICKNESS,
          Gosu::Color::BLACK
        )
        Gosu.draw_rect(
          FRAME_PADDING, FRAME_PADDING,
          FRAME_THICKNESS, window.height - FRAME_PADDING * 2,
          Gosu::Color::BLACK
        )

        @gosu_game_jam_logo.draw_rot(
          @gosu_game_jam_logo_position.x,
          @gosu_game_jam_logo_position.y,
          @gosu_game_jam_logo_position.z,
          0,
          0.5,
          0.5,
          @gosu_game_jam_logo_scale,
          @gosu_game_jam_logo_scale
        )

        super
      end

      def button_down(id)
        super

        case id
        when Gosu::KB_LEFT, Gosu::KB_A
          @card_index -= 1
        when Gosu::KB_RIGHT, Gosu::KB_D
          @card_index += 1
        when Gosu::KB_ENTER, Gosu::KB_RETURN, Gosu::KB_SPACE
          # launch game
          @cards[@card_index].block.call
        end

        @card_index = @cards.size - 1 if @card_index < 0
        @card_index = 0 if @card_index > @cards.size - 1
      end
    end
  end
end
