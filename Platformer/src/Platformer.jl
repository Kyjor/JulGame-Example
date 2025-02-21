module Platformer 
    using JulGame.SceneBuilderModule: Scene, load_and_prepare_scene
    using JulGame
    
    function run()
        JulGame.ScriptModule = @__MODULE__
        println("JulGame.ScriptModule: $(JulGame.ScriptModule)")
        JulGame.MAIN = JulGame.MainLoop()
        scene = Scene("scene.json")
        load_and_prepare_scene(scene, JulGame.MAIN)
    end

    julia_main() = run()
end