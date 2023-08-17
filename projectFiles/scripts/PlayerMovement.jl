using JulGame.Macros
using JulGame.MainLoop
using JulGame.SoundSourceModule
using Firebase
using HTTP

# Firebase.realdb_deleteRealTime("/players/$(user["localId"])", user["idToken"])
mutable struct PlayerMovement
    animator
    canMove
    input
    isFacingRight
    isJump 
    jumpSound
    parent
    playerId
    user 
    test 
    results
    roomState

    function PlayerMovement()
        this = new()

        this.canMove = false
        this.input = C_NULL
        this.isFacingRight = true
        this.isJump = false
        this.parent = C_NULL
        this.jumpSound = SoundSourceModule.SoundSource(joinpath(pwd(),"..",".."), "Jump.wav", 1, 50)
        this.test = C_NULL
        this.results = Channel()
        this.roomState = C_NULL

        return this
    end
end

function Base.getproperty(this::PlayerMovement, s::Symbol)
    if s == :initialize
        function()
            #println("PlayerMovement initialize")
            event = @event begin
                #this.jump()
            end
            MAIN.scene.camera.target = this.parent.getTransform()
            this.animator = this.parent.getAnimator()
            this.animator.currentAnimation = this.animator.animations[1]
            this.animator.currentAnimation.animatedFPS = 0

            Firebase.realdb_init("https://multiplayer-demo-2f287-default-rtdb.firebaseio.com")
            Firebase.set_webapikey("AIzaSyCxuzQNfmIMijosSYn8UWfQGOrQYARJ4iE")
            this.user = Firebase.firebase_signinanon()
            initialPlayerState = Dict("id" => this.user["localId"], "name" => "toto", "direction" => "right", "color" => "blue", "x" => 3, "y" => 3, "coins" => 0)
            this.playerId = Firebase.realdb_postRealTime("/players/$(this.user["localId"])",initialPlayerState, this.user["idToken"])["name"]
        end
    elseif s == :update
        function(deltaTime)
            if this.test != C_NULL
                try
                    print("")
                    #wait(this.test)
                catch e
                    this.test = C_NULL
                    println(e)
                    Base.show_backtrace(stderr, catch_backtrace())
                end
            end
            if this.roomState != C_NULL
                println(this.roomState)
                this.roomState = C_NULL
            end

            this.canMove = true
            x = 0
            speed = 5
            input = MAIN.input
            y = this.parent.getRigidbody().getVelocity().y
            # Inputs match SDL2 scancodes after "SDL_SCANCODE_"
            # https://wiki.libsdl.org/SDL2/SDL_Scancode
            # Spaces full scancode is "SDL_SCANCODE_SPACE" so we use "SPACE". Every other key is the same.
            if (input.getButtonPressed("SPACE")|| this.isJump) && this.parent.getRigidbody().grounded && this.canMove 
               
                this.animator.currentAnimation.animatedFPS = 0
                this.animator.forceSpriteUpdate(2)
                this.jumpSound.toggleSound()

                this.parent.getRigidbody().grounded = false
                y = -5.0
                user = this.user
                # @async begin
                #     #print("\$(this.user["idToken"])\n")
                #     try
                #         print("test")
                #         Firebase.realdb_getRealTime("/players", this.user["idToken"])
                #     catch e
                #         print(e)
                #         Base.show_backtrace(stderr, catch_backtrace())
                #     end

                # end
                this.test = Threads.@spawn this.get()
                # this.test = @async begin 
                #         Firebase.realdb_getRealTime("/players", this.user["idToken"])
                #         print("hi")
                # end
                # @async begin
                #     print("hi")
                #     initialPlayerState = Dict("id" => this.user["localId"], "name" => "toto", "direction" => "right", "color" => "blue", "x" => 3, "y" => 3, "coins" => 0)
                #     test = Firebase.realdb_postRealTime("/players/$(this.user["localId"])",initialPlayerState, this.user["idToken"])["name"]
                # end
                # #println(this.test)
            end
            if input.getButtonHeldDown("A") && this.canMove
                if input.getButtonPressed("A")
                    this.animator.forceSpriteUpdate(2)
                end
                x = -speed
                if this.parent.getRigidbody().grounded
                    this.animator.currentAnimation.animatedFPS = 5
                end
                if this.isFacingRight
                    this.isFacingRight = false
                    this.parent.getSprite().flip()
                end
            elseif input.getButtonHeldDown("D") && this.canMove
                if input.getButtonPressed("D")
                    this.animator.forceSpriteUpdate(2)
                end
                if this.parent.getRigidbody().grounded
                    this.animator.currentAnimation.animatedFPS = 5
                end
                x = speed
                if !this.isFacingRight
                    this.isFacingRight = true
                    this.parent.getSprite().flip()
                end
            elseif this.parent.getRigidbody().grounded
                this.animator.currentAnimation.animatedFPS = 0
                this.animator.forceSpriteUpdate(1)
            end
            
            this.parent.getRigidbody().setVelocity(Vector2f(x, y))
            x = 0
            this.isJump = false
            if this.parent.getTransform().position.y > 8
                this.parent.getTransform().position = Vector2f(1, 4)
            end
        end
    elseif s == :setParent
        function(parent)
            this.parent = parent
            collisionEvent = @event begin
                this.handleCollisions()
            end
            this.parent.getComponent(Collider).addCollisionEvent(collisionEvent)
        end
    elseif s == :handleCollisions
        function()
            return
            collider = this.parent.getComponent(Collider)
            for collision in collider.currentCollisions
                if collision.tag == "coin"
                end
            end
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
    else
        try
            getfield(this, s)
        catch e
            println(e)
        end
    end
end