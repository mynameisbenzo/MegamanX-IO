# MegamanX-IO

#### Working off of MarI/O to make Mega Man X do his own work!


## Issues as of 10-13
##### Enemies aren't being recognized the same way as MarI/O.
###### I'm sure I have the right address, but it's not displaying correctly in the neural net. -Lorenzo
##### Surfaces aren't displayed either!
###### On this note, I am not ENTIRELY sure what is going on here with respect to the MarI/O code.  In the getTiles() function is where it seems to identify the surfaces, but the address I'm seeing referenced in MarI/O vs the various Super Mario World Ram Maps don't yield any information for me. -Lorenzo
##### Unlike MarI/O, there are cutscenes...
###### The fitness will have to be adjusted in order to compensate for that.  My idea is that if there are any enemies on the screen then before Mega Man X can move forward he must eliminate them. -Lorenzo
###### UPDATE: Possible solution.  For this problem, increase time before next genome while also checking the life counter.  If health is zero and life counter is zero, then move to next genome.  If megaman has been staying still for awhile, then move to next genome.
