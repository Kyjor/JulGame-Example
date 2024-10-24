module BobModule
    using ..JulGame
    mutable struct Bob
        parent # do not remove this line, this is a reference to the entity that this script is attached to
        # This is where you define your script's fields
        # Example: speed::Float64
        elapsedTime
        startingY
        isBobbing::Bool

        function Bob()
            this = new() # do not remove this line
            
            # this is where you initialize your script's fields
            # Example: this.speed = 1.0
            this.elapsedTime = 0.0
            this.isBobbing = true

            return this # do not remove this line
        end
    end

    # This is called when a scene is loaded, or when script is added to an entity
    # This is where you should register collision events or other events
    # Do not remove this function
    function JulGame.initialize(this::Bob)
        this.startingY = this.parent.sprite.offset.y
    end

    # This is called every frame
    # Do not remove this function
    function JulGame.update(this::Bob, deltaTime)
        if !this.isBobbing 
            return
        end
        return

        bob(this)
        this.elapsedTime += deltaTime
    end

    # This is called when the script is removed from an entity (scene change, entity deletion)
    # Do not remove this function
    function JulGame.on_shutdown(this::Bob)
    end 

    function bob(this::Bob)
        # Define bobbing parameters
        bobHeight = -0.20  # The maximum height the item will bob
        bobSpeed = 3.0   # The speed at which the item bobs up and down
        minBobHeight = -0.10

        # Calculate a sine wave for bobbing motion
        bobOffset = minBobHeight + bobHeight * (1.0 - cos(bobSpeed * this.elapsedTime)) / 2.0

        # Update the item's Y-coordinate
        this.parent.sprite.offset = JulGame.Math.Vector2f(this.parent.sprite.offset.x, this.startingY + bobOffset)
    end
end

