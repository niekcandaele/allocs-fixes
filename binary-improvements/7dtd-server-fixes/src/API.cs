using System.Collections.Generic;
using AllocsFixes.PersistentData;
using System;

namespace AllocsFixes {
	public class API : IModApi {
		public void InitMod () {
			ModEvents.GameStartDone.RegisterHandler (GameAwake);
			ModEvents.GameShutdown.RegisterHandler (GameShutdown);
			ModEvents.SavePlayerData.RegisterHandler (SavePlayerData);
			ModEvents.PlayerSpawning.RegisterHandler (PlayerSpawning);
			ModEvents.PlayerDisconnected.RegisterHandler (PlayerDisconnected);
			ModEvents.PlayerSpawnedInWorld.RegisterHandler (PlayerSpawned);
			ModEvents.ChatMessage.RegisterHandler (ChatMessage);
		}

		public void GameAwake () {
			try {
				PersistentContainer.Load ();
			} catch (Exception e) {
				Log.Out ("Error in StateManager.Awake: " + e);
			}
		}

		public void GameShutdown () {
			try {
				Log.Out ("Server shutting down!");
				PersistentContainer.Instance.Save ();
			} catch (Exception e) {
				Log.Out ("Error in StateManager.Shutdown: " + e);
			}
		}

		public void SavePlayerData (ClientInfo _cInfo, PlayerDataFile _playerDataFile) {
			try {
				PersistentContainer.Instance.Players [_cInfo.playerId, true].Update (_playerDataFile);
			} catch (Exception e) {
				Log.Out ("Error in GM_SavePlayerData: " + e);
			}
		}

		public void PlayerSpawning (ClientInfo _cInfo, int _chunkViewDim, PlayerProfile _playerProfile) {
			try {
				Log.Out ("Player connected" +
					", entityid=" + _cInfo.entityId +
					", name=" + _cInfo.playerName +
					", steamid=" + _cInfo.playerId +
					", steamOwner=" + _cInfo.ownerId +
					", ip=" + _cInfo.ip
				);
			} catch (Exception e) {
				Log.Out ("Error in AllocsLogFunctions.RequestToSpawnPlayer: " + e);
			}
		}

		public void PlayerDisconnected (ClientInfo _cInfo, bool _bShutdown) {
			try {
				Player p = PersistentContainer.Instance.Players [_cInfo.playerId, false];
				if (p != null) {
					p.SetOffline ();
				} else {
					Log.Out ("Disconnected player not found in client list...");
				}

				PersistentContainer.Instance.Save ();
			} catch (Exception e) {
				Log.Out ("Error in AllocsLogFunctions.PlayerDisconnected: " + e);
			}
		}

		public void PlayerSpawned (ClientInfo _cInfo, RespawnType _respawnReason, Vector3i _spawnPos) {
			try {
				PersistentContainer.Instance.Players [_cInfo.playerId, true].SetOnline (_cInfo);
				PersistentContainer.Instance.Save ();
			} catch (Exception e) {
				Log.Out ("Error in AllocsLogFunctions.PlayerSpawnedInWorld: " + e);
			}
		}

		private const string ANSWER =
			"     [ff0000]I[-] [ff7f00]W[-][ffff00]A[-][80ff00]S[-] [00ffff]H[-][0080ff]E[-][0000ff]R[-][8b00ff]E[-]";

		public bool ChatMessage (ClientInfo _cInfo, EChatType _type, int _senderId, string _msg, string _mainName,
			bool _localizeMain, List<int> _recipientEntityIds) {
			if (string.IsNullOrEmpty (_msg) || !_msg.EqualsCaseInsensitive ("/alloc")) {
				return true;
			}

			if (_cInfo != null) {
				Log.Out ("Sent chat hook reply to {0}", _cInfo.playerId);
				_cInfo.SendPackage (NetPackageManager.GetPackage<NetPackageChat> ().Setup (EChatType.Whisper, -1, ANSWER, "", false, null));
			} else {
				Log.Error ("ChatHookExample: Argument _cInfo null on message: {0}", _msg);
			}

			return false;
		}
	}
}