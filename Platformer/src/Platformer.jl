module Platformer 
    using JulGame
    using JulGame.Math

    function run()
        JulGame.MAIN = JulGame.Main(Float64(1.0))
        scene = SceneBuilderModule.Scene("scene.json")
        SceneBuilderModule.load_and_prepare_scene(;this=scene)
    end

    julia_main() = run()
end