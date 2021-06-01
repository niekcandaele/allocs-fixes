using System.Collections.Generic;
using System.Net;
using AllocsFixes.JSON;
using AllocsFixes.PersistentData;

namespace AllocsFixes.NetConnections.Servers.Web.API {
	public class GetPlayerInventories : WebAPI {
		public override void HandleRequest (WebSocketSharp.Net.HttpListenerRequest _req, WebSocketSharp.Net.HttpListenerResponse _resp, WebConnection _user,
			int _permissionLevel) {

			bool showIconColor, showIconName;
			GetPlayerInventory.GetInventoryArguments (_req, out showIconColor, out showIconName);

			JSONArray AllInventoriesResult = new JSONArray ();

			foreach (KeyValuePair<string, Player> kvp in PersistentContainer.Instance.Players.Dict) {
				Player p = kvp.Value;

				if (p == null) {
					continue;
				}

				if (p.IsOnline) {
					AllInventoriesResult.Add (GetPlayerInventory.DoPlayer (kvp.Key, p, showIconColor, showIconName));
				}
			}

			WriteJSON (_resp, AllInventoriesResult);
		}
	}
}