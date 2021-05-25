#!/bin/bash

#   Copyright 2016 Christian 'Alloc' Illy
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.


# Provides functions to query and validate values for serverconfig.xml

#################################
## Definition of options

serverconfig_ServerPort_QueryName() {
	echo "Base Port"
}
serverconfig_ServerPort_Type() {
	echo "number"
}
serverconfig_ServerPort_Default() {
	echo "26900"
}
serverconfig_ServerPort_Range() {
	echo "1024-65533"
}
serverconfig_ServerPort_Validate() {
	local I=${INSTANCE:-!}
	if [ $(checkGamePortUsed "$1" "$I") -eq 0 ]; then
		echo "1"
	else
		echo "0"
	fi
}
serverconfig_ServerPort_ErrorMessage() {
	echo "Illegal port number or port already in use by another instance."
}


serverconfig_ServerDisabledNetworkProtocols_QueryName() {
	echo "Disabled network protocols"
}
serverconfig_ServerDisabledNetworkProtocols_Type() {
	echo "enum"
}
serverconfig_ServerDisabledNetworkProtocols_Default() {
	echo "1"
}
serverconfig_ServerDisabledNetworkProtocols_Values() {
	config_allowed_values=("None" "SteamNetworking" "SteamNetworking,LiteNetLib" "LiteNetLib")
}


serverconfig_ServerVisibility_QueryName() {
	echo "Public server"
}
serverconfig_ServerVisibility_Type() {
	echo "number"
}
serverconfig_ServerVisibility_Default() {
	echo "2"
}
serverconfig_ServerVisibility_Range() {
	echo "0-2"
}
serverconfig_ServerVisibility_Values() {
	config_allowed_values=("Not listed" "Friends only (only works while at least one player is connected manually. Dedi servers do not have friends!)" "Public")
}


serverconfig_ServerName_QueryName() {
	echo "Server name"
}
serverconfig_ServerName_Type() {
	echo "string"
}
serverconfig_ServerName_Validate() {
	if [ ! -z "$1" ]; then
		echo "1"
	else
		echo "0"
	fi
}
serverconfig_ServerName_ErrorMessage() {
	echo "Server name cannot be empty."
}



serverconfig_ServerDescription_QueryName() {
	echo "Server description"
}
serverconfig_ServerDescription_Type() {
	echo "string"
}



serverconfig_ServerWebsiteURL_QueryName() {
	echo "Server website URL"
}
serverconfig_ServerWebsiteURL_Type() {
	echo "string"
}



serverconfig_ServerPassword_QueryName() {
	echo "Server password"
}
serverconfig_ServerPassword_Type() {
	echo "string"
}



serverconfig_MaxUncoveredMapChunksPerPlayer_QueryName() {
	echo "Max uncovered chunks per player"
}
serverconfig_MaxUncoveredMapChunksPerPlayer_Type() {
	echo "number"
}
serverconfig_MaxUncoveredMapChunksPerPlayer_Default() {
	echo "131072"
}

serverconfig_ServerMaxWorldTransferSpeedKiBs_QueryName() {
	echo "Max download speed for the world (KiB/s"
}
serverconfig_ServerMaxWorldTransferSpeedKiBs_Type() {
	echo "number"
}
serverconfig_ServerMaxWorldTransferSpeedKiBs_Default() {
	echo "512"
}
serverconfig_ServerMaxWorldTransferSpeedKiBs_Range() {
	echo "64-1300"
}

serverconfig_ServerMaxAllowedViewDistance_QueryName() {
	echo "Limit allowed view distance settings of clients"
}
serverconfig_ServerMaxAllowedViewDistance_Type() {
	echo "number"
}
serverconfig_ServerMaxAllowedViewDistance_Default() {
	echo "12"
}
serverconfig_ServerMaxAllowedViewDistance_Range() {
	echo "5-12"
}

serverconfig_HideCommandExecutionLog_QueryName() {
	echo "Hide command execution in log"
}
serverconfig_HideCommandExecutionLog_Type() {
	echo "number"
}
serverconfig_HideCommandExecutionLog_Default() {
	echo "0"
}
serverconfig_HideCommandExecutionLog_Range() {
	echo "0-3"
}
serverconfig_HideCommandExecutionLog_Values() {
	config_allowed_values=("Log all" "Log all but commands from Telnet/ControlPanel" "Also hide commands executed by clients" "Do not log any commands at all")
}




