using System;
using System.Collections.Generic;
using AllocsFixes.PersistentData;

namespace AllocsFixes.CustomCommands {
	public class ListLandProtection : ConsoleCmdAbstract {
		public override string GetDescription () {
			return "lists all land protection blocks and owners";
		}

		public override string GetHelp () {
			return "Usage:\n" +
			       "  1. listlandprotection summary\n" +
			       "  2. listlandprotection <steam id / player name / entity id> [parseable]\n" +
			       "  3. listlandprotection nearby [length]\n" +
			       "1. Lists only players that own claimstones, the number they own and the protection status\n" +
			       "2. Lists only the claims of the player given by his SteamID / entity id / playername, including the individual claim positions.\n" +
			       "   If \"parseable\" is specified the output of the individual claims will be in a format better suited for programmatical readout.\n" +
			       "3. Lists claims in a square with edge length of 64 (or the optionally specified size) around the executing player\n";
		}

		public override string[] GetCommands () {
			return new[] {"listlandprotection", "llp"};
		}

		public override void Execute (List<string> _params, CommandSenderInfo _senderInfo) {
			if (_senderInfo.RemoteClientInfo != null) {
				if (_params.Count >= 1 && _params [0].EqualsCaseInsensitive ("nearby")) {
					_params.Add (_senderInfo.RemoteClientInfo.playerId);
				}
			}

			World w = GameManager.Instance.World;
			PersistentPlayerList ppl = GameManager.Instance.GetPersistentPlayerList ();

			bool summaryOnly = false;
			string steamIdFilter = string.Empty;
			Vector3i closeTo = default (Vector3i);
			bool onlyCloseToPlayer = false;
			int closeToDistance = 32;
			bool parseableOutput = false;

			if (_params.Contains ("parseable")) {
				parseableOutput = true;
				_params.Remove ("parseable");
			}

			if (_params.Count == 1) {
				long tempLong;

				if (_params [0].EqualsCaseInsensitive ("summary")) {
					summaryOnly = true;
				} else if (_params [0].Length == 17 && long.TryParse (_params [0], out tempLong)) {
					steamIdFilter = _params [0];
				} else {
					ClientInfo ci = ConsoleHelper.ParseParamIdOrName (_params [0]);
					if (ci != null) {
						steamIdFilter = ci.playerId;
					} else {
						SdtdConsole.Instance.Output ("Player name or entity id \"" + _params [0] + "\" not found.");
						return;
					}
				}
			} else if (_params.Count >= 2) {
				if (_params [0].EqualsCaseInsensitive ("nearby")) {
					try {
						if (_params.Count == 3) {
							if (!int.TryParse (_params [1], out closeToDistance)) {
								SdtdConsole.Instance.Output ("Given length is not an integer!");
								return;
							}

							closeToDistance /= 2;
						}

						ClientInfo ci = ConsoleHelper.ParseParamSteamIdOnline (_params [_params.Count - 1]);
						EntityPlayer ep = w.Players.dict [ci.entityId];
						closeTo = new Vector3i (ep.GetPosition ());
						onlyCloseToPlayer = true;
					} catch (Exception e) {
						SdtdConsole.Instance.Output ("Error getting current player's position");
						Log.Out ("Error in ListLandProtection.Run: " + e);
						return;
					}
				} else {
					SdtdConsole.Instance.Output ("Illegal parameter list");
					return;
				}
			}


			LandClaimList.OwnerFilter[] ownerFilters = null;
			if (!string.IsNullOrEmpty (steamIdFilter)) {
				ownerFilters = new[] {LandClaimList.SteamIdFilter (steamIdFilter)};
			}

			LandClaimList.PositionFilter[] posFilters = null;
			if (onlyCloseToPlayer) {
				posFilters = new[] {LandClaimList.CloseToFilter2dRect (closeTo, closeToDistance)};
			}

			Dictionary<Player, List<Vector3i>> claims = LandClaimList.GetLandClaims (ownerFilters, posFilters);

			foreach (KeyValuePair<Player, List<Vector3i>> kvp in claims) {
				SdtdConsole.Instance.Output (string.Format (
					"Player \"{0} ({1})\" owns {4} keystones (protected: {2}, current hardness multiplier: {3})",
					kvp.Key.Name,
					kvp.Key.SteamID,
					kvp.Key.LandProtectionActive,
					kvp.Key.LandProtectionMultiplier,
					kvp.Value.Count));
				if (!summaryOnly) {
					foreach (Vector3i v in kvp.Value) {
						if (parseableOutput) {
							SdtdConsole.Instance.Output ("LandProtectionOf: id=" + kvp.Key.SteamID +
							                             ", playerName=" + kvp.Key.Name + ", location=" + v);
						} else {
							SdtdConsole.Instance.Output ("   (" + v + ")");
						}
					}
				}
			}

			if (string.IsNullOrEmpty (steamIdFilter)) {
				SdtdConsole.Instance.Output ("Total of " + ppl.m_lpBlockMap.Count + " keystones in the game");
			}
		}
	}
}