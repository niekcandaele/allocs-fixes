using System;
using System.Collections.Generic;
using AllocsFixes.PersistentData;

namespace AllocsFixes.CustomCommands {
	public class ListKnownPlayers : ConsoleCmdAbstract {
		public override string GetDescription () {
			return "lists all players that were ever online";
		}

		public override string GetHelp () {
			return "Usage:\n" +
			       "  1. listknownplayers\n" +
			       "  2. listknownplayers -online\n" +
			       "  3. listknownplayers -notbanned\n" +
			       "  4. listknownplayers <player name / steamid>\n" +
			       "1. Lists all players that have ever been online\n" +
			       "2. Lists only the players that are currently online\n" +
			       "3. Lists only the players that are not banned\n" +
			       "4. Lists all players whose name contains the given string or matches the given SteamID";
		}

		public override string[] GetCommands () {
			return new[] {"listknownplayers", "lkp"};
		}

		public override void Execute (List<string> _params, CommandSenderInfo _senderInfo) {
			AdminTools admTools = GameManager.Instance.adminTools;

			bool onlineOnly = false;
			bool notBannedOnly = false;
			string nameFilter = string.Empty;
			bool isSteamId = false;

			if (_params.Count == 1) {
				long steamid;
				if (_params [0].EqualsCaseInsensitive ("-online")) {
					onlineOnly = true;
				} else if (_params [0].EqualsCaseInsensitive ("-notbanned")) {
					notBannedOnly = true;
				} else if (_params [0].Length == 17 && long.TryParse (_params [0], out steamid)) {
					isSteamId = true;
				} else {
					nameFilter = _params [0];
				}
			}

			if (isSteamId) {
				Player p = PersistentContainer.Instance.Players [_params [0], false];

				if (p != null) {
					SdtdConsole.Instance.Output (string.Format (
						"{0}. {1}, id={2}, steamid={3}, online={4}, ip={5}, playtime={6} m, seen={7}",
						0, p.Name, p.EntityID, _params [0], p.IsOnline, p.IP,
						p.TotalPlayTime / 60,
						p.LastOnline.ToString ("yyyy-MM-dd HH:mm"))
					);
				} else {
					SdtdConsole.Instance.Output (string.Format ("SteamID {0} unknown!", _params [0]));
				}
			} else {
				int num = 0;
				foreach (KeyValuePair<string, Player> kvp in PersistentContainer.Instance.Players.Dict) {
					Player p = kvp.Value;

					if (
						(!onlineOnly || p.IsOnline)
						&& (!notBannedOnly || !admTools.IsBanned (kvp.Key))
						&& (nameFilter.Length == 0 || p.Name.ContainsCaseInsensitive (nameFilter))
					) {
						SdtdConsole.Instance.Output (string.Format (
							"{0}. {1}, id={2}, steamid={3}, online={4}, ip={5}, playtime={6} m, seen={7}",
							++num, p.Name, p.EntityID, kvp.Key, p.IsOnline, p.IP,
							p.TotalPlayTime / 60,
							p.LastOnline.ToString ("yyyy-MM-dd HH:mm"))
						);
					}
				}

				SdtdConsole.Instance.Output ("Total of " + PersistentContainer.Instance.Players.Count + " known");
			}
		}
	}
}