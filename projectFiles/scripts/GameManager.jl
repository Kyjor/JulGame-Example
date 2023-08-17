using JulGame.MainLoop 
using Firebase

mutable struct GameManager
    localPlayerState
    otherPlayers
    parent
    playerId
    results
    roomState
    task
    tickRate
    tickTimer
    user 

    function GameManager()
        this = new()

        this.roomState = C_NULL
        this.tickRate = 12
        this.tickTimer = 0.0
        this.task = C_NULL
        this.otherPlayers = Dict()
        this.localPlayerState = C_NULL
        return this
    end
end

function Base.getproperty(this::GameManager, s::Symbol)
    if s == :initialize
        function()
            MAIN.scene.camera.target = JulGame.TransformModule.Transform(JulGame.Math.Vector2f(-3,2))
            MAIN.cameraBackgroundColor = [0, 128, 128]
            #println("Name: $(MAIN.globals[1])")
            name = MAIN.globals[1]
            #this.localPlayerState = Dict("id" => "local", "name" => name, "direction" => "right", "color" => "blue", "x" => -2, "y" => 7, "coins" => 0)
            Firebase.realdb_init("https://multiplayer-demo-2f287-default-rtdb.firebaseio.com")
            Firebase.set_webapikey("AIzaSyCxuzQNfmIMijosSYn8UWfQGOrQYARJ4iE")
            this.user = Firebase.firebase_signinanon()
            this.localPlayerState = Dict("id" => this.user["localId"], "name" => name, "direction" => "right", "color" => "blue", "x" => -2, "y" => 7, "coins" => 0)
            this.playerId = Firebase.realdb_postRealTime("/players/$(this.user["localId"])", this.localPlayerState, this.user["idToken"])["name"]
        end
    elseif s == :update
        function(deltaTime)
            if this.task != C_NULL # Not sure why this is needed, but it doesn't work without it
                try
                    print("")
                catch e
                    this.task = C_NULL
                    println(e)
                    Base.show_backtrace(stderr, catch_backtrace())
                end
            end
            if this.roomState != C_NULL
                this.processRoomState()
                this.roomState = C_NULL
            end
            this.tickTimer += deltaTime
            if this.tickTimer >= 1/this.tickRate
                this.task = Threads.@spawn this.get()
                this.tickTimer = 0.0
            end
        end
    elseif s == :setParent 
        function(parent)
            this.parent = parent
        end
    elseif s == :get
        function ()
            res = nothing
            try
                res = Firebase.realdb_getRealTime("/players", this.user["idToken"])
            catch e
                print(e)
            end
            this.roomState = res
        end
    elseif s == :updatePos
        function (position)
            #print(this.localPlayerState)
            this.localPlayerState["x"] = position.x
            this.localPlayerState["y"] = position.y

            Firebase.realdb_putRealTime("/players/$(this.user["localId"])/$(this.playerId)", this.localPlayerState, this.user["idToken"])
        end
    elseif s == :processRoomState
        function ()
            for player in this.roomState
                playerId = ""
                for key in keys(player.second) # only loops once
                    playerId = key
                end
                if haskey(player.second, this.playerId) # local player
                    #println(player.second[this.playerId])
                elseif haskey(this.otherPlayers, playerId) # update existing other player
                    #println("update existing player")
                    this.otherPlayers[playerId][1] = player.second[playerId]
                    this.otherPlayers[playerId][2].getTransform().position = JulGame.Math.Vector2f(player.second[playerId]["x"], player.second[playerId]["y"])
                elseif !haskey(this.otherPlayers, playerId) # add new other player
                    println("new player has joined")
                    this.otherPlayers[playerId] = [player.second[playerId], this.spawnOtherPlayer()]
                # todo: remove player
                end
            end
        end
    elseif s == :spawnOtherPlayer
        function ()
            sprite = JulGame.SpriteModule.Sprite(joinpath(pwd(),"..",".."), "characters.png", false)
            sprite.injectRenderer(MAIN.renderer)
            sprite.crop = JulGame.Math.Vector4(16,0,16,16)
            newPlayer = JulGame.EntityModule.Entity("other player", JulGame.TransformModule.Transform(JulGame.Math.Vector2f(-2,7)), [sprite])
            #println(newPlayer)
            push!(MAIN.scene.entities, newPlayer)
            return newPlayer
        end
    elseif s == :onShutDown
        function ()
            println("shut down")
            Firebase.realdb_deleteRealTime("/players/$(this.user["localId"])", this.user["idToken"])
        end
    else
        try
            getfield(this, s)
        catch e
            println(e)
        end
    end
end