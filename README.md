# [Play the game here](https://owenbrush.itch.io/pixel-pottery)

### Project Goal:

* Challenge the typical implementation of crafting in video games that relies on limited predetermined options and static outcomes.

### Approach:

* Develop a free form crafting mechanic that creates a totally unique piece of pixel art that can then be used in the game.
* Use image classification to give value to the created object based on aesthetic qualities, so that the creative process has meaning within the game.	

### Results:
* Greater player agency, creative freedom, and personal expression.
* Potential for more meaningful story telling that reacts to the player’s own creativity.
* Player-made game assets.

### How the image classification works:
* The profile of the object created is captured as a black and white image and classified as one of 4 categories:
  * Cup
  * Bowl
  * Decorative piece
  * Junk.
* The piece is also given a score based on how symmetrical the object is, allowing for variation in preferences within a given class.
* Each customer has their own neural net, trained on a unique data set and given a different preference for symmetry, simulating different opinions and tastes between people.

