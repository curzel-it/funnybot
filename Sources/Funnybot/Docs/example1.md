Input concept:
```
Andy lounges in a serene park, emanating boredom,
BUT an excited Roy rushes in, announcing a new IKEA nearby with rumored Swedish meatballs.
Dan is on a singular mission for Swedish meatballs in the restaurant.
THEREFORE, enticed by the possibility of adventure, they all decide to visit.

They arrive at the majestic façade of IKEA,
BUT within moments, Andy and the blue cat, Bella, lose Dan in the labyrinthine aisles.
THEREFORE, they venture deeper, ending up in the rug section.

BUT instead encounters a mysterious figure: the IKEA Master.
THEREFORE, Dan is initiated into the ways of blindfolded furniture assembly to learn the store's secrets.

Meanwhile, Andy and Bella find an ancient treasure map in the bathroom section,
BUT instead of leading them out, it plunges them into an underworld beneath IKEA.
THEREFORE, they're confronted by time-lost Vikings, guardians of the IKEA flame, who view them as intruders.

The duo soon realizes they might be the next meal,
BUT just in time, Dan arrives, now a disciple of the IKEA Master.
THEREFORE, he unleashes his newfound 'Swedish Meatballs No Jutsu', raining meatballs and saving his friends.

Having escaped the Viking's clutches, they exit into the sunlight,
BUT ponder on the randomness of their adventure.

Yet, in the IKEA underworld, the roasted Roy provides a feast for the tribe,
BUT the IKEA Master hints there's more to their story and future visitors.
THEREFORE, the mysteries of the IKEA underworld await another day.
```

