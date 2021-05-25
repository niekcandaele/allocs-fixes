using AllocsFixes.NetConnections.Servers.Web;
using AllocsFixes.NetConnections.Servers.Web.Handlers;

namespace AllocsFixes {
	public class API : IModApi {
		public void InitMod () {
			ModEvents.GameStartDone.RegisterHandler (GameStartDone);
			ModEvents.GameShutdown.RegisterHandler (GameShutdown);
			ModEvents.CalcChunkColorsDone.RegisterHandler (CalcChunkColorsDone);
		}

		private void GameStartDone () {
			// ReSharper disable once ObjectCreationAsStatement
			new Web ();
			LogBuffer.Init ();

			if (ItemIconHandler.Instance != null) {
				ItemIconHandler.Instance.LoadIcons ();
			}
		}

		private void GameShutdown () {
			MapRendering.MapRendering.Shutdown ();
		}

		private void CalcChunkColorsDone (Chunk _chunk) {
			MapRendering.MapRendering.RenderSingleChunk (_chunk);
		}
	}
}