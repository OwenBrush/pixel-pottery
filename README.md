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

![Screenshot](/screenshot.png?raw=true "Optional Title")

### Dataset Generation
* While in data collection mode, the game saves every unique frame during a play session as a 96x96 black and white image, which can then manually classified
  * Classification process is made easier due to the images being in a time sequence, allowing sequeces of similar images to be classified in batches.
* This could be adapted for crowd sources data collection, or building models that are unique and responsive to individual players.

### Examples from test data:
![Cup class](/pixel_pottery_modelling/graphs/cup_class.png?raw=true "Optional Title")

![Bowl class](/pixel_pottery_modelling/graphs/bowl_class.png?raw=true "Optional Title")

![Decorative class](/pixel_pottery_modelling/graphs/decorative_class.png?raw=true "Optional Title")

![Junk class](/pixel_pottery_modelling/graphs/junk_class.png?raw=true "Optional Title")

### Classification performance with test data:
* Each model scores around 80% accuracy.  (with a baseline accuracy of 40%, were it to just always guess the most common class)
* Many of the false classifcations are due the subjectivity of the data and are often reasonable mistakes.
* Extremely assymetrical images can also confuse the model, but this is accounted for with the symmetry score, where if the symmetry is far enough away from the preferences of the customer it is labeled as junk regardless of what the classifier chose.


* model_1 (customer name: Mabel)

![Model_1](/pixel_pottery_modelling/graphs/model_1.png?raw=true "Optional Title")

* model_2 (customer name: Jimmy)

![Model_1](/pixel_pottery_modelling/graphs/model_2.png?raw=true "Optional Title")

* model_3 (customer name: Tyrel)

![Model_1](/pixel_pottery_modelling/graphs/model_3.png?raw=true "Optional Title")

* model_4 (customer name: Augustus)

![Model_1](/pixel_pottery_modelling/graphs/model_4.png?raw=true "Optional Title")

* model_5 (customer name: Sam)

![Model_1](/pixel_pottery_modelling/graphs/model_5.png?raw=true "Optional Title")

### Limitations:
* The Godot game engine is not optimized for running convolutional networks, so the models had to be tuned to be as simple as possible.
* All data was generated through gameplay by myself alone.
* All data was classified by myself alone.

For a larger or more developed project the data generation and classifcation process would need to involve a diverse selection of people to account for real diversity in preferences and aproaches to gameplay.

### Notes:
* Much of the game mechanics are salvaged from an older project that I was working on while still learning the basics of programming, and there is likely some large inconsistencies in code quality as a result.
* The integration of a Keras convolutional network into Godot was acomplished with an enormous amount of help from [this repository](https://github.com/postcode-x/godot-keras).
