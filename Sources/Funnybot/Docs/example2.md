Input concept:
```
Episode start off in Andy's living room. Dan, feeling peckish, persuades a reluctant Andy to visit a new eatery recommended by their friend Roy, who works there. Despite Andy's skepticism about Roy's culinary tastes, they drive for three hours to a trucker-frequented fry shop on the outskirts of town.

At the shop, they're greeted by Roy the T-Rex, who serves up bizarre food combinations like anchovy ice cream and pickled banana sandwiches. The food turns out to be as unappetizing as it sounds, causing both Andy and Dan to feel ill. A distressed Andy rushes to the restroom, which is in a deplorable state, and accidentally discovers a portal beneath the shop.

This portal transports Andy to a parallel universe where he finds the "tree of infinite knowledge".
The world seems popupated by alpacas who wear sunglasses and call themselves the Sunglasses Tribe. They welcome Andy and reveal their intent to invade Earth for its resources and novelties, like sweets and sunglasses, since they lack opposable thumbs to create their own. The alpacas are irked when Andy mistakenly refers to them as "lamas," a cultural faux pas that leads to his expulsion from their world.

Meanwhile, back in the original world, Dan and Roy have left the fry shop and are settling their stomachs with coffee at a diner. Unbeknownst to them, the coffee is abysmal, offending the ape wait staff, leading to a chaotic escape from an impending ape attack.

Back in the alpaca universe, after Andy has used their otherworldly bathroom, the alpacas decide they’ve had enough of him, and Andy is unceremoniously sent back through the portal, landing back at the fry shop.

Dan and Roy manage to get back inside the fry shop to hide from the apes, but they get caught there.

Andy, Dan, and Roy lie defeated on the floor of the fry shop, only to be found by Bella, who is miffed at being left out of their shenanigans. Andy and Dan recount their wild experiences, with Andy mentioning "talking llamas" and Dan exasperatedly blurting out about "fucking monkeys."

In the final moments, the alpacas from the parallel universe appear to have followed Andy through the portal, signifying that the crossover between the two worlds may have just begun.
```

