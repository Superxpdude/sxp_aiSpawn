/*
	SXP_spawn_fnc_activate
	Author: Superxpdude
	Spawns a set of units from the spawn queue
	
	Executes only on the server
	
	Parameters:
		0: String - ID to spawn
	
	Returns: Nothing
*/

// Only run on the server
if (!isServer) exitWith {};

params [
	["_id", nil, [""]]
];

if (isNil "_id") exitWith {};

{
	if ((_x select 0) == _id) then {
		private _args = _x select 2;
		switch (toLower (_x select 1)) do {
			case "garrison": {_args spawn SXP_spawn_fnc_garrisonSpawn;};
		};
		SXP_spawn_queue set [_forEachIndex, nil];
	};
} forEach SXP_spawn_queue;

// This removes all nil entries from the array (and it's decently fast too)
SXP_spawn_queue = SXP_spawn_queue arrayIntersect SXP_spawn_queue;