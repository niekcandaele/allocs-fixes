using System;
using System.Collections.Generic;
using System.Text.RegularExpressions;

namespace AllocsFixes.PersistentData {
	[Serializable]
	public class Players {
		public readonly Dictionary<string, Player> Dict = new Dictionary<string, Player> (StringComparer.OrdinalIgnoreCase);

		public Player this [string _steamId, bool _create] {
			get {
				if (string.IsNullOrEmpty (_steamId)) {
					return null;
				}

				if (Dict.ContainsKey (_steamId)) {
					return Dict [_steamId];
				}

				if (!_create || _steamId.Length != 17) {
					return null;
				}

				Log.Out ("Created new player entry for ID: " + _steamId);
				Player p = new Player (_steamId);
				Dict.Add (_steamId, p);
				return p;
			}
		}

		public int Count {
			get { return Dict.Count; }
		}

//		public Player GetPlayerByNameOrId (string _nameOrId, bool _ignoreColorCodes)
//		{
//			string sid = GetSteamID (_nameOrId, _ignoreColorCodes);
//			if (sid != null)
//				return this [sid];
//			else
//				return null;
//		}

		public string GetSteamID (string _nameOrId, bool _ignoreColorCodes) {
			if (_nameOrId == null || _nameOrId.Length == 0) {
				return null;
			}

			long tempLong;
			if (_nameOrId.Length == 17 && long.TryParse (_nameOrId, out tempLong)) {
				return _nameOrId;
			}

			int entityId;
			if (int.TryParse (_nameOrId, out entityId)) {
				foreach (KeyValuePair<string, Player> kvp in Dict) {
					if (kvp.Value.IsOnline && kvp.Value.EntityID == entityId) {
						return kvp.Key;
					}
				}
			}

			foreach (KeyValuePair<string, Player> kvp in Dict) {
				string name = kvp.Value.Name;
				if (_ignoreColorCodes) {
					name = Regex.Replace (name, "\\[[0-9a-fA-F]{6}\\]", "");
				}

				if (kvp.Value.IsOnline && name.EqualsCaseInsensitive (_nameOrId)) {
					return kvp.Key;
				}
			}

			return null;
		}
	}
}