Your output script:
```
/*
Andy lounges in a serene park, emanating boredom,
BUT an excited Roy rushes in, announcing a new IKEA nearby with rumored Swedish meatballs.
THEREFORE, enticed by the possibility of adventure, they all decide to visit.
*/
scene: background background_park_town_view
andy: at center
dan: at centerRight
roy: at outsideRight
bella: at sloth
andy: turn left
andy: "God I'm so bored today"
roy: move to midRight
roy: turn left
roy: "Did you guys hear? There's a new IKEA store nearby, there might be some crazy shit there!"
andy: turn right
andy: "That might actually be a good idea"
dan: turn left
dan: "Oh man! I heard they have a Swedish meatball piramid!"
bella: "I could use some new pillows..."
roy: turn left
roy: "Well, let's fucking go then!"
dan: move to outsideRight
bella: move to outsideRight
andy: move to outsideRight
roy: move to outsideRight
scene: pause 1
scene: clear

/*
They arrive at the majestic façade of IKEA,
*/
scene: background background_ikea_exterior
dan: at outsideLeft
andy: at farLeft
bella: at midLeft
roy: at centerLeft
andy: move to outsideRight
bella: move to outsideRight
dan: move to outsideRight
roy: move to outsideRight
bella: turn left
bella: "Ikea, here we go!"
scene: pause 1
scene: clear

/*
BUT within moments, Andy and the blue cat, Bella, lose Dan in the labyrinthine aisles.
Dan is on a singular mission for Swedish meatballs in the restaurant.
*/
scene: background background_ikea_restaurant
dan: at farRight
dan: move to outsideLeft
scene: pause 0.2
dan: "I'm coming for you, delicious Swedish balls!"
scene: pause 1
scene: clear

/*
THEREFORE, they venture deeper, ending up in the rug section.
*/
scene: background background_ikea_rugs
andy: at farLeft
bella: at centerLeft
andy: move to outsideRight
bella: move to outsideRight
bella: "Did we already lose the others!?"
scene: pause 1
scene: clear

/*
BUT instead encounters a mysterious figure: the IKEA Master.
THEREFORE, Dan is initiated into the ways of blindfolded furniture assembly to learn the store's secrets.
*/
scene: background background_ikea_kitchen
dan: at outsideRight
dan: move to center
dan: "Man, this place is fucking huge. How am I even supposed to find anything?"
ikeamaster: at midLeft
ikeamaster: fade in
ikeamaster: turn right
ikeamaster: "Ah, young one... I sense you are looking for something."
dan: "Who the hell are you?"
ikeamaster: play showoff 1
ikeamaster: move to outsideRight
ikeamaster: "I am the master of the way of IKEA..."
dan: turn right
dan: "Look master-chef, do you happen to have the recipe of the meatballs they serve here?"
ikeamaster: "If you seek guidance, follow me"
dan: move to outsideRight
scene: pause 1
scene: clear

/*
Meanwhile, Andy and Bella find an ancient treasure map in the bathroom section,
*/
scene: background background_ikea_bathrooms
andy: at centerLeft
bella: at farLeft
treasuremap: at centerRight
andy: move to treasuremap
bella: move to treasuremap
bella: "I think we're lost bro..."
andy: "Whoa, check this out, Bella!"
bella: "Dude, that looks ancient! Think it'll lead us to the exit?"
scene: pause 1
scene: clear

/*
BUT instead of leading them out, it plunges them into an underworld beneath IKEA.
*/
scene: background background_ikea_underworld_entrance
andy: at midLeft
bella: at centerLeft
bella: move to outsideRight
andy: move to outsideRight
andy: "I don't understand this map, is this supposed to be a warehouse area?"
scene: pause 0.5
bella: "Look, I see a few people over there!"
scene: pause 1
scene: clear

/*
THEREFORE, they're confronted by time-lost Vikings, guardians of the IKEA flame, who view them as intruders.
The duo soon realizes they might be the next meal,
*/
scene: background background_ikea_underworld_bonfire
andy: at farLeft
bella: at sloth
viking4: at farRight
viking4: play idle loop
andy: move to center
bella: move to center
andy: "This is insane, who knew IKEA had a secret underground city?"
bella: turn right
andy: turn right
viking1: at outsideLeft
viking1: move to centerLeft
viking2: at outsideLeft
viking2: move to farLeft
viking3: at outsideRight
viking3: move to centerRight
bella: "Maybe they're like, the long-lost tribe of Swedish furniture makers or something."
viking4: turn left
viking1: "You are not followers of the way of IKEA. How did you find our secret sanctuary?"
andy: turn right
viking1: play idle
viking3: play idle
viking4: play idle
andy: "Well, we sort of stumbled upon this ancient map-"
bella: turn left
bella: "Yeah, we got lost up there too, but we thought the map would lead us to an exit."
viking2: "We're not `lost`, you fools!"
andy: turn right
andy: "Hey, we didn't mean any-"
bella: turn left
bella: "Dude, why are you all so uptight?"
viking1: "Intruders must be improsoned! It is the law!"
andy: turn left
andy: "We need to call for help!"
andy: play phonecall_talk loop
andy: "Dan, we're in some Adidas-level-predicament down here!"
bella: "Dude, you mean dire, not Adidas."
andy: turn right
andy: "Now's not the time, Bella!"
scene: pause 1
scene: clear

/*
BUT just in time, Dan arrives, now a disciple of the IKEA Master.
*/
scene: background background_ikea_warehouse
dan: at centerRight
dan: turn left
ikeamaster: at farLeft
ikeaforniture: at center
ikeaforniture: play assembled loop
ikeamaster: move to outsideRight
dan: "What the hell are you two doing?!"
andy: at outsideLeft
andy: "Just get us out of here! We're in an underground city beneath IKEA! Hurry!"
ikeamaster: turn left
ikeamaster: "You have learned all that I can teach you, my child. Now go save your friends"
scene: pause 1
scene: clear

/*
THEREFORE, he unleashes his newfound 'Swedish Meatballs No Jutsu', raining meatballs and saving his friends.
*/
scene: background background_ikea_underworld_bonfire
viking1: at centerLeft
viking3: at centerRight
viking4: at farRight
viking4: turn right
andy: at center
bella: at center
dan: at outsideLeftTop
dan: move to farLeft
dan: play idling loop
bella: turn left
bella: "Dan! You found us!"
dan: "You can't get lost when you see beyond the shelves."
bella: "Showoff."
dan: play jutsu loop
dan: "If I wanted to show off, I'd do this..."
overlay: play meatball_asteroid 1
dan: "Swedish Meatballs No Jutsu!"
bella: move to outsideLeft
andy: move to outsideLeft
dan: move to outsideLeft
viking1: play dead loop
viking3: play dead loop
viking4: play dead loop
andy: "Now's our chance, let's fucking go go go!"
scene: pause 1
scene: clear

/*
Having escaped the Viking's clutches, they exit into the sunlight,
BUT ponder on the randomness of their adventure.
*/
scene: background background_ikea_exterior
andy: at centerLeft
bella: at centerRight
dan: at farRight
andy: turn right
andy: "Thanks, Dan. You actually saved our asses this time."
dan: turn left
dan: "Yeah, I guess I did."
bella: turn left
bella: "But what was the point of the ancient map?"
andy: turn right
andy: "Who the fuck knows in this town... At least we're all safe!"
scene: pause 1
scene: clear

/*
Yet, in the IKEA underworld, the roasted Roy provides a feast for the tribe,
BUT the IKEA Master hints there's more to their story and future visitors.
THEREFORE, the mysteries of the IKEA underworld await another day.
*/
scene: background background_ikea_underworld_entrance
roy: at center
ikeamaster: at centerLeft
viking4: at centerRight
viking4: turn front
roy: play roasted loop
ikeamaster: turn right
ikeamaster: "Isn't the flame too high?"
viking4: "It's being going low and slow for a while, I just turned up the heat to make the skin crispy"
overlay: play endcard 1
ikeamaster: "Can't wait to try it!"
scene: pause 1
```