serverconfig_ServerMaxPlayerCount_QueryName() {
 	echo "Max players"
}
serverconfig_ServerMaxPlayerCount_Type() {
 	echo "number"
}
serverconfig_ServerMaxPlayerCount_Default() {
	echo "4"
}
serverconfig_ServerMaxPlayerCount_Range() {
	echo "1-64"
}


serverconfig_ServerReservedSlots_QueryName() {
 	echo "Reserved VIP slots"
}
serverconfig_ServerReservedSlots_Type() {
 	echo "number"
}
serverconfig_ServerReservedSlots_Default() {
	echo "0"
}
serverconfig_ServerReservedSlots_Range() {
	echo "0-64"
}


serverconfig_ServerReservedSlotsPermission_QueryName() {
 	echo "Permission level required for VIP slots"
}
serverconfig_ServerReservedSlotsPermission_Type() {
 	echo "number"
}
serverconfig_ServerReservedSlotsPermission_Default() {
	echo "100"
}
serverconfig_ServerReservedSlotsPermission_Range() {
	echo "0-2000"
}


serverconfig_ServerAdminSlots_QueryName() {
 	echo "Admin slots"
}
serverconfig_ServerAdminSlots_Type() {
 	echo "number"
}
serverconfig_ServerAdminSlots_Default() {
	echo "0"
}
serverconfig_ServerAdminSlots_Range() {
	echo "0-64"
}


serverconfig_ServerAdminSlotsPermission_QueryName() {
 	echo "Permission level required for admin slots"
}
serverconfig_ServerAdminSlotsPermission_Type() {
 	echo "number"
}
serverconfig_ServerAdminSlotsPermission_Default() {
	echo "0"
}
serverconfig_ServerAdminSlotsPermission_Range() {
	echo "0-2000"
}




serverconfig_GameWorld_QueryName() {
	echo "World name"
}
serverconfig_GameWorld_Type() {
	echo "enum"
}
serverconfig_GameWorld_Default() {
	echo "1"
}
serverconfig_GameWorld_Values() {
	config_allowed_values=("RWG" "Navezgane") #  "MP Wasteland Horde" "MP Wasteland Skirmish" "MP Wasteland War"
}



serverconfig_WorldGenSeed_QueryName() {
	echo "Random generation seed (if world RWG)"
}
serverconfig_WorldGenSeed_Type() {
	echo "string"
}
serverconfig_WorldGenSeed_Validate() {
	if [ ! -z "$1" ]; then
		echo "1"
	else
		echo "0"
	fi
}
serverconfig_WorldGenSeed_ErrorMessage() {
	echo "Seed cannot be empty."
}



serverconfig_WorldGenSize_QueryName() {
 	echo "Random generation map size (if world RWG)"
}
serverconfig_WorldGenSize_Type() {
 	echo "number"
}
serverconfig_WorldGenSize_Default() {
	echo "6144"
}
serverconfig_WorldGenSize_Range() {
	echo "2048-16384"
}



serverconfig_GameName_QueryName() {
	echo "World decoration seed"
}
serverconfig_GameName_Type() {
	echo "string"
}
serverconfig_GameName_Validate() {
	if [ ! -z "$1" ]; then
		echo "1"
	else
		echo "0"
	fi
}
serverconfig_GameName_ErrorMessage() {
	echo "Seed cannot be empty."
}



serverconfig_GameDifficulty_QueryName() {
	echo "Difficulty (+ damage given / received)"
}
serverconfig_GameDifficulty_Type() {
	echo "number"
}
serverconfig_GameDifficulty_Default() {
	echo "1"
}
serverconfig_GameDifficulty_Range() {
	echo "0-5"
}
serverconfig_GameDifficulty_Values() {
	config_allowed_values=("Scavenger (200% / 50%)" "Adventurer (150% / 75%)" "Nomad (100% / 100%)" "Warrior (75% / 150%)" "Survivalist (50% / 200%)" "Insane (25% / 250%)")
}



serverconfig_GameMode_QueryName() {
	echo "Game mode"
}
serverconfig_GameMode_Type() {
	echo "enum"
}
serverconfig_GameMode_Default() {
	echo "1"
}
serverconfig_GameMode_Values() {
	config_allowed_values=("GameModeSurvival")
}



serverconfig_ZombieMove_QueryName() {
	echo "Zombie speed, regular"
}
serverconfig_ZombieMove_Type() {
	echo "number"
}
serverconfig_ZombieMove_Default() {
	echo "0"
}
serverconfig_ZombieMove_Range() {
	echo "0-4"
}
serverconfig_ZombieMove_Values() {
	config_allowed_values=("Walk" "Jog" "Run" "Sprint" "Nightmare")
}



