Input concept:
```
Bella tells Andy and Roy her new boyfriend, Phil has invited her over for Netflix and Chill
THEREFORE Bella thinks the night is going to get hot
BUT When Bella and Phil go to the livingroom, Phil’s supsicious uncle is at home with them for some reason
BUT the uncle goes to the basement and leaves them alone
THEREFORE Bella and Phil start watching a movie
BUT they hear noises coming from the basement
THEREFORE they go check
BUT They see Phil’s uncle watering his plants, turns out he grows catnip, a lot of it
THEREFORE they steal som, just for fun
BUT the day after Phil is not at school
THEREFORE Bella tells Andy and Roy about the story and they go check on Phil
Roy gets some catnip from Bella
After school, Bella and Andy arrive at Phil's house, they find the door wide open
THEREFORE they cautiously enter, fearing that something might have happened to Phil
BUT as they search the house, they stumble upon Phil's uncle corpse
BUT as they get near to check, it turns into a zombie
The zombie starts to whisper about being hungry and starts walking towards them
THEREFORE Bella and Andy scream and run for their lives and lock themself in the kitchen
BUT the zombie uncle is too slow to catch them, he’s dead after all
THEREFORE they decide to kill him
BUT they realize they don't know how to kill a zombie
THEREFORE they call Roy, the expert in all things supernatural and conspiratorial, but he does not answer the phone
BUT just as they're about to finish off the "zombie" uncle, Phil appears
THEREFORE Phil stops them and explains that his uncle isn't a zombie, but is just extremely stoned from the supernatural catnip, and he was too that’s why he missed school earlier.
BUT the group is skeptical and unsure whether to believe Phil
BUT Bella realises she smoked catnip Roy earlier at school today, and he does not answer the phone
THEREFORE they decide to look for Roy, leaving Phil’s uncle behind

BUT as they leave Phil's house, Bella mentioned that Roy and Dan were meeting at the pub
THEREFORE they decided to go there to find them.

At the pub, they notice the environment is quiet, surprisingly quiet
BUT suddenly the bartender walks into the scene and as they order they realise he’s also turned into a zombie.
THEREFORE they run out of the pub, fearing for their lives.

BUT before they could make it far enough, they are suddenly surrounded by a horde of zombies from left and right
THEREFORE they run into an alleyway but get cornered.

Just then, Bella remembers that they left Phil's uncle alone at the house
THEREFORE she decides to call him since he might be their only chance at survival.
Uncle picks up, asks if they've seen the "Land of the dead"
The guys didn't see it
Uncle says they will figure it out and hangs up
Roay was turned into a zombie.

Just as they're about to lose hope, they see a bright light from afar and immediately beautiful display of fireworks.
The zombies, feeling attracted to the lights, are distracted and start moving in the other direction.

In this chaos, Phil’s uncle swiftly pulls up in a car, yelling for the group to get in
THEREFORE they all jump in the car and drive away just in time, leaving behind the chaos and the popcorn fireworks.

Phil's Uncle, Bella and Phil give the morale of the episode.
```

