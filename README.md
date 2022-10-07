# Godot Sidescroller Movement
## Info
This is a demo with the current setup I use for movement in sidescroller/2D platformer player characters. 

Art (character and tiles) made by [Buch](https://opengameart.org/users/buch) on OpenGameArt.

## Setup
The project is set up with a simple tilemap and a player character, both under the root node Game, and can be run as is.

The player script has comments explaining its functionality. Various physics parameters can be changed directly on the editor.

Buttons are setup in code as left and right arrow keys for movement, and up arrow key for jump. Those can be changed on the Player.gd script.

## Parameter tweaking
### Max speed, Acceleration, Friction
Max speed refers to how fast the player can move at top speed. Acceleration refers to how fast the player arrives at the max speed. Friction is the opposite of acceleration, how fast it takes for a moving object to go back to standing still.

For the character to take longer to reach top speed, lower the acceleration. If you want the movement to feel slippery, try lowering the friction, it's like walking on ice!

### Gravity, Max fall speed, Jump force, Min air distance
Gravity is just like real gravity! (Kind of.) Max fall speed is the maximum speed at which the player can fall, think of it as its terminal velocity. Jump force is the amount of force the player character will have going upwards when they jump. Min air distance is a value that dictates the minimum jump height.

Lowering the gravity or max fall speed will make the jump feel floatier. Raising jump force will make the character jump higher. Mix and match until it feels just right.

When letting go of the jump button before reaching maximum height, the player character starts falling. Min air distance is how high the jump is even if pressed for a single frame. 

## Other settings
The camera has no special settings. It's a child of the player node in order to follow it. Its limits are set on _ready() so it doesn't go out of the tilemap area.

In order to animate the player, an animation tree node was used. The state machine in that animation tree node mirrors the state machine of the player character itself. It has a simple script to simplify the animation setting functions called on the Player.gd script.

## Features I'll add
<ol>
  <li>Wall jumping</li>
  <li>Coyote jump and jump buffer</li>
  <li>Health, damage (with some spikes)</li>
  <li>Knockback</li>
  <li>More map to play around on</li>
  <li>Maybe some other stuff!</li>
</ol> 