serverconfig_ZombieMoveNight_QueryName() {
	echo "Zombie speed, night"
}
serverconfig_ZombieMoveNight_Type() {
	echo "number"
}
serverconfig_ZombieMoveNight_Default() {
	echo "3"
}
serverconfig_ZombieMoveNight_Range() {
	echo "0-4"
}
serverconfig_ZombieMoveNight_Values() {
	config_allowed_values=("Walk" "Jog" "Run" "Sprint" "Nightmare")
}



serverconfig_ZombieFeralMove_QueryName() {
	echo "Zombie speed, ferals"
}
serverconfig_ZombieFeralMove_Type() {
	echo "number"
}
serverconfig_ZombieFeralMove_Default() {
	echo "3"
}
serverconfig_ZombieFeralMove_Range() {
	echo "0-4"
}
serverconfig_ZombieFeralMove_Values() {
	config_allowed_values=("Walk" "Jog" "Run" "Sprint" "Nightmare")
}



serverconfig_ZombieBMMove_QueryName() {
	echo "Zombie speed, bloodmoons"
}
serverconfig_ZombieBMMove_Type() {
	echo "number"
}
serverconfig_ZombieBMMove_Default() {
	echo "3"
}
serverconfig_ZombieBMMove_Range() {
	echo "0-4"
}
serverconfig_ZombieBMMove_Values() {
	config_allowed_values=("Walk" "Jog" "Run" "Sprint" "Nightmare")
}




serverconfig_BuildCreate_QueryName() {
	echo "Item spawn menu"
}
serverconfig_BuildCreate_Type() {
	echo "boolean"
}
serverconfig_BuildCreate_Default() {
	echo "false"
}
serverconfig_BuildCreate_ErrorMessage() {
	echo "Not a valid boolean given (true/false or yes/no or y/n)."
}



serverconfig_DayNightLength_QueryName() {
	echo "Length of one day"
}
serverconfig_DayNightLength_Type() {
	echo "number"
}
serverconfig_DayNightLength_Default() {
	echo "60"
}



serverconfig_DayLightLength_QueryName() {
	echo "Duration of daylight (in ingame hours)"
}
serverconfig_DayLightLength_Type() {
	echo "number"
}
serverconfig_DayLightLength_Default() {
	echo "18"
}
serverconfig_DayLightLength_Range() {
	echo "0-24"
}




serverconfig_XPMultiplier_QueryName() {
	echo "XP gain multiplier (%)"
}
serverconfig_XPMultiplier_Type() {
	echo "number"
}
serverconfig_XPMultiplier_Default() {
	echo "100"
}


serverconfig_PartySharedKillRange_QueryName() {
	echo "Party range to share kill / quest XP rewards"
}
serverconfig_PartySharedKillRange_Type() {
	echo "number"
}
serverconfig_PartySharedKillRange_Default() {
	echo "100"
}



serverconfig_PlayerKillingMode_QueryName() {
	echo "Player killing"
}
serverconfig_PlayerKillingMode_Type() {
	echo "number"
}
serverconfig_PlayerKillingMode_Default() {
	echo "3"
}
serverconfig_PlayerKillingMode_Range() {
	echo "0-3"
}
serverconfig_PlayerKillingMode_Values() {
	config_allowed_values=("No player killing" "Kill allies only" "Kill strangers only" "Kill everyone")
}



serverconfig_PersistentPlayerProfiles_QueryName() {
	echo "Persistent player profiles"
}
serverconfig_PersistentPlayerProfiles_Type() {
	echo "boolean"
}
serverconfig_PersistentPlayerProfiles_Default() {
	echo "false"
}
serverconfig_PersistentPlayerProfiles_ErrorMessage() {
	echo "Not a valid boolean given (true/false or yes/no or y/n)."
}



serverconfig_PlayerSafeZoneLevel_QueryName() {
	echo "Safe zone up to player level"
}
serverconfig_PlayerSafeZoneLevel_Type() {
	echo "number"
}
serverconfig_PlayerSafeZoneLevel_Default() {
	echo "5"
}


serverconfig_PlayerSafeZoneHours_QueryName() {
	echo "Safe zone up to played hours"
}
serverconfig_PlayerSafeZoneHours_Type() {
	echo "number"
}
serverconfig_PlayerSafeZoneHours_Default() {
	echo "5"
}


serverconfig_ControlPanelEnabled_QueryName() {
	echo "Enable control panel"
}
serverconfig_ControlPanelEnabled_Type() {
	echo "boolean"
}
serverconfig_ControlPanelEnabled_Default() {
	echo "false"
}
serverconfig_ControlPanelEnabled_ErrorMessage() {
	echo "Not a valid boolean given (true/false or yes/no or y/n)."
}



