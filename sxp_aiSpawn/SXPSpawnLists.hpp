class SXP_spawn
{
	class spawnLists
	{
		class example
		{
			// Array of groups to spawn
			// Entries should consist of the an array followed by the weight
			// Entries are an array of the group, and the "cost" of the group
			// Group definitions should be either the classname of the group, or an array of unit classnames
			groups[] = {
				// NATO infantry squad, has a "cost" of 8, and a weight of 1
				{"BUS_InfSquad",8}, 1,
				// Spawns specific units
				{{"B_soldier_SL_F", "B_soldier_F", "B_soldier_F", "B_soldier_F"}, 4}, 1
			};
			transports[] = {
				{"B_Truck_01_covered_F", 1}, 1
			};
			landVehicles[] = {
				{"B_MBT_01_cannon_F",50}, 1
			};
			airVehicles[] = {
				{"B_Plane_CAS_01_dynamicLoadout_F", 150}, 1
			};
			weights[] = {
				1, // Infantry
				1, // Land vehicles
				1 // Air vehicles
			};
		};
	};
};