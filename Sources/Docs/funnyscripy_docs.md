# FunnyScript

## Interpreter
FunnyScript is a language for telling stories.
A FunnyScript file is just called a `script`.
Scripts are interpreted by Funnybot, our app, to generate videos.
FunnyScript is not complicated, but it can be quite verbose...
Luckily, the interpreter can do a few things for you automatically:
* Place characters in the scene where they fit best
* Make them turn left and right
* Move and zoom the camera 

There is no support for audio effects other than dialog.

<!-- interpreter options start -->
### AutoTurn
When enabled, characters will turn automatically towards the nearest action.
You can still add any number of `turn` instruction to your script and those will have precedence over any automatic turn applied by the system in that scene context.
When working with AutoTurn enabled, you should only use `turn` instruction to force behaviors that would not be obvious to the system, such as a character turning away from the person he's having a conversation with.  

### AutoCamera
When enabled, the camera zoom in, out and moves automatically according to what happens in the scene.
When enabled, any `camera directives` are ignored and therefore you don't need to include any in the script.

### AutoPlacement
When enabled, characters that lack a placement (`at`) instruction in the script are placed automatically in the scene where it makes the most sense.
You can still place your characters manually using placement instructions and those will have precedence over any automatic placement applied by the system in that scene context. 
When working with AutoPlacement enabled, you should only use placement instruction to force behaviors that would not be obvious to the system, such as a character appearing in a corner of the screen, falling from the sky, etc.  
<!-- interpreter options end -->

## Subject
Each line of the script needs to have a subject.
A subject must be one of the following:
- The name of single a character, lowercase (such as `roy` or `dan`), see "Subject Directives" 
- The word `scene`, see "Scene Directives"
- The word `overlay`, see "Scene Directives"
- The word `camera`, see "Camera Directives"

A subject cannot refer to a group of subject. For example, if "Roy, Dan and Bella are at the center of the scene", add one line for each character:
```
roy: at centerLeft
dan: at center
bella: at centerRight
```

## Scene Positions
List of available scene positions:
* outsideLeft: Useful for characters walking into the scene from the left
* farLeft
* midLeft
* centerLeft
* center
* midRight
* centerRight
* farRight
* outsideRight: Useful for characters walking into the scene from the right

Plus, a vertical modifier might be added:
* Below: Vertically below the scene
* Bottom: Subject "feet" will touch the bottom of the scene
* Mid: Ground level, this is the default (center and centerMid are equivalent, etc)
* Top: Subject "head" will touch the top of the scene
* Over: Vertically above the scene