serverconfig_ControlPanelPort_QueryName() {
	echo "Control panel port"
}
serverconfig_ControlPanelPort_Type() {
	echo "number"
}
serverconfig_ControlPanelPort_Default() {
	echo "8080"
}
serverconfig_ControlPanelPort_Range() {
	echo "1024-65535"
}
serverconfig_ControlPanelPort_Validate() {
	local I=${INSTANCE:-!}
	if [ $(checkTCPPortUsed "$1" "$I") -eq 0 ]; then
		echo "1"
	else
		echo "0"
	fi
}
serverconfig_ControlPanelPort_ErrorMessage() {
	echo "Illegal port number or port already in use by another instance."
}



serverconfig_ControlPanelPassword_QueryName() {
	echo "Control panel password"
}
serverconfig_ControlPanelPassword_Type() {
	echo "string"
}



serverconfig_TelnetPort_QueryName() {
	echo "Telnet port"
}
serverconfig_TelnetPort_Type() {
	echo "number"
}
serverconfig_TelnetPort_Default() {
	echo "8081"
}
serverconfig_TelnetPort_Range() {
	echo "1024-65535"
}
serverconfig_TelnetPort_Validate() {
	local I=${INSTANCE:-!}
	if [ $(checkTCPPortUsed "$1" "$I") -eq 0 ]; then
		echo "1"
	else
		echo "0"
	fi
}
serverconfig_TelnetPort_ErrorMessage() {
	echo "Illegal port number or port already in use by another instance."
}



serverconfig_TelnetPassword_QueryName() {
	echo "Telnet password"
}
serverconfig_TelnetPassword_Type() {
	echo "string"
}



serverconfig_TelnetFailedLoginLimit_QueryName() {
	echo "Max failed login attempts (0 to disable)"
}
serverconfig_TelnetFailedLoginLimit_Type() {
	echo "number"
}
serverconfig_TelnetFailedLoginLimit_Default() {
	echo "10"
}



serverconfig_TelnetFailedLoginsBlocktime_QueryName() {
	echo "Telnet login blocktime after failed logins (seconds)"
}
serverconfig_TelnetFailedLoginsBlocktime_Type() {
	echo "number"
}
serverconfig_TelnetFailedLoginsBlocktime_Default() {
	echo "10"
}



serverconfig_DropOnDeath_QueryName() {
	echo "Drop on Death"
}
serverconfig_DropOnDeath_Type() {
	echo "number"
}
serverconfig_DropOnDeath_Default() {
	echo "1"
}
serverconfig_DropOnDeath_Range() {
	echo "0-4"
}
serverconfig_DropOnDeath_Values() {
	config_allowed_values=("Nothing" "Everything (incl. Equip)" "Toolbelt only" "Backpack only" "Delete all")
}


serverconfig_DropOnQuit_QueryName() {
	echo "Drop on Quit"
}
serverconfig_DropOnQuit_Type() {
	echo "number"
}
serverconfig_DropOnQuit_Default() {
	echo "0"
}
serverconfig_DropOnQuit_Range() {
	echo "0-3"
}
serverconfig_DropOnQuit_Values() {
	config_allowed_values=("Nothing" "Everything (incl. Equip)" "Toolbelt only" "Backpack only")
}




serverconfig_EnemySpawnMode_QueryName() {
	echo "Spawn mode"
}
serverconfig_EnemySpawnMode_Type() {
	echo "boolean"
}
serverconfig_EnemySpawnMode_Default() {
	echo "true"
}
serverconfig_EnemySpawnMode_ErrorMessage() {
	echo "Not a valid boolean given (true/false or yes/no or y/n)."
}


serverconfig_EnemyDifficulty_QueryName() {
	echo "Enemy difficulty"
}
serverconfig_EnemyDifficulty_Type() {
	echo "number"
}
serverconfig_EnemyDifficulty_Default() {
	echo "0"
}
serverconfig_EnemyDifficulty_Range() {
	echo "0-1"
}
serverconfig_EnemyDifficulty_Values() {
	config_allowed_values=("Normal" "Feral")
}


serverconfig_BloodMoonEnemyCount_QueryName() {
	echo "Enemies per Player on Blood moons"
}
serverconfig_BloodMoonEnemyCount_Type() {
	echo "number"
}
serverconfig_BloodMoonEnemyCount_Default() {
	echo "8"
}
serverconfig_BloodMoonEnemyCount_Range() {
	echo "0-64"
}




