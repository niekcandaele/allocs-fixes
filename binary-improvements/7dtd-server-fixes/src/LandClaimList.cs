using System;
using System.Collections.Generic;
using AllocsFixes.PersistentData;

namespace AllocsFixes {
	public class LandClaimList {
		public delegate bool OwnerFilter (Player _owner);

		public delegate bool PositionFilter (Vector3i _position);

		public static Dictionary<Player, List<Vector3i>> GetLandClaims (OwnerFilter[] _ownerFilters,
			PositionFilter[] _positionFilters) {
			Dictionary<Vector3i, PersistentPlayerData> d = GameManager.Instance.GetPersistentPlayerList ().m_lpBlockMap;
			Dictionary<Player, List<Vector3i>> result = new Dictionary<Player, List<Vector3i>> ();

			if (d == null) {
				return result;
			}

			Dictionary<PersistentPlayerData, List<Vector3i>> owners =
				new Dictionary<PersistentPlayerData, List<Vector3i>> ();
			foreach (KeyValuePair<Vector3i, PersistentPlayerData> kvp in d) {
				bool allowed = true;
				if (_positionFilters != null) {
					foreach (PositionFilter pf in _positionFilters) {
						if (!pf (kvp.Key)) {
							allowed = false;
							break;
						}
					}
				}

				if (allowed) {
					if (!owners.ContainsKey (kvp.Value)) {
						owners.Add (kvp.Value, new List<Vector3i> ());
					}

					owners [kvp.Value].Add (kvp.Key);
				}
			}

			foreach (KeyValuePair<PersistentPlayerData, List<Vector3i>> kvp in owners) {
				Player p = PersistentContainer.Instance.Players [kvp.Key.PlayerId, false];
				if (p == null) {
					p = new Player (kvp.Key.PlayerId);
				}

				bool allowed = true;
				if (_ownerFilters != null) {
					foreach (OwnerFilter of in _ownerFilters) {
						if (!of (p)) {
							allowed = false;
							break;
						}
					}
				}

				if (allowed) {
					result.Add (p, new List<Vector3i> ());
					foreach (Vector3i v in kvp.Value) {
						result [p].Add (v);
					}
				}
			}

			return result;
		}

		public static OwnerFilter SteamIdFilter (string _steamId) {
			return _p => _p.SteamID.Equals (_steamId);
		}

		public static PositionFilter CloseToFilter2dRect (Vector3i _position, int _maxDistance) {
			return _v => Math.Abs (_v.x - _position.x) <= _maxDistance && Math.Abs (_v.z - _position.z) <= _maxDistance;
		}

		public static OwnerFilter OrOwnerFilter (OwnerFilter _f1, OwnerFilter _f2) {
			return _p => _f1 (_p) || _f2 (_p);
		}
	}
}