Your output script:
```
/*
Episode start off in Andy's living room. Dan, feeling peckish, persuades a reluctant Andy to visit a new eatery recommended by their friend Roy, who works there. Despite Andy's skepticism about Roy's culinary tastes
*/
scene: background background_andy_livingroom
andy: at center
dan: at midLeft
dan: "Man, I'm starving. Wanna get something to eat?"
dan: turn to sloth
andy: worried
scene: pause 0.3
andy: "Really, Dan? We've eaten like 50 packs of Cheetos."
scene: pause 3
dan: "Come on dude, Roy started working at a new place just outside town, he says we HAVE to check it out"
andy: "Do we have to? He's taste for food is not exactly..."
dan: "Please???"
andy: "Ok... let's get in the car"
scene: pause 0.5
scene: clear

/*
they drive for three hours to a trucker-frequented fry shop on the outskirts of town.
*/
scene: background background_fry_shop_exterior
cybertruck: scale 2
cybertruck: at outsideLeft
cybertruck: offset x 120
cybertruck: set z -10
cybertruck: drive to center
scene: pause 0.7
cybertruck: fade out
scene: pause 0.2
andy: fade in
andy: at center
dan: fade in 
dan: at centerRight
andy: turn to crow
andy: "You said 'just outside town', not three freaking hours away!"
dan: "Look, truckers eat here too, it must be a good place."
scene: pause 1
scene: clear

/*
At the shop, they're greeted by Roy the T-Rex, who serves up bizarre food combinations like anchovy ice cream and pickled banana sandwiches. The food turns out to be as unappetizing as it sounds, causing both Andy and Dan to feel ill
*/
scene: background background_fry_shop_interior
dan: at midLeft
andy: at farLeft
dan: walk to centerRight
andy: walk to center
roy: at outsideRight
roy: walk to farRight
andy: worried
dan: happy
andy: "Oh man, this place is a lawsuit waiting to happen!"
scene: pause 3
dan: "Hehe that's how you know it's good! What's on the menu Roy?"
roy: happy   
roy: "We have such exciting combinations like anchovy ice cream and pickled banana sandwiches."
andy: worried
scene: pause 0.5
andy: "Are you serious? That sounds disgusting."
dan: "Come on, Andy! Live a little. Let's try it... We'll have the anchovy ice cream and a pickled banana sandwiches, please."
roy: "Here you go, enjoy!"
dan: play eat_disgusted loop
andy: play eat_disgusted loop
dan: "Oh god, this is awful!"
andy: play panic_talk loop
andy: "Yeah, I don't think I can take another bite."
dan: play vomit loop
scene: pause 0.1
andy: "Shit! I need a bathroom, now!"
andy: play panic loop
roy: "Yeah, I can definitely smell that!"
scene: pause 3
roy: "Hurry up, this way!"
andy: walk to outsideRight
roy: walk to outsideRight
scene: pause 0.5
scene: clear

/*
A distressed Andy rushes to the restroom, which is in a deplorable state,
*/
scene: background background_fry_shop_restroom
roy: at farRight
andy: at centerRight
roy: walk to center
andy: walk to centerLeft
andy: "Somehow, the bathroom is worse than I expected"
roy: play shrug
roy: "Hey, you gotta go when you gotta go."
andy: walk to midLeft
scene: pause 0.2
scene: pause 0.5
scene: clear

/*
and accidentally discovers a portal beneath the shop.
*/
scene: background background_fry_shop_bathroom
andy: at farRight
andy: opacity 1
scene: pause 0.5
andy: walk to center
scene: pause 0.5
andy: "Ahh... Just in time..."
scene: pause 3
overlay: set z 100
overlay: play buzzing_lights loop
scene: pause 0.5
overlay: set z -50
overlay: offset y -15
andy: "Hey, guys! There's something weird with this bathroom!"
overlay: play floor_portal loop
andy: play panic loop
andy: "Guys! A little help!?"
scene: clear

/*
This portal transports Andy to a parallel universe where he finds the "tree of infinite knowledge".
The world seems popupated by alpacas who wear sunglasses and call themselves the Sunglasses Tribe.
*/
scene: background background_alpaca_world_tree_of_wisdom
roadsign: at center
andy: at farLeftTop
andy: fade in
andy: drive to farLeft
andy: "Woah, what just happened? Where am I?" 
scene: pause 0.1
andy: walk to center
andy: "Mmmh... The sign says `Tree of infinite knowledge`..."
roadsign: debug
roadsign: fade out
scene: pause 0.1
alpaca_orange: fade in
alpaca_orange: at farLeft
alpaca_orange: turn to sloth
alpaca_beige: fade in
alpaca_beige: at midLeft
alpaca_beige: offset x 25
alpaca_beige: turn right
alpaca_purple: fade in
alpaca_purple: at centerRight
alpaca_purple: turn to sloth
alpaca_brown: fade in
alpaca_brown: at farRight
alpaca_brown: turn to sloth
alpaca_orange: "Greetings, Andy the sloth"
andy: turn left
andy: "Uh, hello...?"
andy: turn right
alpaca_purple: "You have stumbled upon the parallel universe hidden beneath Obscureville, young one."
andy: "Not this shit again..."
andy: turn left
alpaca_orange: "Indeed, and we, the sunglasses tribe, are its rulers."
andy: "So... Does this tree really hold infinite knowledge?"
alpaca_orange: "No... but some wise plant told us it's a marketing gimmick that's showing results."
andy: "Lame... So, what's this place called?"
andy: turn right
alpaca_purple: "It doesn't have a name understandable to human languages."
andy: turn left
andy: "Not gonna lie, everything so far sounds a bit clisheh"
scene: pause 3
alpaca_beige: play angry_talk loop
alpaca_beige: "Enough! We can all smell the traveler needs a bathroom, an a change, we'll talk later"
scene: pause 0.5
scene: clear

/*
They welcome Andy and reveal their intent to invade Earth for its resources and novelties, like sweets and sunglasses, since they lack opposable thumbs to create their own. The alpacas are irked when Andy mistakenly refers to them as "lamas," a cultural faux pas that leads to his expulsion from their world.
*/
scene: background background_alpaca_world_temple_council_room
alpaca_orange: fade in
alpaca_orange: at farLeft
alpaca_orange: turn to sloth
alpaca_beige: fade in
alpaca_beige: at midLeft
alpaca_beige: offset x 25
alpaca_beige: turn to right
alpaca_purple: fade in
alpaca_purple: at centerRight
alpaca_purple: turn to sloth
alpaca_brown: fade in
alpaca_brown: at farRight
alpaca_brown: turn to sloth
andy: at center
andy: turn left
alpaca_orange: "Let us resume our meeting."
alpaca_purple: "We have this proposal for invading Earth and..."
andy: turn right
andy: play panic_talk loop
andy: "WHAT!?"
andy: play panic loop
alpaca_beige: "You wish to speak, Andy?"
andy: play lateral
andy: "Why? You have all you need here"
alpaca_purple: "Dude, have you noticed we don't have any opposable thumbs? Where do you think all of our shit comes from?"
alpaca_brown: "And don't get me started about food, eating grass is cool and all, but once you try human sweets.. oh boy!"
alpaca_orange: "Not to mention sunglasses!"
andy: turn left
andy: "Why do Lamas where sunglasses anyway?"
alpaca_purple: play angry loop
alpaca_brown: play angry loop
alpaca_orange: play angry loop
alpaca_beige: play angry loop
alpaca_purple: play angry_talk loop
andy: turn right
alpaca_purple: "Lama!? We're alpacas!"
alpaca_purple: play angry loop
alpaca_brown: play angry_talk loop
alpaca_brown: "You used the L word... We though you were cool. This is unforgivable!"
alpaca_brown: play angry loop
scene: pause 1
scene: clear

/*
Meanwhile, back in the original world, Dan and Roy have left the fry shop and are settling their stomachs with coffee at a diner.
*/
scene: background background_fry_shop_interior
dan: at centerLeft
dan: turn right
dan: worried
roy: at centerRight
roy: turn left
roy: worried
dan: "What the hell was that?"
roy: "I don't know, and I don't wanna find out. He doens't seem to be having a great time in there."
roy: turn to crow
dan: "Yeah... Let's get some coffee, I need to settle my stomach..."
roy: "Yeah, just, maybe... Let's pick another place"
dan: walk to outsideLeft
roy: walk to outsideLeft
scene: pause 2
scene: clear

/*
Unbeknownst to them, the coffee is abysmal, offending the ape wait staff, leading to a chaotic escape from an impending ape attack.
*/
scene: background background_diner_tables_night
dan: at centerLeft
roy: at centerRight
dan: turn right
roy: turn to crow
dan: play coffee loop
roy: play coffee_talk loop
roy: "Man, this coffee tastes like butt..."
roy: play coffee loop
dan: play coffee_talk loop
dan: "Yeah, what stupid monkey can't use a coffee machine properly!?"
ape: play angry loop
ape_chef: play angry loop
ape_waiter: play angry loop
dan: at centerLeft
roy: at centerRight
dan: drive to outsideLeftOver
roy: drive to outsideLeft
dan: "RUN ROY! LET'S FUCKING RUN!!"
scene: pause 1
scene: clear

/*
Back in the alpaca universe, after Andy has used their otherworldly bathroom, the alpacas decide they’ve had enough of him, and Andy is unceremoniously sent back through the portal, landing back at the fry shop.
*/
scene: background background_alpaca_world_temple_bathroom
alpaca_orange: fade in
alpaca_orange: at farLeft
alpaca_orange: turn to sloth
alpaca_beige: fade in
alpaca_beige: at midLeft
alpaca_beige: offset x 25
alpaca_beige: turn to sloth
alpaca_purple: fade in
alpaca_purple: at centerRight
alpaca_purple: turn to sloth
alpaca_brown: fade in
alpaca_brown: at farRight
alpaca_brown: turn to sloth
toilet: at center
andy: at centerTop
andy: turn to front
andy: flip vertically
andy: walk to center
andy: "Thanks, I will never forget you guys!"
andy: fade out
alpaca_orange: "And don't ever come back...!"
toilet: play close 1
scene: pause 0.5
alpaca_brown: "Fucking specist."
scene: pause 4
scene: clear

/*
Dan and Roy manage to get back inside the fry shop to hide from the apes, but they get caught there.
*/
scene: background background_fry_shop_interior
dan: at midRightTop
roy: at farRight
dan: walk to center
roy: walk to centerRight
dan: "Holy moly... That was way too close.."
scene: pause 0.5
dan: "Are we safe here?"
roy: "No way they can unhinge the door"
ape: at centerTop
ape: flip vertically
ape: play angry loop
ape_chef: at outsideRight
ape_chef: run to center
ape_waiter: at outsideLeft
ape_waiter: run to center
dan: "Well, fuck."
scene: pause 3
scene: clear

/*
Andy, Dan, and Roy lie defeated on the floor of the fry shop, only to be found by Bella, who is miffed at being left out of their shenanigans. Andy and Dan recount their wild experiences, with Andy mentioning "talking llamas" and Dan exasperatedly blurting out about "fucking monkeys."
In the final moments, the alpacas from the parallel universe appear to have followed Andy through the portal, signifying that the crossover between the two worlds may have just begun.
*/
scene: background background_fry_shop_interior
andy: play dead loop
andy: at centerRight
dan: play dead loop
dan: at centerLeft
roy: play dead loop
roy: at farRightBottom
bella: at farLeft
bella: walk to center
bella: "Guys, what the hell is going on here? Wake up!"
andy: walk to centerRight
dan: walk to centerLeft
andy: "Whoa dude! I just went on this crazy journey with... talking lamas?"
bella: "Lamas don't talk..."
dan: "Monkeys! Fucking monkeys...!"
alpaca_orange: fade in
alpaca_orange: at farLeft
alpaca_orange: turn to sloth
alpaca_beige: fade in
alpaca_beige: at midLeft
alpaca_beige: offset x 25
alpaca_beige: turn to sloth
alpaca_purple: fade in
alpaca_purple: at centerRight
alpaca_purple: turn to sloth
alpaca_brown: fade in
alpaca_brown: at farRight
alpaca_brown: turn to sloth
scene: pause 0.1
alpaca_purple: "Humans! As promised we are here to conquer the planet!"
andy: "We're not... humans?"
dan: "Oh my god, they've killed Roy!"
bella: happy
overlay: play endcard 1
bella: "No, food poisoning and a life committed to no exercise and junk food did."
scene: pause 5 
scene: clear
```