serverconfig_BlockDamagePlayer_QueryName() {
	echo "Block damage modifier for players (%)"
}
serverconfig_BlockDamagePlayer_Type() {
	echo "number"
}
serverconfig_BlockDamagePlayer_Default() {
	echo "100"
}


serverconfig_BlockDamageAI_QueryName() {
	echo "Block damage modifier for AIs (%)"
}
serverconfig_BlockDamageAI_Type() {
	echo "number"
}
serverconfig_BlockDamageAI_Default() {
	echo "100"
}


serverconfig_BlockDamageAIBM_QueryName() {
	echo "Block damage modifier for AIs during blood moons (%)"
}
serverconfig_BlockDamageAIBM_Type() {
	echo "number"
}
serverconfig_BlockDamageAIBM_Default() {
	echo "100"
}





serverconfig_LootAbundance_QueryName() {
	echo "Loot abundance (%)"
}
serverconfig_LootAbundance_Type() {
	echo "number"
}
serverconfig_LootAbundance_Default() {
	echo "100"
}


serverconfig_LootRespawnDays_QueryName() {
	echo "Loot respawn delay (days)"
}
serverconfig_LootRespawnDays_Type() {
	echo "number"
}
serverconfig_LootRespawnDays_Default() {
	echo "7"
}

serverconfig_BedrollDeadZoneSize_QueryName() {
	echo "Bedroll deadzone size"
}
serverconfig_BedrollDeadZoneSize_Type() {
	echo "number"
}
serverconfig_BedrollDeadZoneSize_Default() {
	echo "15"
}

serverconfig_BedrollExpiryTime_QueryName() {
	echo "Bedroll expiry time (days)"
}
serverconfig_BedrollExpiryTime_Type() {
	echo "number"
}
serverconfig_BedrollExpiryTime_Default() {
	echo "45"
}



serverconfig_LandClaimSize_QueryName() {
	echo "Land claim size"
}
serverconfig_LandClaimSize_Type() {
	echo "number"
}
serverconfig_LandClaimSize_Default() {
	echo "7"
}


serverconfig_LandClaimDeadZone_QueryName() {
	echo "Minimum keystone distance"
}
serverconfig_LandClaimDeadZone_Type() {
	echo "number"
}
serverconfig_LandClaimDeadZone_Default() {
	echo "30"
}


serverconfig_LandClaimExpiryTime_QueryName() {
	echo "Claim expiry time (days)"
}
serverconfig_LandClaimExpiryTime_Type() {
	echo "number"
}
serverconfig_LandClaimExpiryTime_Default() {
	echo "3"
}


serverconfig_LandClaimDecayMode_QueryName() {
	echo "Claim decay mode"
}
serverconfig_LandClaimDecayMode_Type() {
	echo "number"
}
serverconfig_LandClaimDecayMode_Default() {
	echo "0"
}
serverconfig_LandClaimDecayMode_Range() {
	echo "0-2"
}
serverconfig_LandClaimDecayMode_Values() {
	config_allowed_values=("Linear" "Exponential" "Full protection")
}


serverconfig_LandClaimOnlineDurabilityModifier_QueryName() {
	echo "Claim durability modifier - online"
}
serverconfig_LandClaimOnlineDurabilityModifier_Type() {
	echo "number"
}
serverconfig_LandClaimOnlineDurabilityModifier_Default() {
	echo "4"
}


serverconfig_LandClaimOfflineDurabilityModifier_QueryName() {
	echo "Claim durability modifier - offline"
}
serverconfig_LandClaimOfflineDurabilityModifier_Type() {
	echo "number"
}
serverconfig_LandClaimOfflineDurabilityModifier_Default() {
	echo "4"
}




serverconfig_AirDropFrequency_QueryName() {
	echo "Airdrop delay (hours)"
}
serverconfig_AirDropFrequency_Type() {
	echo "number"
}
serverconfig_AirDropFrequency_Default() {
	echo "72"
}


serverconfig_AirDropMarker_QueryName() {
	echo "Enable AirDrop markers"
}
serverconfig_AirDropMarker_Type() {
	echo "boolean"
}
serverconfig_AirDropMarker_Default() {
	echo "false"
}
serverconfig_AirDropMarker_ErrorMessage() {
	echo "Not a valid boolean given (true/false or yes/no or y/n)."
}



serverconfig_MaxSpawnedZombies_QueryName() {
	echo "Maximum number of concurrent zombies"
}
serverconfig_MaxSpawnedZombies_Type() {
	echo "number"
}
serverconfig_MaxSpawnedZombies_Default() {
	echo "60"
}


