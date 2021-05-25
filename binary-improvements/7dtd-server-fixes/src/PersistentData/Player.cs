using System;
using System.Runtime.Serialization;
using UnityEngine;

namespace AllocsFixes.PersistentData {
	[Serializable]
	public class Player {
		private readonly string steamId;
		private int entityId;
		private string name;
		private string ip;
		private long totalPlayTime;

		[OptionalField] private DateTime lastOnline;

		private Inventory inventory;

		[OptionalField] private int lastPositionX, lastPositionY, lastPositionZ;

		[OptionalField] [Obsolete ("experience no longer available, use level and expToNextLevel instead")]
		private uint experience;

		[OptionalField] private bool chatMuted;
		[OptionalField] private int maxChatLength;
		[OptionalField] private string chatColor;
		[OptionalField] private bool chatName;
		[OptionalField] private uint expToNextLevel;
		[OptionalField] private int level;

		[NonSerialized] private ClientInfo clientInfo;

		public string SteamID {
			get { return steamId; }
		}

        public int EntityID {
            get { return entityId; }
        }

		public string Name {
			get { return name == null ? string.Empty : name; }
		}

		public string IP {
			get { return ip == null ? string.Empty : ip; }
		}

		public Inventory Inventory {
			get {
				if (inventory == null) {
					inventory = new Inventory ();
				}

				return inventory;
			}
		}

		public bool IsOnline {
			get { return clientInfo != null; }
		}

		public ClientInfo ClientInfo {
			get { return clientInfo; }
		}

		public EntityPlayer Entity {
			get {
				if (IsOnline) {
					return GameManager.Instance.World.Players.dict [clientInfo.entityId];
				}

				return null;
			}
		}

		public long TotalPlayTime {
			get {
				if (IsOnline) {
					return totalPlayTime + (long) (DateTime.Now - lastOnline).TotalSeconds;
				}

				return totalPlayTime;
			}
		}

		public DateTime LastOnline {
			get {
				if (IsOnline) {
					return DateTime.Now;
				}

				return lastOnline;
			}
		}

		public Vector3i LastPosition {
			get {
				if (IsOnline) {
					return new Vector3i (Entity.GetPosition ());
				}

				return new Vector3i (lastPositionX, lastPositionY, lastPositionZ);
			}
		}

		public bool LandProtectionActive {
			get {
				return GameManager.Instance.World.IsLandProtectionValidForPlayer (GameManager.Instance
					.GetPersistentPlayerList ().GetPlayerData (SteamID));
			}
		}

		public float LandProtectionMultiplier {
			get {
				return GameManager.Instance.World.GetLandProtectionHardnessModifierForPlayer (GameManager.Instance
					.GetPersistentPlayerList ().GetPlayerData (SteamID));
			}
		}


		[Obsolete ("Experience no longer available, use Level instead")]
		public uint Experience {
			get { return 0; }
		}

		public float Level {
			get {
				float expForNextLevel =
					(int) Math.Min (Progression.BaseExpToLevel * Mathf.Pow (Progression.ExpMultiplier, level + 1),
						int.MaxValue);
				float fLevel = level + 1f - expToNextLevel / expForNextLevel;
				return fLevel;
			}
		}

		public bool IsChatMuted {
			get { return chatMuted; }
			set { chatMuted = value; }
		}

		public int MaxChatLength {
			get {
				if (maxChatLength == 0) {
					maxChatLength = 255;
				}

				return maxChatLength;
			}
			set { maxChatLength = value; }
		}

		public string ChatColor {
			get {
				if (chatColor == null || chatColor == "") {
					chatColor = "";
				}

				return chatColor;
			}

			set { chatColor = value; }
		}

		public bool ChatName {
			get { return chatName; }

			set { chatName = value; }
		}

		public Player (string _steamId) {
			steamId = _steamId;
			inventory = new Inventory ();
		}

		public void SetOffline () {
			if (clientInfo == null) {
				return;
			}

			Log.Out ("Player set to offline: " + steamId);
			lastOnline = DateTime.Now;
			try {
				Vector3i lastPos = new Vector3i (Entity.GetPosition ());
				lastPositionX = lastPos.x;
				lastPositionY = lastPos.y;
				lastPositionZ = lastPos.z;
				totalPlayTime += (long) (Time.timeSinceLevelLoad - Entity.CreationTimeSinceLevelLoad);
			} catch (NullReferenceException) {
				Log.Out ("Entity not available. Something seems to be wrong here...");
			}

			clientInfo = null;
		}

		public void SetOnline (ClientInfo _ci) {
			Log.Out ("Player set to online: " + steamId);
			clientInfo = _ci;
            entityId = _ci.entityId;
			name = _ci.playerName;
			ip = _ci.ip;
			lastOnline = DateTime.Now;
		}

		public void Update (PlayerDataFile _pdf) {
			UpdateProgression (_pdf);
			inventory.Update (_pdf);
		}

		private void UpdateProgression (PlayerDataFile _pdf) {
			if (_pdf.progressionData.Length <= 0) {
				return;
			}

			using (PooledBinaryReader pbr = MemoryPools.poolBinaryReader.AllocSync (false)) {
				pbr.SetBaseStream (_pdf.progressionData);
				long posBefore = pbr.BaseStream.Position;
				pbr.BaseStream.Position = 0;
				Progression p = Progression.Read (pbr, null);
				pbr.BaseStream.Position = posBefore;
				expToNextLevel = (uint) p.ExpToNextLevel;
				level = p.Level;
			}
		}
	}
}