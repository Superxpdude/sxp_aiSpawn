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
	private _positions = [_x] call BIS_fnc_buildingPositions;
	_positions = _positions call BIS_fnc_arrayShuffle; // Shuffle the positions array
	_positions resize (ceil ((count _positions) * _buildingOccupancy)); // Eliminate extra positions according to occupancy limit
	_buildingPositions append _positions;
} forEach _buildings;

// Create a group for our garrison
private _group = createGroup _side;
SXP_spawn_groups pushBack [_id, _group];

// Start spawning the units
for [{_i = 0}, {(_i < _unitCount) AND ((count _buildingPositions) > 0)}, {_i = _i + 1}] do {
	private _pos = selectRandom _buildingPositions;
	private _unitClass = if ((count _unitWeights) == (count _unitTypes)) then {
		_unitTypes selectRandomWeighted _unitWeights
	} else {
		selectRandom _unitTypes;
	};
	private _unit = _group createUnit [_unitClass, _pos, [], 0, "NONE"];
	_unit setPosATL _pos;
	_unit setUnitPos "UP";
	_unit forceSpeed 0;
	_unit disableAI "PATH";
	SXP_spawn_units pushback [_id, _unit];
	_buildingPositions deleteAt (_buildingPositions find _pos);
};

_group deleteGroupWhenEmpty true;