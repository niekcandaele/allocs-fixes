using System.Collections.Generic;
using Steamworks;

namespace AllocsFixes.CustomCommands {
	public class PrivateMessageConnections {
		private static readonly Dictionary<CSteamID, CSteamID> senderOfLastPM = new Dictionary<CSteamID, CSteamID> ();

		public static void SetLastPMSender (ClientInfo _sender, ClientInfo _receiver) {
			senderOfLastPM [_receiver.steamId] = _sender.steamId;
		}

		public static ClientInfo GetLastPMSenderForPlayer (ClientInfo _player) {
			if (!senderOfLastPM.ContainsKey (_player.steamId)) {
				return null;
			}

			CSteamID recSteamId = senderOfLastPM [_player.steamId];
			ClientInfo recInfo = ConnectionManager.Instance.Clients.ForSteamId (recSteamId);
			return recInfo;
		}
	}
}