Examples of valid positions:
* center (center of the scene, ground level)
* centerLeft
* outsideRightOver (top-right corner of the scene, outside of it's boundaries both vertically and horizontally)
* farRightTop (top-right corner of the scene, inside of it's boundaries both vertically and horizontally)
* ...

## Rendering order
Entities are sorted by their `z-index`, or `z coordinate`, which can be set like other coordinates:
`<subject>: set z <value>`

By default, the z-index for each entity is 0, 100 for overlays therefore:
* Setting a `z > 0` will cause the subject to be rendered in front of other entities
* Setting a `z < 0` will cause the subject to be rendered behind other entities
* Setting a `z > 100` will cause the subject to be rendered in front of any overlays

The z-index is reset automatically when the stage is cleared.

## Stage Directives

### Backgrounds
`scene: background <asset_name>`

Examples:
* `scene: background background_town_park`

### Clear Stage
`scene: clear`

### Pauses
Pauses dont "pause" rendering, they just stop the execution of the next action, allowing, for example, characters to get into position before something else happens.
They can also be used for comedic timing!

`scene: pause <value>`

Examples:
* `scene: pause 1.5`

### Overlays
`overlay: play <animation_name> [<loops>|loop]`

Examples:
* `overlay: play endcard 1`
* `overlay: play endcard loop`

Any visual special effects should be applied with an overlay.
Overlays cannot be used for camera zoom or character animations, they represent a standalone entity.

For example, say a lighting hits the scene, simply do this:
```
overlay: play lighthing_strike 1
``` 

## Subject Directives

### Animations
`<subject>: play <animation_name> [<loops>|loop]`

Examples:
* `andy: play phonecall 1`
* `kyle: play phonecall loop`

### Facial Expressions
FunnyScript supports a limited set of facial expressions for characters:
* `angry`, `andy: play angry`
* `disapponted`, `andy: play disapponted`
* `grin`, `andy: play grin`
* `happy`, `andy: play happy`
* `meh`, `andy: play meh`
* `serious`, `andy: play serious`
* `normal`, `andy: play normal`, which is mostly used to reset the state of the facial expression

### Fade in and out
`<subject>: fade in|out|<value>`

Examples:
* `andy: fade in`
* `andy: fade out`
* `andy: fade 0.3`

### Opacity
`<subject>: opacity <value>`

Examples:
* `andy: opacity 0.5`

### Movement
`<subject>: <walk|run> to <scene_position|entity>`

Examples:
* `andy: walk to center`
* `andy: walk to crow`
* `dan: run to outsideLeft`

### Placement
`<subject>: at <scene_position|entity>`

Examples:
* `andy: at center`
* `andy: at crow`

<!-- facing direction start -->
### Facing direction
`<subject>: turn <direction|entity>`

Examples:
* `andy: turn left`
* `andy: turn crow`

List of available directions:
* left
* right
* front
<!-- facing direction end -->

### Dialogs
`<subject>: "<<emotion>><spoken text>" [<additional_info>]`

Examples:
* `andy: "Hello World!"`
* `andy: "<embarassed>Oh, hi Bella!" he said blushing`
* `dan: "<angrily>Shut up!"`

Do not use custom animations to implement dialogs, like: `bella: play lateral_talk`. Just use a dialog instruction like the examples from before, turning is automatically handled. 

### Coordinates
`<subject>: set <x|y|z> <value>`

Examples:
* `andy: set x 50`
* `overlay: set z 50`

### Offset
`<subject>: offset <x|y|z> <value>`

Examples:
* `andy: offset x 50`
* `andy: offset y -150`

## Camera Directives

### Reset
Restores default configuration.
`camera: reset`

### View
Moves and resizes the camera to a given rectangle.
If the aspect ratio of the selected viewport does not match the aspect ratio of the video, black bars are automatically added.
`camera: [transition] view <w>x<h>+<x>+<y>`

For example (assuming rendering in Full HD):
* `camera: view 1920x1080+0+0` is full screen 
* `camera: view 960x540+480+270` crops the center section of the screen
* `camera: view 1920x731+0+175` crops the top right and bottom parts of the video, appearing in 21:9 with black bars (to fill 16:9)
* `camera: transition view 1920x731+0+175`, same as the above, but smoothly

## Macros
Macros are a set of instructions that can be defined and later injected in the script by simply using their name.
Macros can be injected by simply calling their names

They can be defined with the following syntax:
```
def <macro name>:
    <regular funnyscript>
end
```

Here's an example of macros being used:
```
def scene_andy_room:
    scene: background background_andy_room
    overlay: play none loop
end

def scene_news_studio:
    scene: background background_news_studio
    overlay: play news_studio loop
end

def andy_catch_phrase:
    andy: play shrug
    andy: "This guy!"
end

scene_andy_room
dan: "What are you up to Andy?"
andy_catch_phrase
scene_news_studio
andy: "That's all folks!"
andy_catch_phrase
```

## Comments
Commented lines are ignored by the parser.

Single line comments starts with `#`:
`# This is a comment.`

Multiline comments are surrounded by `/*` and `*/` lines:
```
/*
This is 
a 
multiline comment
*/
```

## Conversion Examples
```
# The Andy walks in from the right
andy: at outsideLeft
andy: walk to centerLeft
```
```
# The Dan flies in from above
dan: at outsideLeftOver
dan: walk to centerLeft
```
```
# Andy and Dan run away
dan: run to outsideLeft
andy: run to outsideLeft
```
```
# The Ikea Master appears and talks to the hero
ikeamaster: at midLeft
ikeamaster: fade in
ikeamaster: "Ah, young one... I sense you are looking for something."
```
