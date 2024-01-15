using JulGame.Component 
using JulGame.EntityModule 
using JulGame.MainLoop 
using JulGame.Math
using JulGame.UI

mutable struct GameManager
    parent

    function GameManager()
        this = new()

        return this
    end
end

function Base.getproperty(this::GameManager, s::Symbol)
    if s == :initialize
        function()
            MAIN.cameraBackgroundColor = [252, 223, 205]
            push!(MAIN.scene.screenButtons, ScreenButtonModule.ScreenButton("ButtonUp.png", "ButtonDown.png", Vector2(256, 64), Vector2(), joinpath("FiraCode", "ttf", "FiraCode-Regular.ttf"), "test"))
            ent = Entity("test", TransformModule.Transform(Vector2f(7,6)))
            push!(MAIN.scene.entities, ent)
            MAIN.scene.entities[57].addShape(ShapeModule.Shape(Math.Vector3(0,0,0), Math.Vector2f(1,1), false, true, Math.Vector2f(0,0), Math.Vector2f(0,0)))
            text = TextBoxModule.TextBox("test", joinpath("FiraCode", "ttf", "FiraCode-Regular.ttf"), 64, Math.Vector2(), "test", true, true; isWorldEntity=true)
            push!(MAIN.scene.textBoxes, text)
            text.setColor(100,100,100)
        end
    elseif s == :update
        function(deltaTime)
        end
    elseif s == :setParent 
        function(parent)
            this.parent = parent
        end
    else
        getfield(this, s)
    end
end