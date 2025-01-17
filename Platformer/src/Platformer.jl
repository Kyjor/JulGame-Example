module Platformer 
    using JulGame.SceneBuilderModule: Scene, load_and_prepare_scene
    using JulGame
    function run()
        JulGame.MAIN = JulGame.Main()
        scene = Scene("scene.json")
        load_and_prepare_scene(;this=scene)
    end

    julia_main() = run()
end