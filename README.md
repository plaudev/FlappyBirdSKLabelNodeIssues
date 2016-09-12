# FlappyBirdSKLabelNodeIssues
SKLabelNode gravity issues?

Hello, working on a basic flappy bird game here. The game works as intended on an actual device until an SKLabelNode is added onto the scene which seems to bring the bird down to the ground almost instantaneously when the app starts. Steps to reproduce problem as follows:
 
1) Comment out the line self.addChild(scoreLabel) and compile to run on iphone (I'm testing with iphone 6 plus running iOS9.3.5). Result = app runs with no scoreLabel (SKLabelNode) but score is shown in console.
 
2) Uncomment the self.addChild(scoreLabel) line and compile to run on iphone. Result = app runs as intended with the scoreLabel updated with the score.
 
3) Restart the game without changing the code (ie leave that line in). Result = app starts but the bird instantaneously goes to the ground.
 
What could be wrong? Any pointers would be appreciated.
Running this on the simulator (6 plus) produces less consistent results.
