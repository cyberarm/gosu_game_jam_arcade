class SchedulerGame
  class States
    class Pause < CyberarmEngine::GuiState
      def setup
        background 0xaa_222222

        flow(width: 1.0, height: 1.0) do
          stack width: 0.3, height: 1.0, padding: 24 do
            background 0xff_222222

            banner "SCHEDULER", width: 1.0, text_align: :center
            title "Paused", width: 1.0, text_align: :center

            button "RESUME", width: 1.0 do
              pop_state
            end

            button "RESTART", width: 1.0, margin_top: 72 do
              until(window.current_state.is_a?(States::MainMenu))
                pop_state
              end

              push_state(States::Game)
            end

            button "MAIN MENU", width: 1.0 do
              until(window.current_state.is_a?(States::MainMenu))
                pop_state
              end
            end

            button "QUIT", width: 1.0 do
              window.close
            end
          end

          stack width: 0.7, height: 1.0, padding: 24 do
            background 0xaa_444444
          end
        end

        def draw
          window.previous_state&.draw
          Gosu.flush

          super
        end

        def button_down(id)
          super

          pop_state if id == Gosu::KB_ESCAPE
        end
      end
    end
  end
end