using JulGame.AnimationModule
using JulGame.Macros
using JulGame.Math
using JulGame.MainLoop
using JulGame.SoundSourceModule

mutable struct PlayerMovement
    animator
    canMove
    input
    isFacingRight
    isJump 
    jumpSound
    parent

    function PlayerMovement()
        this = new()

        this.canMove = false
        this.input = C_NULL
        this.isFacingRight = true
        this.isJump = false
        this.parent = C_NULL
        this.jumpSound = SoundSourceModule.SoundSource(joinpath(pwd(),".."), "Jump.wav", 1, 50)

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
        end
    elseif s == :update
        function(deltaTime)
            #println(GetAnimationTest(this.animator.currentAnimation))
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
                if collision.tag == "ground"
                end
            end
        end
    else
        try
            getfield(this, s)
        catch e
            println(e)
        end
    end
end