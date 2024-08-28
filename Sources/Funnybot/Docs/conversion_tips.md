# Conversion Tips and Tricks

## Generation from concept
In order to convert the script in the best way, be sure to:
- Breakdown by scene
- Concept links
- Verbal Storyboarding
- Leverage animators

## Breakdown by scene
The first thing to do is to break down the concept into individual scenes.
Remember this is an animated show where characters move over a fixed background, so, ideally, each scene can be identified by a background change.
Not all characters need to be in each scene, be sure to include only the necessary ones.

### Concept links
Use comments to report the exact lines of the concept you are converting into script, and do it one scene at a time.
There will be some examples attached.
Not all characters need to be in each scene, be sure to include only the necessary ones.

### Verbal Storyboarding
Before writing the script representing a scene, use comments to answer the following questions, one at a time, reasoning step by step:
1. What's missing in the concept?
2. Is the concept trying to communicate something funny?
3. What details can we add?
4. What are some good jokes we can add?
5. What's in the background and foreground?
6. What elements of the scene are actual characters and which are special animations?

For example, this is part of a concept for the next episode:
```
The episode begins with a truckload of rubber ducks spilling onto Main Street in Obscureville. Roy, strolling down the street, stumbles upon the scene. The sight of hundreds of bright, yellow rubber ducks spread across the road sparks his paranoia. There’s an eerie wind and the ducks seem to all be staring at him. He bolts away, convinced it's a sign of an imminent amphibious alien invasion.
```
Your comment should be something like this:
```
/*
The episode begins with a truckload of rubber ducks spilling onto Main Street in Obscureville. Roy, strolling down the street, stumbles upon the scene. The sight of hundreds of bright, yellow rubber ducks spread across the road sparks his paranoia. There’s an eerie wind and the ducks seem to all be staring at him. He bolts away, convinced it's a sign of an imminent amphibious alien invasion.
1. It's not clear when Roy arrives on the scene
2. Roy does not realise te ducks are rubber ducks, he probably didn't even see the truck
3. We should define when Roy arrives on the scene.
4. Since Roy is looking at the ducks and those are staring back at him, we should do this gag where the ducks always turn towards Roy as he moves around the scene
5. Roy doesn't realise the ducks are actually rubber ducks, because he immediately think it's aliens, so it's reasonable to assume the truck is in the background and Roy did not see it.
6. Due to the complexy and number of items, it's reasonable to assume the ducks spilling out of the truck will be an animation of the truck itself
*/
```

### Leverage animators
Some scenes might involve a large number of characters or items, for example:
```
The episode begins with a truckload of rubber ducks spilling onto Main Street in Obscureville. Roy, strolling down the street, stumbles upon the scene. The sight of hundreds of bright, yellow rubber ducks spread across the road sparks his paranoia. There’s an eerie wind and the ducks seem to all be staring at him. He bolts away, convinced it's a sign of an imminent amphibious alien invasion.
```
In such cases, it's better to let the animators do some of the heavy work:
```
scene: background background_main_street_day
truck: at outsideLeft
truck: drive to outsideRight
scene: pause 1
truck: play crash_spill_rubber_ducks loop
scene: pause 1
overlay: play rubber_ducks_rain loop
scene: pause 1
roy: "An ominous wind... And... Imminent amphibious alien invasion!" He shouted out loud
scene: pause 1
scene: clear
```
