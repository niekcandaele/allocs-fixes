using System.Net;
using AllocsFixes.JSON;
using AllocsFixes.LiveData;

namespace AllocsFixes.NetConnections.Servers.Web.API {
	public class GetWebUIUpdates : WebAPI {
		public override void HandleRequest (WebSocketSharp.Net.HttpListenerRequest _req, WebSocketSharp.Net.HttpListenerResponse _resp, WebConnection _user,
			int _permissionLevel) {
			int latestLine;
			if (_req.QueryString ["latestLine"] == null ||
			    !int.TryParse (_req.QueryString ["latestLine"], out latestLine)) {
				latestLine = 0;
			}

			JSONObject result = new JSONObject ();

			JSONObject time = new JSONObject ();
			time.Add ("days", new JSONNumber (GameUtils.WorldTimeToDays (GameManager.Instance.World.worldTime)));
			time.Add ("hours", new JSONNumber (GameUtils.WorldTimeToHours (GameManager.Instance.World.worldTime)));
			time.Add ("minutes", new JSONNumber (GameUtils.WorldTimeToMinutes (GameManager.Instance.World.worldTime)));
			result.Add ("gametime", time);

			result.Add ("players", new JSONNumber (GameManager.Instance.World.Players.Count));
			result.Add ("hostiles", new JSONNumber (Hostiles.Instance.GetCount ()));
			result.Add ("animals", new JSONNumber (Animals.Instance.GetCount ()));

			result.Add ("newlogs", new JSONNumber (LogBuffer.Instance.LatestLine - latestLine));

			WriteJSON (_resp, result);
		}

		public override int DefaultPermissionLevel () {
			return 2000;
		}
	}
}