module Platformer 
    using JulGame.SceneBuilderModule: Scene, load_and_prepare_scene
    using JulGame
    function run()
        JulGame.MAIN = JulGame.MainLoop()
        scene = Scene("scene.json")
        load_and_prepare_scene(JulGame.MAIN;this=scene)
    end

    julia_main() = run()
end