serverconfig_MaxSpawnedAnimals_QueryName() {
	echo "Maximum number of concurrent animals"
}
serverconfig_MaxSpawnedAnimals_Type() {
	echo "number"
}
serverconfig_MaxSpawnedAnimals_Default() {
	echo "50"
}


serverconfig_EACEnabled_QueryName() {
	echo "Enable EasyAntiCheat"
}
serverconfig_EACEnabled_Type() {
	echo "boolean"
}
serverconfig_EACEnabled_Default() {
	echo "true"
}
serverconfig_EACEnabled_ErrorMessage() {
	echo "Not a valid boolean given (true/false or yes/no or y/n)."
}




#################################
## Edit option functions

configEditServer() {
	local CV
	
	echo "Server"
	echo "--------------------------------"
	for CV in \
			ServerName ServerPassword ServerVisibility ServerPort ServerDisabledNetworkProtocols ServerDescription ServerWebsiteURL \
			HideCommandExecutionLog MaxUncoveredMapChunksPerPlayer ServerMaxWorldTransferSpeedKiBs ServerMaxAllowedViewDistance EACEnabled MaxSpawnedZombies MaxSpawnedAnimals \
			; do
		$1 $CV
	done
	echo
}

configEditSlots() {
	local CV
	
	echo "Slots"
	echo "--------------------------------"
	for CV in \
			ServerMaxPlayerCount ServerReservedSlots ServerReservedSlotsPermission ServerAdminSlots ServerAdminSlotsPermission \
			; do
		$1 $CV
	done
	echo
}

configEditRemoteControl() {
	local CV
	
	echo "Remote control"
	echo "--------------------------------"
	for CV in \
			ControlPanelEnabled ControlPanelPort ControlPanelPassword \
			TelnetPort TelnetPassword TelnetFailedLoginLimit TelnetFailedLoginsBlocktime \
			; do
		if [ "$CV" = "TelnetPort" ]; then
			echo
			echo "NOTE: Telnet will always be enabled for management purposes!"
			echo "Make sure you block external access to this port or set no password"
			echo "so the server will only listen on the loopback interface!"
			echo
		fi
		$1 $CV
	done
	echo
}

configEditGameType() {
	local CV
	
	echo "Game type"
	echo "--------------------------------"
	for CV in \
			GameName GameWorld WorldGenSeed WorldGenSize GameMode \
			; do
		$1 $CV
	done
	echo
}

configEditGeneric() {
	local CV
	
	echo "Generic options"
	echo "--------------------------------"
	for CV in \
			XPMultiplier \
			PartySharedKillRange PlayerKillingMode PersistentPlayerProfiles \
			PlayerSafeZoneLevel PlayerSafeZoneHours \
			BuildCreate \
			BlockDamagePlayer BlockDamageAI BlockDamageAIBM \
			; do
		$1 $CV
	done
	echo
}

configEditDropLoot() {
	local CV
	
	echo "Drop and Loot"
	echo "--------------------------------"
	for CV in \
			DropOnDeath DropOnQuit \
			LootAbundance LootRespawnDays \
			AirDropFrequency AirDropMarker \
			; do
		$1 $CV
	done
	echo
}

configEditTimes() {
	local CV
	
	echo "Times / Durations"
	echo "--------------------------------"
	for CV in \
			DayNightLength DayLightLength \
			; do
		$1 $CV
	done
	echo
}

configEditDifficulty() {
	local CV
	
	echo "Difficulty"
	echo "--------------------------------"
	for CV in \
			GameDifficulty ZombieMove ZombieMoveNight ZombieFeralMove ZombieBMMove \
			EnemySpawnMode EnemyDifficulty \
			BloodMoonEnemyCount BedrollDeadZoneSize BedrollExpiryTime \
			; do
		$1 $CV
	done
	echo
}

configEditLandClaim() {
	local CV
	
	echo "Land claim options"
	echo "--------------------------------"
	for CV in \
			LandClaimSize LandClaimDeadZone LandClaimExpiryTime LandClaimDecayMode \
			LandClaimOnlineDurabilityModifier LandClaimOfflineDurabilityModifier \
			; do
		$1 $CV
	done
	echo
}

configEditAll() {
	configEditServer "$1"
	configEditSlots "$1"
	configEditRemoteControl "$1"
	configEditGameType "$1"
	configEditGeneric "$1"
	configEditDropLoot "$1"
	configEditTimes "$1"
	configEditDifficulty "$1"
	configEditLandClaim "$1"
}





#################################
## Generic worker functions


