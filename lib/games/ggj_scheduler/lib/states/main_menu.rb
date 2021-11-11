class SchedulerGame
  class States
    class MainMenu < CyberarmEngine::GuiState
      def setup
        window.show_cursor = true

        flow(width: 1.0, height: 1.0) do
          stack(width: 0.3, height: 1.0, padding: 24) do
            background 0xff_222222

            banner "SCHEDULER", text_align: :center, width: 1.0

            button "PLAY", width: 1.0 do
              push_state(SchedulerGame::States::Game)
            end

            button "QUIT", width: 1.0 do
              window.close
            end
          end

          stack(width: 0.7, height: 1.0, padding: 24) do
            background 0xff_111111

            title "HOW TO PLAY"

            para "Create paths from the entry door to the various zones before time runs out!"
            para "Use [LEFT MOUSE] and drag to trace a path from the entry door to the waiting zone."
            para "Be careful not to block yourself!"
            banner ""
            para "Music: cynicmusic [cynicmusic.com]"
            para "Bubble SFX: farfadet46 [opengameart.org/users/farfadet46]"
          end
        end
      end
    end
  end
end
