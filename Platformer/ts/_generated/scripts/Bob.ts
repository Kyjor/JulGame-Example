import { registerScript } from "julgame/src/engine/runtime/scriptRegistry";


    // using JulGame
    export class Bob {
        parent // do not remove this line, this is a reference to the entity that this script is attached to
        // This is where you define your script's fields
        // Example: speed: number
        elapsedTime
        startingY
        isBobbing: boolean

        constructor() {
             // do not remove this line
            
            // this is where you initialize your script's fields
            // Example: this.speed = 1.0
            this.elapsedTime = 0.0
            this.isBobbing = true

            return this // do not remove this line
        }
    }

    // This is called when a scene is loaded, or when script is added to an entity
    // This is where you should register collision events or other events
    // Do not remove this function
    function JulGame_initialize_Bob(self: Bob) {
        self.startingY = self.parent.sprite.offset.y
    }

    // This is called every frame
    // Do not remove this function
    function JulGame_update_Bob(self: Bob, deltaTime) {
        if (!self.isBobbing) {
            return
        }
        return

        bob(self)
        self.elapsedTime += deltaTime
    }

    // This is called when the script is removed from an entity (scene change, entity deletion)
    // Do not remove this function
    function JulGame_on_shutdown_Bob(self: Bob) {
    } 

    function bob(self: Bob) {
        // Define bobbing parameters
        let bobHeight = -0.20  // The maximum height the item will bob
        let bobSpeed = 3.0   // The speed at which the item bobs up and down
        let minBobHeight = -0.10

        // Calculate a sine wave for bobbing motion
        let bobOffset = minBobHeight + bobHeight * (1.0 - Math.cos(bobSpeed * self.elapsedTime)) / 2.0

        // Update the item's Y-coordinate
        self.parent.sprite.offset = {x: self.parent.sprite.offset.x, y: self.startingY + bobOffset}
    }
registerScript("Bob", {
    create: () => new Bob(),
    initialize: JulGame_initialize_Bob,
    update: JulGame_update_Bob,
    onShutdown: JulGame_on_shutdown_Bob,
});
