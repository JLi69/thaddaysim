# THADDaySim (Totally Historically Accurate D-Day Simulator)

A turn-based strategy game made with Godot where two players control the Axis
and the Allies.

## How to Play

The main goal of the game is for the Allies to capture the flag at the far left
end of the map (or kill all of the Axis) and for the Axis to kill all of the 
Allies.

The Allies have four actions: Move, Shoot, Heal, and Grenade. Allies can move
to any square that is within a 9 x 9 square around them. They can shoot within
3 tiles in the up, down, right, or left directions. Additionally, they can
heal any of their comrades within 2 tiles in the up, down, right, or left
directions and also throw grenades at positions (+-4, +-4) from their current
position. Grenades explode and deal damage to any soldier within a 5 x 5 square.

The Allies will always have the first turn and get to move all their units and
have each of their units take one of the four actions listed above. Following
that, the Axis get their turn and issue orders to their units.

The Axis have four actions: Move, Shoot, Build, and Landmine. The moving and
shooting are basically the same as the Allies except the Axis have a larger range
for shooting and moving (Axis soldiers can move within a 13 x 13 square and can
shoot up to 4 tiles away). Axis soldiers can place landmines in any available
adjacent tile to their unit. If this landmine is stepped on by any soldier,
then it will explode and damage any neighboring soldiers and fortifications
(brick fortifications are indestructible) within a 5 x 5 square. The Axis soldiers
can also build fortifications within a 7 x 7 square and these fortifications will
block movement until they are destroyed (they require two hits from a landmine
or two hits from shooting to be destroyed).

## Controls

Most of the game is mouse oriented, you issue orders by clicking on buttons
and clicking on the tile you want the unit to move to/shoot at/build to/etc.

You can pan the camera by using W,A,S,D or you can hold down middle mouse and
move the mouse around. You can zoom in and out with the scroll wheel.

Whenever an action is completed, the game will attempt to zoom onto the next
unit but if you want to cancel this process, hit space bar.
