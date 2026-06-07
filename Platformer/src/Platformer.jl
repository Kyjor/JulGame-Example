module Platformer 
    using JulGame.SceneBuilderModule: Scene, load_and_prepare_scene
    using JulGame
    function run()
        JulGame.MAIN = JulGame.MainLoop()
        scene = SceneBuilderModule.Scene(get(ENV, "SCENE", "scene.json"))
       
        try
            SceneBuilderModule.load_and_prepare_scene(scene; windowName="Platformer", preloadAllScenes=false)
        catch e
            @error first(string(e), min(length(string(e)), 500))
            log_error(first(string(e), min(length(string(e)), 500)))
            return Cint(-1)
        end

        return Cint(0)
    end

    julia_main() = run()
end