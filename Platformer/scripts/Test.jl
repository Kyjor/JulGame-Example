module TestModule
    using JulGame
    
    mutable struct Test <: Script
        parent

        function Test()
            this = new()
            
            return this
        end
    end

    function JulGame.initialize(this::Test)
    end

    function JulGame.update(this::Test, deltaTime)
        if JulGame.InputModule.get_button_pressed(MAIN.input, "SPACE")
           println("Something")
        end

    end

    function test()
        println("teststest")
    end

    function JulGame.on_shutdown(this::Test)
    end 
end # module