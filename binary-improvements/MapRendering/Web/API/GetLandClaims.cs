using System.Collections.Generic;
using System.Net;
using AllocsFixes.JSON;
using AllocsFixes.PersistentData;

namespace AllocsFixes.NetConnections.Servers.Web.API {
	public class GetLandClaims : WebAPI {
		public override void HandleRequest (HttpListenerRequest _req, HttpListenerResponse _resp, WebConnection _user,
			int _permissionLevel) {
			string requestedSteamID = string.Empty;

			if (_req.QueryString ["steamid"] != null) {
				ulong lViewersSteamID;
				requestedSteamID = _req.QueryString ["steamid"];
				if (requestedSteamID.Length != 17 || !ulong.TryParse (requestedSteamID, out lViewersSteamID)) {
					_resp.StatusCode = (int) HttpStatusCode.BadRequest;
					Web.SetResponseTextContent (_resp, "Invalid SteamID given");
					return;
				}
			}

			// default user, cheap way to avoid 'null reference exception'
			_user = _user ?? new WebConnection ("", IPAddress.None, 0L);

			bool bViewAll = WebConnection.CanViewAllClaims (_permissionLevel);

			JSONObject result = new JSONObject ();
			result.Add ("claimsize", new JSONNumber (GamePrefs.GetInt (EnumUtils.Parse<EnumGamePrefs> ("LandClaimSize"))));

			JSONArray claimOwners = new JSONArray ();
			result.Add ("claimowners", claimOwners);

			LandClaimList.OwnerFilter[] ownerFilters = null;
			if (!string.IsNullOrEmpty (requestedSteamID) || !bViewAll) {
				if (!string.IsNullOrEmpty (requestedSteamID) && !bViewAll) {
					ownerFilters = new[] {
						LandClaimList.SteamIdFilter (_user.SteamID.ToString ()),
						LandClaimList.SteamIdFilter (requestedSteamID)
					};
				} else if (!bViewAll) {
					ownerFilters = new[] {LandClaimList.SteamIdFilter (_user.SteamID.ToString ())};
				} else {
					ownerFilters = new[] {LandClaimList.SteamIdFilter (requestedSteamID)};
				}
			}

			LandClaimList.PositionFilter[] posFilters = null;

			Dictionary<Player, List<Vector3i>> claims = LandClaimList.GetLandClaims (ownerFilters, posFilters);

			foreach (KeyValuePair<Player, List<Vector3i>> kvp in claims) {
//				try {
					JSONObject owner = new JSONObject ();
					claimOwners.Add (owner);

					owner.Add ("steamid", new JSONString (kvp.Key.SteamID));
					owner.Add ("claimactive", new JSONBoolean (kvp.Key.LandProtectionActive));

					if (kvp.Key.Name.Length > 0) {
						owner.Add ("playername", new JSONString (kvp.Key.Name));
					} else {
						owner.Add ("playername", new JSONNull ());
					}

					JSONArray claimsJson = new JSONArray ();
					owner.Add ("claims", claimsJson);

					foreach (Vector3i v in kvp.Value) {
						JSONObject claim = new JSONObject ();
						claim.Add ("x", new JSONNumber (v.x));
						claim.Add ("y", new JSONNumber (v.y));
						claim.Add ("z", new JSONNumber (v.z));

						claimsJson.Add (claim);
					}
//				} catch {
//				}
			}

			WriteJSON (_resp, result);
		}
	}
}