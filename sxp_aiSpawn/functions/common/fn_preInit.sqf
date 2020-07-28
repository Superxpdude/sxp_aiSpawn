/*
	SXP_spawn_fnc_preInit
	Author: Superxpdude
	Initializes the spawning system
	
	Executes only on the server
	
	Parameters:
		None. Executed in preInit
	
	Returns: Nothing
*/
// Only run on the server
if (!isServer) exitWith {};

// Initialize some variables
// All units spawned by the spawning system
SXP_spawn_units = [];
// All groups spawned by the spawning system
SXP_spawn_groups = [];
// All *pending* spawns for the spawning system. Used in cases where you want to trigger spawns at a specific time
SXP_spawn_queue = [];