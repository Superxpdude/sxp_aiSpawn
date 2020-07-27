/*
	SXP_spawn_fnc_areaCreate
	Author: Superxpdude
	Creates areas used by the unit spawning system
	Initializes all triggers that are synced to the provided game logic using the settings provided.
	
	Executes only on the server
	
	Parameters:
		0: Object - Game logic
		
	Returns: Nothing
*/

// Only run on the server
if (!isServer) exitWith {};

params [
	["_logic", nil, [objNull]]
];

if (isNil "_logic") exitWith {};

_triggers = [_logic, "EmptyDetector"] call BIS_fnc_synchronizedObjects;

