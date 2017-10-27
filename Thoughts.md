**ADDRESSES TO NOTE:
**0c13 is recovery animation.  					
**Why is it noteworthy? 	
****For every frame this is active decrement fitness. 
****(it's initial value is 60 unsure whether this is 
****based on frames)

**1f80 is life counter.							
**Why is it noteworthy? 	
****Increase time before moving into next genome.  
****Check to see if life counter is zero before dying 
****and then add move into next genome there as well

**0bcf	is current health.							
**Why is it noteworthy? 	
****Current health is less than it was last time? 
****Terrible! You're not fit! Current health more than 
****it is last time? Oh great! Good job!

**1928 COULD BE enemy hit or exploding animation.	
**Why is it noteworthy? 	
****We could possibly use this to increment fitness.  
****Blow up a bad guy? good for you Mega Bot!

**REVELATIONS:
**Lorenzo *10*20*17:								
***********************************************************************************
**To be honest, idk what a lot of these Lua functions do, but I just realized
**there's a difference in read_s16_le and readbyte.  WHAT THAT DIFFERENCE IS!?!?
**I'll have to look it up. *_*
**^update:											
******readbyte gets mega man x's position in
******relation to the camera.  read_s16_le
******gets how far he's travelled forward in 
******total. 
******Here's something nice:
******	If I use read_s16_le to get enemy 
******sprites, then suddenly they are seen in
******the gui box.
******Thought:
******	read_s16_le might be the way to go.
**Summation:
******¯\_(ツ)_/¯ TRIAL AND ERROR, BAYBEE!!!!!
***********************************************************************************
**Lorenzo *10*27*17:
**In the while loop, 'rightmost' is determined based on Mega Man's position relative
**to where he last was.  I believe that fitness should be calculated through all lives
**meaning let mega man die and when the 'code to get here' screen pops up start a newGene
**iteration.  For this reason, I believe and will currently work on 'rightmost' being
**calculated appropriately.  
****What to take into account?
********First, is Mega Man's life counter less than it was before?
****************If so, the distance between the last position and the current one is 
****************going to be negative and would mess up fitness. To fix this, do not
****************get the difference and do not add to 'rightmost'.  Just set lastX to
****************Mega Man's current position.
********Second, has the camera moved?
************Condition 1:
****************If the camera hasn't moved, then we need to allow Mega Man to move
****************left or right and be in the positive.  The change here would be that
****************the absolute value of the difference would be added to 'rightmost'.
************Condition 2:
****************If the camera hasn't moved and Mega Man hasn't moved, then I'm not
****************so sure here.  We want to check if input is being used.  If there
****************is input to move in any direction but there is no movement then it's
****************a cutscene and we stop the timeout counter until we can move again.
****************there most be some address that triggers during cutscenes and I think
****************it might be the address that is used to hold the dialog box that we
****************we should look for in this case. 
**...if there is something I'm missing feel free to add on to it.  Something I'm not
**thinking about.  Go wild.
**NOTE:
**I also think there should be a different variable that takes into account when 
**enemies are destroyed.  In the ram map, it is showing that enemies have their 
**properties listed as well, but I'm not entirely sure how to get them precisely.
**This I haven't messed with or tinkered with too much, though, so maybe it's not
**too difficult.  I'm not sure, though.  I THINK I've found the address for enemy
**being hit by a bullet which would be great to keep track of.  Multiply every 
**bullet collision by 2 maybe and every enemy destruction by 10.  It would be even
**better to differentiate the types of enemies (normal/mini*boss/boss) and make
**different enemies worth more/less.
************SUMMATION:
****Need:
********Address of enemies!!! T*T
****Changes:
********The time to switch to the next iteration.  