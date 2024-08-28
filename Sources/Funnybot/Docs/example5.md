Input concept:
```
Cybertruck Unveil Event: At the Tesla HQ, Elon Musk introduces the Cybertruck, boasting about its toughness, charge, and self-driving capabilities. During the demonstration, the truck's window unexpectedly shatters.

Discussion Among Friends: Andy, Dan, and Roy watch the event from Andy's living room. While Andy and Dan are impressed, Roy criticizes the Cybertruck's design, prompting a light-hearted debate.

Aliens Monitoring Earth: In a spaceship command center, two aliens, Gnome and Tom, notice the Cybertruck's similarity to their technology. They decide to visit Earth to address this apparent theft of their technology.

School Scene: Back on Earth, at a school, Andy, Roy, Dan, and Bella discuss the upcoming Cybertruck delivery. Roy remains skeptical, sparking a conversation about advancements in technology and Roy's resistance to change.

Roy's Encounter with a Spaceship: Later, in a forest, Roy encounters a mysterious spaceship, leading him to believe in extraterrestrial life.

Revelation at Phil's House: At Phil's house, the group discusses Roy's alien encounter. Phil's uncle arrives, intrigued by Roy's description of the aliens, which sound suspiciously like him. So he sends them to meet up with a friend at the sighting place.

Confrontation in the Forest: In the forest, Elon Musk and the aliens confront each other. The aliens express their concerns about the Cybertruck's materials, but are surprised to learn about the vehicle's popularity despite its flaws.

Dramatic Conclusion: The story culminates with the aliens preparing to leave Earth. Roy, believing he's one of them, attempts to join them but is humorously rebuffed. The segment ends with a classic cliffhanger line as the spaceship departs, leaving the characters in awe.
```

