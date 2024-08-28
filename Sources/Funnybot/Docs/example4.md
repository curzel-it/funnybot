Input concept:
```
It's taco day at Obscureville High

Andy, Bella, and Roy are discussing how incredibly delicious the tacos are.

THEREFORE, they decide to ask Chef what makes these tacos so special.

BUT upon questioning, Chef admits there's no secret ingredient, it's just a recipe he found in an old dusty book from the school library that he found in the kitchen.

BUT as that discussion takes place, they spot Dan giving a speech to other students "Let me tell you, these tacos are a gift from the heavens! Praise the almighty taco!"

What the hell is Dan up to?

THEREFORE, intrigued and a bit concerned, the guys decide to look in the school library for taco recipes.

BUT as they look around some books, the librarian tells them their friend came in to get "Ancient Taco-Demon Summoning Rituals" a few days ago.

THEREFORE they decide to confront Dan about it, thinking he's trying to troll people again.

BUT they overhear a conversation about a "ritual" taking place in the cafeteria later that night.

THEREFORE they decide to sneak into the cafeteria that night to investigate.

[...]
```

Your output script:
```
/*
It's taco day at Obscureville High

Andy, Bella, and Roy are discussing how incredibly delicious the tacos are.

THEREFORE, they decide to ask Chef what makes these tacos so special.

BUT upon questioning, Chef admits there's no secret ingredient, it's just a recipe he found in an old dusty book from the school library that he found in the kitchen.

BUT as that discussion takes place, they spot Dan giving a speech to other students "Let me tell you, these tacos are a gift from the heavens! Praise the almighty taco!"

What the hell is Dan up to?
*/
scene: background background_cafeteria
taco_plate: set x 70
taco_plate: set y 80
taco_plate: play front loop
taco_plate: set z -1
taco_plate2: set x 120
taco_plate2: set y 85
taco_plate2: play front loop
taco_plate2: set z -1
taco: set x 335
taco: set y 140
taco: play front loop
taco: scale 0.5
taco: set z 50
taco: opacity 0
andy: at centerLeft
bella: at center
bella: offset x 15
roy: at midRight
ape_chef: at outsideLeft
ape_chef: offset x -50
dan: scale 0.5
kyle: scale 0.5
jake: scale 0.5
dan: at centerRightHigh
dan: offset x -60
dan: offset y -10
kyle: at centerLeftHigh
kyle: offset x 25
kyle: offset y -15
jake: at centerLeftHigh
jake: offset x 55
jake: offset y 10
kyle: turn to right
jake: turn to right
dan: turn to left
kyle: opacity 0
jake: opacity 0
dan: opacity 0
andy: play eat loop
bella: play eat loop
roy: play eat loop
ape_chef: walk to midLeft
andy: "Holy shit, these tacos are amazing!"
andy: turn to ape_chef
andy: play lateral_talk loop
andy: "I need the recipe chef!"
andy: play lateral loop
camera: transition view 160x90+50+90
ape_chef: "It seems to me you're eating leaves, milk and a cheesburger...?"
andy: play front_still loop
bella: turn to ape_chef
bella: play angry_talk loop
bella: "Hey! The animation budget is what it is!"
ape_chef: "Yeah, sure, I'm glad you liked them."
bella: play eat loop
andy: turn left
andy: "So, what's the secret?"
ape_chef: "Secret? There ain't no secret. It's just some recipe from a book I found in the kitchen this morning"
bella: "Oh! And... can we have it?"
ape_chef: "Unfortunately no, I can't find it anywhere! I don't even remember the title..."
camera: transition view 320x180+0+0
roy: walk to centerRight
roy: "Books don't just `disappear`, Chef, come on!"
ape_chef: "Talk to the librarian, she might have brought it back to the library"
bella: play worried_talk
camera: transition view 160x90+100+90
bella: "Wait, what? The dusty old library has cook books?"
bella: play worried
camera: transition view 160x90+50+90
ape_chef: "Damn, it's a library, of course it does..."
kyle: fade in
jake: fade in
dan: fade in
taco: fade in
ape_chef: walk to outsideLeft
roy: walk to outsideRight
bella: walk to outsideRight
andy: walk to outsideRight 
camera: transition view 320x180+0+0
roy: "Well, you heard it here first folks. The secret to amazing food is buried in the dust and dirt of history."
dan: play front_still_talk loop
camera: transition view 160x90+80+30
dan: "Let me tell you, brothers..!"
dan: "These tacos are a gift from the heavens!" Enthusiastically said to the crowd
andy: walk to farRight
dan: play front loop
kyle: "Praise the almighty taco!"
dan: play front_still_talk loop
dan: "Praise the almighty taco!"
dan: play front loop
jake: play front_talk loop
jake: "Praise the almighty taco!"
jake: play front loop
camera: transition view 160x90+160+90
andy: "What the hell is Dan up to?" Andy questioning rhetorically looking at Bella and Roy
andy: walk to outsideRight
scene: pause 0.2
scene: clear

/*
THEREFORE, intrigued and a bit concerned, the guys decide to look in the school library for taco recipes.

BUT as they look around some books, the librarian tells them their friend came in to get "Ancient Taco-Demon Summoning Rituals" a few days ago.

THEREFORE they decide to confront Dan about it, thinking he's trying to troll people again.
*/
scene: background background_school_library
sheep: at midLeft
andy: at outsideRight
bella: at farRight
roy: at farRight
roy: offset x 50
andy: walk to center
bella: walk to midRight
roy: walk to centerRight
andy: "First thing on the agenda, find the book!"
bella: "This place gives me the creeps. Who the hell still uses a library?"
camera: transition view 160x90+140+90
bella: play sleep loop
roy: play texting loop
andy: walk to centerLeft
camera: transition view 160x90+20+90
andy: "Let's ask the librarian, she will know... Excuse me, ma'am, we're looking for a book with taco recipes."
sheep: "Of course, boys!"
sheep: walk to farLeft
camera: transition view 160x90+0+90
scene: pause 0.2
sheep: "Here you go, all the books on Mexican cuisine."
andy: walk to sheep
sheep: walk to outsideLeft
andy: "Alright, thanks."
sheep: walk to farLeft
sheep: "Um, boys..."
scene: pause 0.1
andy: turn librarian
roy: turn librarian
sheep: "Please remember your friend to bring me back 'Rituals and Recipes of Ancient Demonology', it's due today"
camera: transition view 320x180+0+0
andy: play panic loop
bella: play worried loop
roy: play lateral_talk loop
roy: "What the fuck did you just say?"
roy: play lateral loop
sheep: "Rituals and Recipes of... Ancient Demonology?"
sheep: walk to outsideLeft
camera: transition view 160x90+160+90
bella: play angry loop
bella: "Dan! Of course, it has to be Dan!"
andy: run to outsideRight
bella: run to outsideRight
roy: run to outsideRight
roy: "Told you they where TOO good to be true!"
scene: pause 1.5
scene: clear

/*
BUT they overhear a conversation about a "ritual" taking place in the cafeteria later that night.

THEREFORE they decide to sneak into the cafeteria that night to investigate.
*/
scene: background background_school_lockers
camera: view 160x90+80+80
andy: at center
andy: offset y 45
bella: at centerLeft
bella: offset y 45
roy: at centerRight
roy: offset y 45
roy: turn left
roy: "I'm sure Dan's just trying to troll the whole school again"
kyle: at outsideRight
jake: at outsideRight
jake: offset x -60
jake: set z 20
kyle: set z 20
kyle: walk to outsideLeft
jake: walk to outsideLeft
andy: "Wait... do you guys hear that?" said softly and gestured towards a door
camera: transition view 320x180+0+0
kyle: "Dan said to come in later tonight, we have to wear these capes"
jake: "Are there going to be more tacos?"
kyle: "Yes, just be there in time for the ritual"
roy: turn sloth
roy: "A... ritual?" uttering quietly in disbelief.
camera: view 160x90+80+80
bella: play worried_talk loop 
bella: "No way... Is this what they needed the book for?" 
bella: play worried loop 
andy: "We have to see for ourselves. Tonight, at the cafeteria."
scene: pause 1.5
scene: clear

[...]
```
