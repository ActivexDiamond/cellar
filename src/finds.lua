--[[

------------------------------ Simple ------------------------------
========== Circular cave with large rocks inside.
survive: 3
born: 5-8

generations: few dozen
probability: 0.3 or less.

{born 5-8} clears out most of the map except the edges {over a long time},
creating a sort of circular hole in the middle.

Few small rocks survive in the center of it.
{survive 3} increases the odds of those rocks surviving, and their size.

With this setup;
	Increasing the {probability} increases the number of those center rocks.
		And that's about it, since everything else is cleared out.
	Increasing the number of {generations} decreses the size of the center hole.
		Eventually turning it into a full cave system (but one with an interesting design).
	
	Thus, by tweaking those two variables, you can tweak; 
		The size of the hole.
		The number and size of rocks in the center.
		
As always, {survive 0} leads to there being random single-cells left randomly around..

--]]