Your output script:
```
/*
Cybertruck Unveil Event: At the Tesla HQ, Elon Musk introduces the Cybertruck, boasting about its toughness, charge, and self-driving capabilities. During the demonstration, the truck's window unexpectedly shatters.
*/
scene: background background_tesla_hq_stage
overlay: play text_cybertruck_unveil 1
elon: at center
cybertruck: scale 2
cybertruck: at outsideRight
cybertruck: walk to centerRight
elon: set z 80
elon: "Welcome to the Cybertruck unveil event!"
elon: "This thing is a beast – it's tougher, incredible charge, and yeah, full self driving!"
camera: transition view 160x90+160+80
cybertruck: play window_shatters loop
scene: pause 0.1
elon: "Coming early next year!"
scene: pause 0.1
scene: clear

/*
Discussion Among Friends: Andy, Dan, and Roy watch the event from Andy's living room. While Andy and Dan are impressed, Roy criticizes the Cybertruck's design, prompting a light-hearted debate.
*/
scene: background background_andy_livingroom
camera: view 213x120+107+60
andy: at center
dan: at centerRight
roy: at midRight
andy: turn right
roy: turn left
dan: turn left
andy: "That was incredible! It's going to be a hit!"
dan: "Absolutely, man!"
roy: "I don't know, it's just... ugly"
andy: turn left
andy: "Haters gonna hate I guess"
scene: pause 0.2
scene: clear

/*
Aliens Monitoring Earth: In a spaceship command center, two aliens, Gnome and Tom, notice the Cybertruck's similarity to their technology. They decide to visit Earth to address this apparent theft of their technology.
*/
scene: background_spaceship_command_center
gnome: at centerRight
gnome: offset x -20
gnome: turn left
tom: at centerLeft
tom: turn right
gnome: "Dude! I'm looking at the Earth's channel"
camera: transition view 160x90+85+90
gnome: "That's the spitting image of a Glokkothronw kay!"
tom: "Oh my god, and the way that glass broke, it's definately our tech!"
gnome: "They play with stolen toys as if they've mastered the cosmos..."
tom: "Let's pay these 'innovators' a little visit. Time to teach them a lesson in intergalactic property rights."
gnome: turn right
tom: turn left
gnome: play roar loop
tom: play roar loop
scene: pause 1
scene: clear

/*
School Scene: Back on Earth, at a school, Andy, Roy, Dan, and Bella discuss the upcoming Cybertruck delivery. Roy remains skeptical, sparking a conversation about advancements in technology and Roy's resistance to change.
*/
scene: background background_school_lockers
overlay: play text_today 1
andy: at midRight
roy: at center
roy: offset x -40
bella: at centerRight
roy: turn left
dan: at outsideLeftMid
dan: walk to midLeft
dan: "Guys, guys! It's tonight, Cybertruck delivery event is tonight!"
andy: "Finally, can't wait to get mine!"
camera: transition view 160x90+30+90
roy: "Sure, it's only what, 4 years late? Prices are gonna be double the original and it's still the ugliest thing i've ever seen"
dan: "Roy, sorry pal, but you're obsolete. You're just a old dinosaur, your time is over!"
roy: "Haha... Prehistoric being do not like shiny new tech toy. Very funny." 
dan: "I know you hate electric cars because they don't use oil, just say it!"
roy: play sad_talk loop
roy: "Wait... So we're extinct AND useless now?"
roy: play sad loop
camera: transition view 160x90+100+90
roy: turn right
roy: play sad loop
bella: "If that makes you feel better Roy, oils is made out of fossil plants, not dinosaur, it's a common misconception"
roy: run to outsideRight
camera: transition view 320x180+0+0
roy: "It fucking doesn't make me feel better... You guys are not fun!"
scene: pause 1
scene: clear

/*
Roy's Encounter with a Spaceship: Later, in a forest, Roy encounters a mysterious spaceship, leading him to believe in extraterrestrial life.
*/
scene: background background_forest_border_night
cybership: at midLeftOver
cybership: speed to midLeftMid
roy: at outsideRight
roy: run to centerRight
roy: "What a bunch of assholes..."
scene: pause 0.2
roy: "What the... hell..."
scene: pause 0.5
cybership: play busy_aliens loop
scene: pause 0.3
roy: "Oh god... Who's the dinosaur now eh!?"
scene: pause 1
scene: clear

/*
Revelation at Phil's House: At Phil's house, the group discusses Roy's alien encounter. Phil's uncle arrives, intrigued by Roy's description of the aliens, which sound suspiciously like him. So he sends them to meet up with a friend at the sighting place.
*/
scene: background background_phil_livingroom
roy: at centerLeft
andy: at midLeft
dan: at centerRight
phil's uncle: at outsideRight
andy: turn left
roy: turn right
dan: turn left
camera: transition view 213x120+80+60
dan: "For the hundredth fucking time Roy, reptilians are not real"
andy: turn right
roy: "I'm telling you guys, aliens! and they looked just like me!"
camera: transition view 213x120+30+60
roy: turn left
andy: "If you're still upset about the 'dinosaur' jokes we understand roy, no need to make shit up"
camera: transition view 320x180+0+0
phil's uncle: walk to midRight
phil's uncle: "Actually... "
roy: turn right
dan: turn right
andy: "Hey Doc!"
roy: "Hey Doc"
dan: "Hey Doc"
camera: transition view 213x120+107+60
phil's uncle: "Can you describe these 'aliens'...?"
roy: "Basically me with a palette swap."
phil's uncle: play front_talk loop
phil's uncle: "I see... I've got good news and bad news... The bad one - it's probably aliens"
phil's uncle: play front loop
dan: "and the good one?"
phil's uncle: play front loop
phil's uncle: "My guy is on its way, he'll meet you there"
phil's uncle: walk to outsideRight
dan: "Oh, you have 'a guy'! I see..."
roy: walk to outsideLeft
andy: walk to outsideLeft
dan: walk to outsideLeft
dan: "Fucking great..."
scene: pause 1
scene: clear

/*
Confrontation in the Forest: In the forest, Elon Musk and the aliens confront each other. The aliens express their concerns about the Cybertruck's materials, but are surprised to learn about the vehicle's popularity despite its flaws.

Dramatic Conclusion: The story culminates with the aliens preparing to leave Earth. Roy, believing he's one of them, attempts to join them but is humorously rebuffed. The segment ends with a classic cliffhanger line as the spaceship departs, leaving the characters in awe.
*/
scene: background background_forest_border_night
cybership: at midLeftMid
cybership: set z -15
cybertruck: at outsideRight
cybertruck: scale 2
roy: at centerLeftMid
roy: offset x 25
roy: scale 0.5
roy: set z -10
roy: play texting loop
andy: at centerRight
andy: play phonecall_talk loop
andy: "Yeah Doc... He's not here yet"
andy: play phonecall loop
scene: pause 0.5
andy: play phonecall_talk loop
andy: "What? How am I even supposed to know that Doc!?"
andy: play phonecall loop
scene: pause 0.2
andy: play phonecall_talk loop
andy: "Wait, I see a car"
andy: play phonecall loopp
cybership: play busy_aliens loop
cybertruck: speed to outsideLeft
scene: pause 0.5
elon: at center
elon: fade in
andy: play phonecall_talk loop
andy: "Doc... Talk to you later..."
andy: play panic_talk loop
andy: "No way! Elon Mu-mu-musk??"
andy: play panic loop
cybertruck: fade out
cybership: play front loop
gnome: at midLeft
gnome: turn right
gnome: fade in
tom: at farLeft
tom: turn right
tom: fade in
elon: turn left
elon: "When Joe Rogan hears about this... Just you wait..."
andy: turn left
cybertruck: scale 0.5
cybertruck: set z -20
cybertruck: opacity 1
cybertruck: at outsideLeftMid
cybertruck: walk to centerRightMid
gnome: "People of Earth! The materials you used for the Cybertruck's it's highly bulletproof and incredible in many ways but..."
andy: "Wait, before you continue... Everybody on the planet knows about the glass thing already!"
cybertruck: play front loop
gnome: "What!?"
elon: "Funny story, It actually increased our sales..."
tom: "What!?"
elon: "The most entertaining outcome is the most likely"
gnome: turn left
gnome: "Is the translator working properly!??"
gnome: turn right
andy: "So... What happens now?" 
camera: transition view 160+90+10+90
tom: "Well, you still stole from us Elon, we were about to wipe off the planet if I'm being honest, but"
gnome: "But it looks like there's PLENTY of us reptilians living here"
camera: transition view 160+90+120+90
andy: "Anyone famous!?"
camera: transition view 320x180+0+0
elon: "Nah, I would know"
tom: "GG guys, and good luck with your poligonal vehicles!"
gnome: fade out
tom: fade out
scene: pause 0.1
cybership: play busy_aliens loop
roy: play roar loop
roy: "WAIT! WAAAIT!!"
roy: run to midLeftMid
camera: transition view 160x90+10+60
roy: "I am one of you! Take me with you!"
cybership: walk to farLeftOver
scene: pause 0.1
roy: play dead_burned loop
gnome: "Hands of my spaceship you dinosaur!"
camera: transition view 320x180+0+0
overlay: play endcard loop
andy: "Oh my god! they've killed Roy!"
elon: "You bastards!"
```