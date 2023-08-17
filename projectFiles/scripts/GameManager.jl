using JulGame.MainLoop 
using Firebase

mutable struct GameManager
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
        this.tickRate = 2
        this.tickTimer = 0.0
        this.task = C_NULL
        this.otherPlayers = Dict()

        return this
    end
end

function Base.getproperty(this::GameManager, s::Symbol)
    if s == :initialize
        function()
            Firebase.realdb_init("https://multiplayer-demo-2f287-default-rtdb.firebaseio.com")
            Firebase.set_webapikey("AIzaSyCxuzQNfmIMijosSYn8UWfQGOrQYARJ4iE")
            this.user = Firebase.firebase_signinanon()
            initialPlayerState = Dict("id" => this.user["localId"], "name" => "toto", "direction" => "right", "color" => "blue", "x" => 3, "y" => 3, "coins" => 0)
            this.playerId = Firebase.realdb_postRealTime("/players/$(this.user["localId"])",initialPlayerState, this.user["idToken"])["name"]
            MAIN.cameraBackgroundColor = [252, 223, 205]
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
    elseif s == :processRoomState
        function ()
            for player in this.roomState
                playerId = ""
                for key in keys(player.second) # only loops once
                    playerId = key
                end
                if haskey(player.second, this.playerId) # local player
                    println("my player")
                    println(player.second[this.playerId])
                elseif haskey(this.otherPlayers, playerId) # update existing other player
                    println("update existing player")
                    this.otherPlayers[playerId] = player.second[playerId]
                elseif !haskey(this.otherPlayers, playerId) # add new other player
                    println("new player has joined")
                    this.otherPlayers[playerId] = player.second[playerId]
                    this.spawnOtherPlayer()
                # todo: remove player
                end
            end
        end
    elseif s == :spawnOtherPlayer
        function ()
            println("spawn")
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