# List all defined config editing parts
# Returns:
#   List of config funcs
listConfigEditFuncs() {
	local CV
	for CV in $(declare -F | cut -d\  -f3 | grep "^configEdit.*$"); do
		CV=${CV#configEdit}
		printf "%s " "$CV"
	done
}


# List all defined config options
# Returns:
#   List of defined config options
listConfigValues() {
	local CV
	for CV in $(declare -F | cut -d\  -f3 | grep "^serverconfig_.*_Type$"); do
		CV=${CV#serverconfig_}
		CV=${CV%_Type}
		printf "%s " "$CV"
	done
}


# Validate the given value for the given option
# Params:
#   1: Option name
#   2: Value
# Returns:
#   0/1: invalid/valid
isValidOptionValue() {
	local TYPE=$(serverconfig_$1_Type)
	local RANGE=""

	if [ "$TYPE" = "enum" ]; then
		TYPE="number"
		serverconfig_$1_Values
		RANGE=1-${#config_allowed_values[@]}
	else
		if [ "$(type -t serverconfig_$1_Range)" = "function" ]; then
			RANGE=$(serverconfig_$1_Range)
		fi
	fi

	case "$TYPE" in
		number)
			if [ $(isANumber "$2") -eq 0 ]; then
				echo "0"
				return
			fi
			if [ ! -z "$RANGE" ]; then
				local MIN=$(cut -d- -f1 <<< "$RANGE")
				local MAX=$(cut -d- -f2 <<< "$RANGE")
				if [ $2 -lt $MIN -o $2 -gt $MAX ]; then
					echo "0"
					return
				fi
			fi
			;;
		boolean)
			if [ $(isABool "$2") -eq 0 ]; then
				echo "0"
				return
			fi
			;;
		string)
			;;
	esac
	

	if [ "$(type -t serverconfig_$1_Validate)" = "function" ]; then
		if [ $(serverconfig_$1_Validate "$2") -eq 0 ]; then
			echo "0"
			return
		fi
	fi
	
	echo "1"
}