Your output script:
```
/*
Bella tells Andy and Roy her new boyfriend, Phil has invited her over for Netflix and Chill
THEREFORE Bella thinks the night is going to get hot
*/
scene: background background_outside_school
andy: at centerLeft
roy: at center
bella: at farRight
bella: walk to centerRight
bella: "Guys, I've got some news!" 
andy: turn to cat_blue
roy: turn to cat_blue
bella: play lateral_talk loop
camera: transition view 160x90+100+90
bella: "Phil has invited me over to his place for some Netflix and chill."
bella: play lateral loop
roy: turn to cat_blue
roy: "Don't forget the popcorn! You know, just in case you REALLY end up watching the movie!"
andy: turn to cat_blue
andy: "Haha! And don't forget to make sure his 'Tv' is big enough!"
bella: "What the hell are you guys talking about... It's just a movie, it's not that hard..."
scene: pause 3
andy: "Oh Bella, pretty hard I hope! You're about to learn so, so much!"
bella: "You guys are ridiculous."
bella: walk to outsideRight
scene: pause 1
scene: clear

/*
BUT When Bella and Phil go to the livingroom, Phil’s supsicious uncle is at home with them for some reason
BUT the uncle goes to the basement and leaves them alone
THEREFORE Bella and Phil start watching a movie
BUT they hear noises coming from the basement
THEREFORE they go check
*/
scene: background background_phil_livingroom
sofa: scale 2
sofa: at center
sofa: play back loop
sofa: offset y 10
sofa: set z -1
bella: at outsideLeft
bella: walk to centerLeft
cat_calico: at center
phil's uncle: at midRight
phil's uncle: play sleep loop
cat_calico: turn to cat_blue
bella: "Ehm, hi Phil...!" she said, super embarrassed
cat_calico: "Hello Bella"
scene: pause 1
phil's uncle: walk to midRight
bella: "I wasn't expecting... An audience."
camera: transition view 160x90+160+90
cat_calico: turn to cat_grumpy
phil's uncle: "And I wasn't expecting a show, but here we are!"
scene: pause 1
cat_calico: turn to cat_blue
camera: view 160x90+80+90
cat_calico: "Just... Give me a second Bella..."
camera: transition view 160x90+160+90
cat_calico: walk to cat_grumpy
scene: pause 1.5
cat_calico: play angry_talk loop
cat_calico: "Uncle, you're kinda killing the mood here" said whispering
cat_calico: play front loop
phil's uncle: walk to outsideRight
phil's uncle: "Oh, no worries, I'll be in the basement if you need me"
camera: transition view 160x90+80+90
bella: turn to cat_calico
cat_calico: walk to cat_blue
cat_calico: "Finally alone..."
scene: pause 5
camera: reset
sofa: set z 70
cat_calico: offset x -25
bella: offset x 75
bella: offset y 60
cat_calico: offset y 60
cat_calico: play worried_talk loop
cat_calico: "Did you hear that?" He asked in a low whisper
cat_calico: play worried loop
bella: play worried_talk loop
bella: "Yeah, what was that?" She whispered back, nudging closer to Phil
bella: play worried loop
cat_calico: play worried_talk loop
cat_calico: "I think it's coming from the basement."
cat_calico: play worried loop
bella: "Phil, I think we should check it out." She said sternly
bella: walk to outsideRight
cat_calico: play worried_talk loop
cat_calico: "Wait up, what about the 'and Chill' part of the deal...!?"
cat_calico: play worried loop
scene: pause 3
scene: clear

/*
BUT They see Phil’s uncle watering his plants, turns out he grows catnip, a lot of it
THEREFORE they steal som, just for fun
*/
scene: background background_basement_greenhouse
catnip: at center
catnip: offset x 25
catnip: set z -1
bella: at midLeft
cat_calico: at farLeft
bella: walk to centerLeft
cat_calico: walk to center
cat_calico: "Uncle? Is everything alright?"
bella: walk to centerLeft
cat_calico: walk to center
bella: play love_talk loop
bella: "Oh my God, is that... catnip?"
bella: play love loop
cat_calico: "High end, hydroponic, premium strains. Say hello to my Uncle's side hustle!"
bella: play love_talk loop
bella: "Let's steal some!"
bella: play love loop
cat_calido: turn to cat_blue
cat_calico: "I don't know about that, this stuff is pretty wild!"
scene: pause 0.5
scene: clear

/*
BUT the day after Phil is not at school
THEREFORE Bella tells Andy and Roy about the story and they go check on Phil
Roy gets some catnip from Bella
*/
scene: background background_school_lockers
bella: at farLeft
andy: at centerRight
roy: at center
roy: offset x 20
bella: walk to centerLeft
roy: turn cat_blue
andy: offset y 10
camera: transition view 160x90+100+90
andy: "Hey Bella! What's up?" 
camera: transition view 160x90+80+90
bella: "Phil isn't at school today..." 
andy: play shrug 1
andy: turn cat_blue
camera: transition view 160x90+100+90
roy: "Had you guys reminded me about the test I would have skipped school today too, you know?"
camera: transition view 160x90+80+90
bella: "It's a bit strange guys, you won't believe it, but last night we found out Phil's uncle is growing tons of catnip, maybe he got caught..."
camera: transition view 160x90+100+90
andy: play panic_talk loop
andy: "What?!"
andy: play panic loop
roy: "Are you shitting me?!" 
bella: "No, I swear! I even filled my bag with it HAHAHA!"
roy: "Can I pocket some?" 
bella: "You damn freeloader, ok"
andy: turn bella
roy: turn bella
andy: play front_still_talk loop
andy: "Let's go check on Phil after school"
andy: play front_still loop
roy: "I'll wait for you guys at the pub" 
bella: "Ok!"
scene: pause 0.5
scene: clear

/*
After school, Bella and Andy arrive at Phil's house, they find the door wide open
THEREFORE they cautiously enter, fearing that something might have happened to Phil
BUT as they search the house, they stumble upon Phil's uncle corpse
BUT as they get near to check, it turns into a zombie
The zombie starts to whisper about being hungry and starts walking towards them
THEREFORE Bella and Andy scream and run for their lives
*/
scene: background background_phil_livingroom
camera: view 160x90+0+90
sofa: at center
sofa: play back loop
sofa: offset y 10
sofa: set z -1
andy: at farLeft
bella: at outsideLeft
cat_grumpy_zombie: at centerRight
cat_grumpy_zombie: set y 5
cat_grumpy_zombie: play dead loop
andy: walk to midLeft
bella: walk to farLeft
andy: "The door is wide open..."
bella: "And this smell..."
andy: "Hello? Anybody home?"
camera: transition view 320x180+0+0
bella: play worried_talk loop
bella: "OH MY GOD! Is that, is that Phil's uncle?"
bella: play worried loop
andy: play panic_talk loop
andy: "I think I’m gonna throw up… This is messed up… This is so messed up"
andy: play panic loop
bella: walk to cat_grumpy_zombie
andy: walk to cat_grumpy_zombie
cat_grumpy_zombie: play dead_talk loop
cat_grumpy_zombie: "Hungry...so...hungry..."
andy: "Did he just... TALK?!"
cat_grumpy_zombie: play front loop
bella: "LET'S FUCKING RUN!" 
cat_grumpy_zombie: walk to outsideLeft
bella: run to outsideLeft
andy: run to outsideLeft
scene: pause 0.5
scene: clear

/*
... and lock themself in the kitchen
BUT the zombie uncle is too slow to catch them, he’s dead after all
THEREFORE they decide to kill him
BUT they realize they don't know how to kill a zombie
THEREFORE they call Roy, the expert in all things supernatural and conspiratorial, but he does not answer the phone
BUT just as they're about to finish off the "zombie" uncle, Phil appears
THEREFORE Phil stops them and explains that his uncle isn't a zombie, but is just extremely stoned from the supernatural catnip, and he was too that’s why he missed school earlier.
BUT the group is skeptical and unsure whether to believe Phil
BUT Bella realises she smoked catnip Roy earlier at school today, and he does not answer the phone
THEREFORE they decide to look for Roy, leaving Phil’s uncle behind
BUT as they leave Phil's house, Bella mentioned that Roy and Dan were meeting at the pub
THEREFORE they decided to go there to find them.
*/
scene: background background_phil_kitchen
camera: view 160x90+160+90
bella: at farRight
andy: at outsideRight
andy: walk to midRight
bella: walk to center
bella: "Lock the door!"
andy: "No shit Sherlock!"
andy: play panic loop
camera: transition view 320x180+0+0
bella: "Oh my God. Is this actually happening?" 
andy: play panic_talk loop
andy: "It... it can't be. I mean... zombies aren't real, right?" 
andy: play panic loop
bella: turn to sloth
bella: "Doesn't matter, we've watched movies, we need to kill it before the virus spreads further!"
andy: walk to centerRight
camera: transition view 160x90+100+90
andy: "Do we? Do you even know how to kill a zombie, Bella?"
bella: play angry loop
bella: "I don't know! Do I look like a zombie expert to you?"
bella: play angry loop
phil's uncle: at outsideRight
phil's uncle: "Hungry.. need food.."
bella: play front loop
andy: "Okay.. okay, we need backup. Let's call Roy."
bella: play phonecall_talk loop
bella: "Good for us he's a nerd for this stuff..."
bella: play angry loop
bella: "Shit! Fucking voicemail! Why!?"
andy: "Yeah, who the hell uses voicemail?"
bella: play front loop
andy: "Time for plan B"
scene: pause 0.5
andy: play knife loop
scene: pause 1
bella: play hammer loop
scene: pause 1
andy: play bat loop
scene: pause 1
bella: play chainsaw_man loop
scene: pause 1
andy: turn to cat_blue
andy: play lateral_talk loop
andy: "What... What's that supposed to be?"
andy: play lateral loop
bella: "A Chainsaw-Man reference?"
andy: play lateral_talk loop
andy: "I... I didn't watch it yet..."
andy: play lateral loop
bella: "Come on! This might be our last shot at cosplay!"
andy: play lateral_talk loop
camera: transition view 320x180+0+0
andy: "...Ok fine, keep the chainsaw and help me look for duck tape, we're doing `Ash versus Evil dead`!"
andy: play lateral loop
cat_calico: at outsideRight
cat_calico: "Guys, it's me Phil, let me in"
bella: walk to farRight
andy: "Nice try asshole!"
andy: walk to centerLeft
camera: transition view 320x180+0+0
bella: "Zombies can't talk, do they?"
cat_calico: "He's not a zombie, he's just high as fuck..."
bella: walk to centerRight
cat_calico: walk to farRight
andy: turn right
andy: "What the..."
bella: "So you're telling me it's munchies? That's it?"
bella: turn to cat_calico
cat_calico: "Well, I don't know what would have happened without food at hand..."
bella: "Fuck... I gave Roy the rest of the catnip!"
andy: "So?" 
bella: "He might be turned into a fucking... I don't know...a stoned zombie or something?"
cat_calico: "What?! Did you guys smoke my uncle’s catnip? That shit’s not normal! It’s like... supernatural or something!" 
andy: "So, you're telling me we officially have a zombie problem now??" 
bella: play worried_talk loop
bella: "Yes, fuck, what are we gonna do? They were supposed to meet at the pub after school."
bella: play worried loop
andy: "Well, let's go find them then...", he said with a determined tone.
scene: pause 0.5
scene: clear

/*
At the pub, they notice the environment is quiet, surprisingly quiet
BUT suddenly the bartender walks into the scene and as they order they realise he’s also turned into a zombie.
THEREFORE they run out of the pub, fearing for their lives.
*/
scene: background background_dive_bar
camera: view 160x90+30+90
bella: at farLeft
andy: at midLeft
cat_calico: at centerLeft
bella: walk to midLeft
andy: walk to centerLeft
cat_calico: walk to center
cat_calico: "Since we're here, let's grab something to drink"
bella: "We'll have two beers and a glass of water please!"
andy: "Pff... Be careful with the water"
bella: "Asshole"
camera: transition view 320x180+0+0
zombie: at outsideRight
zombie: crawl to outsideLeft
bella: play worried_talk loop
bella: "Oh shit! He's a freaking zombie!"
bella: play worried loop
cat_calico: play worried_talk loop
cat_calico: "I should have mentioned basically everybody in town smokes my uncle's catnip... Let's get out of here!"
bella: run to outsideLeft
andy: run to outsideLeft
cat_calico: run to outsideLeft
scene: pause 0.5
scene: clear

/*
BUT before they could make it far enough, they are suddenly surrounded by a horde of zombies from left and right
THEREFORE they run into an alleyway but get cornered.

Just then, Bella remembers that they left Phil's uncle alone at the house
THEREFORE she decides to call him since he might be their only chance at survival.
Uncle picks up, asks if they've seen the "Land of the dead"
The guys didn't see it
Uncle says they will figure it out and hangs up
Roay was turned into a zombie.

Just as they're about to lose hope, they see a bright light from afar and immediately beautiful display of fireworks.
The zombies, feeling attracted to the lights, are distracted and start moving in the other direction.

In this chaos, Phil’s uncle swiftly pulls up in a car, yelling for the group to get in
THEREFORE they all jump in the car and drive away just in time, leaving behind the chaos and the popcorn fireworks.
*/
scene: background background_town_street_sunset2
cybertruck: scale 2
cybertruck: at outsideLeft
cybertruck: set z 50
bella: at midRight
andy: at centerRight
phil's uncle: at outsideRight
cat_calico: at midRight
cat_calico: offset x -25
cat_calico: turn to cat_blue
andy: turn to cat_blue
bella: "Next time, let's pick a place where the staff DOES NOT BITE, OK??"
cat_calico: "Hold on, more zombies!"
zombie: opacity 1
zombie: set x 55
zombie: slug to outsideRight
zombie_kid: set x 0
zombie_kid: slug to outsideRight
zombie_kid: opacity 1
trex_zombie: set x -25
trex_zombie: slug to outsideRight
trex_zombie: opacity 1
andy: turn to trex_zombie
andy: "Fuck! They got Roy!"
bella: "I'm calling your uncle." she said frantically
bella: play phonecall_talk loop
bella: "What the fuck is up with your catnip?? Everyone in town turned into fucking zombies!"
zombie: opacity 0
zombie_kid: opacity 0
trex_zombie: opacity 0
bella: play phonecall loop
camera: transition view 160x90+160+90
phil's uncle: "About that..."
phil's uncle: "Have you guys seen the movie Land of the Dead?"
bella: play phonecall_talk loop
bella: "No, we haven't...?"
bella: play phonecall loop
phil's uncle: "No time to explain then, I'm sure you'll figure it out. Bye."
bella: play front loop
cat_calico: play angry_talk loop
camera: transition view 320x180+0+0
zombie: opacity 1
zombie: set x 55
zombie: slug to outsideRight
zombie_kid: set x 0
zombie_kid: slug to outsideRight
zombie_kid: opacity 1
trex_zombie: set x -25
trex_zombie: slug to outsideRight
trex_zombie: opacity 1
cat_calico: "Figure it out... Figure out what exactly!? That cryptic motherfucker!!"
cat_calico: play angry loop
bella: turn to left
andy: play panic_talk loop
andy: "Guys... I think this is it."
andy: play panic loop
bella: "All of this... I just wanted to get laid"
overlay: play fireworks loop
scene: pause 1
cat_calico: play worried_talk loop
cat_calico: "What the hell was that!?"
cat_calico: play worried loop
cybertruck: speed to centerRight
bella: "Fireworks!?"
zombie: fade out
zombie_kid: fade out
trex_zombie: opacity 0
roy: set x 55
roy: play dead loop
phil's uncle: "Everybody get in! We've got to go!"
cybertruck: speed to outsideRight
scene: pause 1
scene: clear

/*
Phil's Uncle, Bella and Phil give the morale of the episode.
*/
scene: background background_town_street_sunset
overlay: play endcard loop
bella: at centerLeft
cat_calico: at center
phil's uncle: at centerRight
bella: "thanks for the ride! What's the plan?"
cat_calico: "The effects should wear off in a couple of hours..."
bella: "So you killed Roy for nothing? You bastards!"
phil's uncle: "Let's go get some ice cream!"
scene: pause 0.5
scene: clear
```
