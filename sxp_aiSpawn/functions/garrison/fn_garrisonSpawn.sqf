/*
	SXP_spawn_fnc_garrisonSpawn
	Author: Superxpdude
	Spawns units for a garrison
	
	Executes only on the server
	
	Parameters:
		0: Object - Trigger
		1: String - Garrison list to use
		2: String - ID. Used to keep track of which group a unit was spawned with.
		3: Number (Opt) - Number of units to spawn. Uses number in garrison list when undefined.
		
	Returns: Nothing
*/

// Only run on the server
if (!isServer) exitWith {};

params [
	["_trigger", nil, [objNull]],
	["_list", nil, [""]],
	["_id", "", [""]],
	["_amount", nil, [0]]
];

// Grab some trigger values
private _triggerPos = getPosATL _trigger;
// Find the "range" of our trigger to allow square triggers to work
private _triggerRange = if ((triggerArea _trigger) select 3) then {
	sqrt (((triggerArea _trigger) select 0)^2 + ((triggerArea _trigger) select 1)^2) // Math
} else {
	(triggerArea _trigger) select 0
};

if (_id == "") then {_id == (triggerText _trigger)};

// Get our config values
private _baseConfig = (missionConfigFile >> "SXP_spawn" >> "garrisons" >> _list);
private _side = [west, east, independent, civilian] select ([(_baseConfig >> "side") call BIS_fnc_getCfgData] param [0, 0, [0]]);
private _unitTypes = [(_baseConfig >> "units") call BIS_fnc_getCfgDataArray] param [0, [], [[]]];
private _unitWeights = [(_baseConfig >> "unitWeights") call BIS_fnc_getCfgDataArray] param [0, [], [[]], [0, count _unitTypes]];
private _unitCount = if (!isNil "_amount") then {_amount} else {[(_baseConfig >> "unitCount") call BIS_fnc_getCfgData] param [0, 0, [0]]};
private _buildingBlacklist = [(_baseConfig >> "buildingBlacklist") call BIS_fnc_getCfgDataArray] param [0, [], [[]]];
private _buildingOccupancy = [(_baseConfig >> "buildingOccupancy") call BIS_fnc_getCfgData] param [0, 1, [0]];

// Collect a list of valid building positions
// Grab a list of buildings within our trigger
private _buildings = ((_triggerPos nearObjects ["House", _triggerRange]) inAreaArray _trigger);
if (count _buildings <= 0) exitWith {["[SXP_spawn_fnc_garrisonSpawn] Could not find any buildings"] call BIS_fnc_error};
private _buildingPositions = [];
// Iterate through all of the buildings that we found, and grab the valid AI positions.
{
	if ((typeOf _x) in _buildingBlacklist) exitWith {};
	// Grab a list of positions. Ignore positions that already have a unit there.
	private _positions = ([_x] call BIS_fnc_buildingPositions) select {count (_x nearEntities [["Man"],0.5]) <= 0};
	_positions = _positions call BIS_fnc_arrayShuffle; // Shuffle the positions array
	_positions resize (ceil ((count _positions) * _buildingOccupancy)); // Eliminate extra positions according to occupancy limit
	_buildingPositions append _positions;
} forEach _buildings;

// Create a group for our garrison
private _group = createGroup _side;
private _units = [];
_group setVariable ["SXP_spawn_id", _id, true];
_group setVariable ["SXP_spawn_type", "garrison", true];
SXP_spawn_groups pushBack [_id, _group];

// Start spawning the units
for [{_i = 0}, {(_i < _unitCount) AND ((count _buildingPositions) > 0)}, {_i = _i + 1}] do {
	
	// Select our position and unit type
	private _pos = selectRandom _buildingPositions;
	private _unitClass = if ((count _unitWeights) == (count _unitTypes)) then {
		_unitTypes selectRandomWeighted _unitWeights
	} else {
		selectRandom _unitTypes;
	};
	
	// Spawn the unit
	private _unit = _group createUnit [_unitClass, _pos, [], 0, "NONE"];
	_unit setPosATL _pos;
	_unit setUnitPos "UP";
	_unit forceSpeed 0;
	_unit disableAI "PATH";
	_unit setVariable ["SXP_spawn_id", _id, true];
	_unit setVariable ["SXP_spawn_type", "garrison", true];
	
	// Add the unit to our arrays
	_units pushBack _unit;
	SXP_spawn_units pushback [_id, _unit];
	
	// Make sure that the position is no longer used.
	_buildingPositions deleteAt (_buildingPositions find _pos);
	
	// Rotate the unit to ensure a good line of sight
	// Inspiration taken from the "Achilles" zeus mod's garrison function
	private _eyePos = eyePos _unit; // Grab the position of the unit's eyes
	private _startAngle = (round random 360); // Start at a random angle
	// Check every 10 degrees until we find a direction that has a good line of sight
	for "_angle" from _startAngle to (_startAngle + 360) step 10 do {
		// Check to see if we have a good line of sight
		_relPos = [10 * (sin _angle), 10 * (cos _angle), 0];
		if !(lineIntersects [_eyePos, _eyePos vectorAdd _relPos]) exitWith {
			// If we have a good line of sight, exit.
			_unit doWatch (_pos vectorAdd _relPos);
		};
		
		// Check to see if we have a decent line of sight
		_relPos = [3 * (sin _angle), 3 * (cos _angle), 0];
		if !(lineIntersects [_eyePos, _eyePos vectorAdd _relPos]) then {
			// If we have a decent line of sight, continue to try and find a good one.
			_unit doWatch (_pos vectorAdd _relPos);
		};
	};
};

// Add all units spawned to all curators
{
	_x addCuratorEditableObjects [_units, true];
} forEach allCurators;

_group deleteGroupWhenEmpty true;
_group enableDynamicSimulation true;

// Add the ID to the activated list
SXP_spawn_activated pushBackUnique _id;