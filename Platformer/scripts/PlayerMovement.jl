using JulGame.AnimationModule
using JulGame.AnimatorModule
using JulGame.RigidbodyModule
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
    jumpVelocity
    jumpSound
    parent

    xDir
    yDir

    function PlayerMovement(jumpVelocity = -5)
        this = new()

        this.canMove = false
        this.input = C_NULL
        this.isFacingRight = true
        this.isJump = false
        this.parent = C_NULL
        this.jumpSound = SoundSourceModule.SoundSource("Jump.wav", 1, 50)
        this.jumpVelocity = jumpVelocity

        this.xDir = 0
        this.yDir = 0

        return this
    end
end

function Base.getproperty(this::PlayerMovement, s::Symbol)
    if s == :initialize
        function()
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
            this.canMove = true
            x = 0
            speed = 5
            input = MAIN.input

            # Inputs match SDL2 scancodes after "SDL_SCANCODE_"
            # https://wiki.libsdl.org/SDL2/SDL_Scancode
            # Spaces full scancode is "SDL_SCANCODE_SPACE" so we use "SPACE". Every other key is the same.
            if ((input.getButtonPressed("SPACE")  || input.button == 1)|| this.isJump) && this.parent.getRigidbody().grounded && this.canMove 
                this.animator.currentAnimation.animatedFPS = 0
                ForceFrameUpdate(this.animator, 2)
                this.jumpSound.toggleSound()
                AddVelocity(this.parent.getRigidbody(), Vector2f(0, this.jumpVelocity))
            end
            if (input.getButtonHeldDown("A") || input.xDir == -1) && this.canMove
                if input.getButtonPressed("A")
                    ForceFrameUpdate(this.animator, 2)
                end
                x = -speed
                if this.parent.getRigidbody().grounded
                    this.animator.currentAnimation.animatedFPS = 5
                end
                if this.isFacingRight
                    this.isFacingRight = false
                    this.parent.getSprite().flip()
                end
            elseif (input.getButtonHeldDown("D")  || input.xDir == 1) && this.canMove
                if input.getButtonPressed("D")
                    ForceFrameUpdate(this.animator, 2)
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
                ForceFrameUpdate(this.animator, 1)
            end
            
            SetVelocity(this.parent.getRigidbody(), Vector2f(x, this.parent.getRigidbody().getVelocity().y))
            x = 0
            this.isJump = false
            if this.parent.getTransform().position.y > 8
                this.parent.getTransform().position = Vector2f(1, 4)
            end
        end
    elseif s == :setParent
        function(parent)
            this.parent = parent
            collisionEvent = @argevent (col) this.handleCollisions(col)
            this.parent.getComponent(Collider).addCollisionEvent(collisionEvent)
        end
    elseif s == :handleCollisions
        function(otherCollider)
            if otherCollider.tag == "ground"
            end
        end
    else
        getfield(this, s)
    end
end