# Query for the value of a single config option
# Will be stored in $configCurrent_$1
# Params:
#   1: Option name
configQueryValue() {
	local TYPE=$(serverconfig_$1_Type)
	local NAME=""
	local RANGE=""
	local DEFAULT=""
	local currentValName=configCurrent_$1

	if [ "$(type -t serverconfig_$1_Values)" = "function" ]; then
		echo "$(serverconfig_$1_QueryName), options:"
		serverconfig_$1_Values
		NAME="Select option"
		if [ "$TYPE" = "enum" ]; then
			local OPTOFFSET=1
		else
			local OPTOFFSET=0
		fi
		for (( i=$OPTOFFSET; i < ${#config_allowed_values[@]}+$OPTOFFSET; i++ )); do
			printf "  %2d: %s\n" $i "${config_allowed_values[$i-$OPTOFFSET]}"
		done
	else
		NAME=$(serverconfig_$1_QueryName)
	fi

	if [ "$TYPE" = "enum" ]; then
		RANGE=1-${#config_allowed_values[@]}
		if [ ! -z "${!currentValName}" ]; then
			for (( i=1; i < ${#config_allowed_values[@]}+1; i++ )); do
				if [ "${!currentValName}" = "${config_allowed_values[$i-1]}" ]; then
					DEFAULT=$i
				fi
			done
			export $currentValName=
		fi
	else
		if [ "$(type -t serverconfig_$1_Range)" = "function" ]; then
			RANGE=$(serverconfig_$1_Range)
		fi
	fi

	if [ -z "$DEFAULT" ]; then
		if [ ! -z "${!currentValName}" ]; then
			DEFAULT=${!currentValName}
		else
			if [ "$(type -t serverconfig_$1_Default)" = "function" ]; then
				DEFAULT=$(serverconfig_$1_Default)
			fi
		fi
	fi

	local prompt=$(printf "%s" "$NAME")
	if [ ! -z "$RANGE" ]; then
		prompt=$(printf "%s (%s)" "$prompt" "$RANGE")
	fi
	if [ ! -z "$DEFAULT" ]; then
		prompt=$(printf "%s [%s]" "$prompt" "$DEFAULT")
	fi
	prompt=$(printf "%s:" "$prompt")
	prompt=$(printf "%-*s " 40 "$prompt")

	while : ; do
		read -p "$prompt" $currentValName
		export $currentValName="${!currentValName:-$DEFAULT}"
		if [ $(isValidOptionValue "$1" "${!currentValName}") -eq 0 ]; then
			if [ "$(type -t serverconfig_$1_ErrorMessage)" = "function" ]; then
				serverconfig_$1_ErrorMessage "${!currentValName}"
			fi
		fi
		[ $(isValidOptionValue "$1" "${!currentValName}") -eq 1 ] && break
	done
	
	if [ "$TYPE" = "boolean" ]; then
		if [ $(getBool ${!currentValName}) -eq 1 ]; then
			export $currentValName="true"
		else
			export $currentValName="false"
		fi
	fi
	if [ "$TYPE" = "enum" ]; then
		export $currentValName="${config_allowed_values[$currentValName-1]}"
	fi
	echo
}

# Set parameters for current instance that have forced values:
#  - TelnetEnabled must be set so that management scripts can work
#  - AdminFileName is made to point to the local instance admins.xml
#  - SaveGameFolder is made to point to the instance folder
#  - UserDataFolder (for GeneratedWorlds) is made to point to the <user home directory>/serverdata/
# Params:
#   1: Instance name
configSetAutoParameters() {
	configCurrent_TelnetEnabled=true
	configCurrent_AdminFileName=admins.xml
	configCurrent_SaveGameFolder="$(getInstancePath "$1")"
	configCurrent_UserDataFolder=$SDTD_BASE/serverdata
}


# Print defined config value
# Params:
#   1: Config option
printConfigValue() {
	local currentValName=configCurrent_$1
	printf "%-25s = %s\n" "$(serverconfig_$1_QueryName)" "${!currentValName}"
}

# Query for an instance name (will be saved in $INSTANCE)
readInstanceName() {
	until [ $(isValidInstanceName "$INSTANCE") -eq 1 ]; do
		read -p "Instance name: " INSTANCE
		if [ $(isValidInstanceName "$INSTANCE") -eq 0 ]; then
			echo "Invalid instance name, may only contain:"
			echo " - letters (A-Z / a-z)"
			echo " - digits (0-9)"
			echo " - underscores (_)"
			echo " - hyphens (-)"
		fi
	done
}

# Undefine the current config values
unsetAllConfigValues() {
	local CV
	for CV in $(listConfigValues); do
		local currentValName=configCurrent_$CV
		export $currentValName=
	done
}

# Load all config values from the config.xml of the given instance
# Params:
#   1: Instance name
loadCurrentConfigValues() {
	local CV
	for CV in $(listConfigValues); do
		local currentValName=configCurrent_$CV
		local cfile=$(getInstancePath "$1")/config.xml
		local XPATH="/ServerSettings/property[@name='$CV']/@value"
		local VAL=$($XMLSTARLET sel -t -v "$XPATH" $cfile)
		if [ ! -z "$VAL" ]; then
			export $currentValName="$VAL"
		fi
	done
}

# Save all config values to the config.xml of the given instance
# Params:
#   1: Instance name
saveCurrentConfigValues() {
	local CV
	for CV in $(listConfigValues) TelnetEnabled AdminFileName SaveGameFolder UserDataFolder; do
		local currentValName=configCurrent_$CV
		local val="${!currentValName}"
		local cfile=$(getInstancePath "$1")/config.xml

		XPATHBASE="/ServerSettings/property[@name='$CV']"

		if [ -z $($XMLSTARLET sel -t -v "$XPATHBASE/@name" $cfile) ]; then
			$XMLSTARLET ed -L \
				-s "/ServerSettings" -t elem -n "property" -v "" \
				-i "/ServerSettings/property[not(@name)]" -t attr -n "name" -v "$CV" \
				-i "$XPATHBASE" -t attr -n "value" -v "$val" \
				$cfile
		else
			$XMLSTARLET ed -L \
				-u "$XPATHBASE/@value" -v "$val" \
				$cfile
		fi
	done
}

# Check if the config template exists
# Returns:
#   0/1: no/yes
configTemplateExists() {
	if [ -f $SDTD_BASE/templates/config.xml ]; then
		echo 1
	else
		echo 0
	fi
}

# Get a single value from a serverconfig
# Params:
#   1: Instance name
#   2: Property name
# Returns:
#   Property value
getConfigValue() {
	local CONF=$(getInstancePath $1)/config.xml
	$XMLSTARLET sel -t -v "/ServerSettings/property[@name='$2']/@value" $CONF
}

# Update a single value in a serverconfig
# Params:
#   1: Instance name
#   2: Property name
#   3: New value
setConfigValue() {
	local CONF=$(getInstancePath $1)/config.xml
	$XMLSTARLET ed -L -u "/ServerSettings/property[@name='$2']/@value" -v "$3" $CONF
}

