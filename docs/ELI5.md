# ELI5

SimCity 2000 is a 1990s game where you build a city and keep it alive. It was made for old computers, and it doesn't run well on a new Mac.

A game is two things: the engine (the rules and the code that draws everything) and the stuff (pictures, sounds, music, words). The old engine is the part that broke. The stuff is fine.

Some people wrote a brand new engine called OpenSC2K. It follows the same rules as the original, but it's built for computers today. It doesn't come with the stuff, because that still belongs to the company that made the game. So you bring your own copy, and OpenSC2K copies the pictures, sounds and music out of it.

This repo has two helpers:

1. One downloads OpenSC2K and checks it's the real thing before installing it, like checking the seal on a jar.
2. The other looks through your copy of the game, makes sure nothing is missing, works out which version you have, and tells OpenSC2K where to look.

Then you click Import once, and you're building cities again.
