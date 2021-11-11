module Omega
    class Assets
        (Dir["#{ChaosPenguinGame::GAME_ROOT_PATH}/assets/*.png"] + Dir["#{ChaosPenguinGame::GAME_ROOT_PATH}/assets/*.jpg"]).each do |f|
            name = "TEX_" + f.split("/")[1].gsub(".", "_").gsub(" ", "_").downcase
            eval("#{name} = Gosu::Image.new(\"#{f}\")")
        end

        (Dir["#{ChaosPenguinGame::GAME_ROOT_PATH}/assets/*.ogg"] + Dir["#{ChaosPenguinGame::GAME_ROOT_PATH}/assets/*.mp3"]).each do |f|
            name = "MUS_" + f.split("/")[1].gsub(".", "_").gsub(" ", "_").downcase
            eval("#{name} = Gosu::Song.new(\"#{f}\")")
        end
    end
end if false