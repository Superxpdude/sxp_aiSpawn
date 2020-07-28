/*
	SXP_spawn_fnc_garrisonCreate
	Author: Superxpdude
	Initializes a garrison
	Initializes all triggers that are synced to the provided game logic using the settings provided.
	
	Executes only on the server
	
	Parameters:
		0: Object - Game logic
		1: String - Garrison list to use
		2: String (Opt) - String to "queue" the spawns instead of spawning them immediately. Defaults to False.
		3: Number (Opt) - Number of units to spawn. Uses number in garrison list when undefined.
		
	Returns: Nothing
*/

// Only run on the server
if (!isServer) exitWith {};

params [
	["_logic", nil, [objNull]],
	["_list", nil, [""]],
	["_queue", false, [false,""]],
	["_amount", nil, [0]]
];

if (isNil "_logic") exitWith {};
if (isNil "_list") exitWith {};

_triggers = [_logic, "EmptyDetector", false] call BIS_fnc_synchronizedObjects;

{
	private _id = switch (true) do {
		case (_queue isEqualType ""): {_queue};
		case (count (triggerText _x) > 0): {triggerText _x};
		case (count (vehicleVarName _logic) > 0): {vehicleVarName _logic};
		default {str (ceil (random 100000))};
	};
	if (_queue isEqualTo true) then {_queue = _id};
	private _args = [_x, _list, _id, _amount];
	if (_queue isEqualType "") then {
		SXP_spawn_queue pushBack [_queue,"garrison",_args];
	} else {
		_args spawn SXP_spawn_fnc_garrisonSpawn;
	};
} forEach _triggers;