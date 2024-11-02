module Platformer 
    using JulGame.SceneBuilderModule: Scene, load_and_prepare_scene
    using JulGame: Main
    function run()
        scene = Scene("scene.json")
        load_and_prepare_scene(Main();this=scene)
    end

    julia_main() = run()
end