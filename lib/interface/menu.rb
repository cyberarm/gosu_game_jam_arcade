class GosuGameJamArcade
  class Interface
    class Menu < CyberarmEngine::GuiState
      FRAME_PADDING = 32
      FRAME_THICKNESS = 4

      @@card_index = 0

      def setup
        window.show_cursor = false

        @background_image = get_image("#{GosuGameJamArcade::GAME_ROOT_PATH}/media/background.png")
        @gosu_game_jam_logo = get_image("#{GosuGameJamArcade::GAME_ROOT_PATH}/media/gosu_game_jam_logo_large.png")

        @gosu_game_jam_logo_scale = 0.25

        @window_scale = [window.width / 1920.0, window.height / 1080.0].min

        @gosu_game_jam_logo_scale *= @window_scale

        @gosu_game_jam_logo_position = CyberarmEngine::Vector.new(
          window.width - (@gosu_game_jam_logo.width * @gosu_game_jam_logo_scale) / 2 - (FRAME_PADDING + FRAME_THICKNESS * 2),
          (FRAME_PADDING + FRAME_THICKNESS * 2) + (@gosu_game_jam_logo.height * @gosu_game_jam_logo_scale) / 2,
          10
        )

        flow(width: 1.0, height: 1.0, margin: FRAME_THICKNESS + FRAME_PADDING) do
          banner "<b>Arcade</b>", width: 1.0, text_align: :center, text_size: (128 * @window_scale).round, text_border: false, text_shadow: true, text_shadow_size: 1, text_shadow_color: 0xff_000000
        end

        @cards = [
          GosuGameJamArcade::Interface::Card.new(
            title: "Pet Peeve",
            description: "You are an adorable kitten and you've just moved into your new home - how exciting! Wouldn't it be a shame if you went on a mug-breaking, shelf-clearing spree of destruction...?",
            authors: "Aaron Christiansen (@OrangeFlash81)",
            banner: "pet_peeve.png",
            color_hint: 0x88_800000
          ) do
            GosuGameJamArcade::Window.current_game = PetPeeve::GameWindow.new
            GosuGameJamArcade::Window.current_game.current_window = GosuGameJamArcade::Window.instance
          end,

          GosuGameJamArcade::Interface::Card.new(
            title: "Boxes !",
            description: "You have to sort the boxes falling from the top right corner using three sorting areas.",
            authors: "Guillaume Quillet (@bestguigui)",
            banner: "boxes.png",
            color_hint: 0x88_884422
          ) do
            GosuGameJamArcade::Window.current_game = BoxesGame::Window.new
            GosuGameJamArcade::Window.current_game.current_window = GosuGameJamArcade::Window.instance
          end,

          GosuGameJamArcade::Interface::Card.new(
            title: "Relax",
            description: "This game puts you in an ordinary living room on an ordinary day — just relax, and try to keep things tidy in there if you can please!",
            authors: "eagleDog and triquad",
            banner: "relax.png",
            color_hint: 0x88_ff8800
          ) do
            GosuGameJamArcade::Window.current_game = RelaxGame::Game.new
            GosuGameJamArcade::Window.current_game.current_window = GosuGameJamArcade::Window.instance
          end,

          GosuGameJamArcade::Interface::Card.new(
            title: "Butterfly Surfer",
            description: "Earn points by staying alive. Maximize points per second by gliding as close as possible to the bodies. BUT BEWARE! Your microscopic mass, although negligible, will have an exponentially increasing impact on their fragile equilibrium as you grow nearer. Disturb the natural order at your own risk.",
            authors: "heymitchfischer",
            banner: "butterfly_surfer.png",
            color_hint: 0x88_000000
          ) do
            GosuGameJamArcade::Window.current_game = ButterflySurferGame::ButterflySurfer.new
            GosuGameJamArcade::Window.current_game.current_window = GosuGameJamArcade::Window.instance
          end,

          GosuGameJamArcade::Interface::Card.new(
            title: "Chaos Penguin",
            description: "Welcome into Chaos Penguin!\n\nIn this entry for the Inaugural Gosu Jam, you will take the role of (obviously) the \"Chaos Penguin\"! It's up to you to destroy, ruin, and establish chaos in the peaceful kingdom of Penguinland.\n\nWill you succeed in this chaotic task?",
            authors: "HydroGene & D3nX",
            banner: "chaos_penguin.png",
            color_hint: 0x88_000080
          ) do
            Omega.run(ChaosPenguinGame::Game, "#{ChaosPenguinGame::GAME_ROOT_PATH}/config.json")

            GosuGameJamArcade::Window.current_game = Omega.window
            GosuGameJamArcade::Window.current_game.current_window = GosuGameJamArcade::Window.instance
          end,

          GosuGameJamArcade::Interface::Card.new(
            title: "Scheduler",
            description: "Weave all the Travellers to their zones before time runs out",
            authors: "Cyberarm",
            banner: "scheduler.png",
            color_hint: 0x88_255025
          ) do
            GosuGameJamArcade::Window.current_game = SchedulerGame::Window.new(width: window.width, height: window.height)
            GosuGameJamArcade::Window.current_game.current_window = GosuGameJamArcade::Window.instance
          end,

          GosuGameJamArcade::Interface::Card.new(
            title: "Keep Calm & Balance",
            description: "Your goal is to keep balancing the barrel on the seesaw for as long as possible. Game ends when the centre of barrel leaves the window area.",
            authors: "rasunadon",
            banner: "keep_calm_and_balance.png",
            color_hint: 0x88_404080
          ) do
            GosuGameJamArcade::Window.current_game = KeepCalmAndBalanceGame::GameWindow.new(KeepCalmAndBalanceGame::VERSION)
            GosuGameJamArcade::Window.current_game.current_window = GosuGameJamArcade::Window.instance
          end,

          GosuGameJamArcade::Interface::Card.new(
            title: "Ruby Brickland",
            description: "There is chaos in Ruby Brickland, and you need to get your ball to the green field out of the castle before it is engulfed in flames. Clear as many bricks and collect as many dots as you can along the way before exiting into the green area at the top. Don't take too long because the fire level will be rising.",
            authors: "dbroemme",
            banner: "ruby_brickland.png",
            color_hint: 0x44_ff8800
          ) do
            GosuGameJamArcade::Window.current_game = BricksGameGame::BricksGame.new
            GosuGameJamArcade::Window.current_game.current_window = GosuGameJamArcade::Window.instance
          end
        ]
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

        prev_card = @cards[(@@card_index - 1) % @cards.size]
        card = @cards[@@card_index]
        next_card = @cards[(@@card_index + 1) % @cards.size]

        fixed_height = 630.0 / 2

        fill(0x44_222222) # Dim background image a tad
        fill(card.color_hint) # Color Hint

        Gosu.clip_to(FRAME_PADDING + FRAME_THICKNESS, FRAME_PADDING + FRAME_THICKNESS,
                     window.width - ((FRAME_PADDING + FRAME_THICKNESS) * 2), window.height - ((FRAME_PADDING + FRAME_THICKNESS) * 2)) do
          Gosu.translate(-prev_card.width / 2, window.height / 2 - fixed_height) do
            Gosu.scale(@window_scale, @window_scale, prev_card.width / 2, window.height / 2) do
              prev_card.draw
            end
          end

          Gosu.translate(window.width / 2 - card.width / 2, window.height / 2 - fixed_height) do
            Gosu.scale(@window_scale, @window_scale, window.width / 2 - card.width / 2, window.height / 2) do
              card.draw
            end
          end

          Gosu.translate(window.width - next_card.width / 2, window.height / 2 - fixed_height) do
            Gosu.scale(@window_scale, @window_scale, 0, window.height / 2) do
              next_card.draw
            end
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
          @@card_index -= 1
        when Gosu::KB_RIGHT, Gosu::KB_D
          @@card_index += 1
        when Gosu::KB_ENTER, Gosu::KB_RETURN, Gosu::KB_SPACE
          # launch game
          @cards[@@card_index].block.call
        end

        @@card_index = @cards.size - 1 if @@card_index < 0
        @@card_index = 0 if @@card_index > @cards.size - 1
      end
    end
  end
end
