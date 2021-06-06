using System.Net;
using System.Text;
using System.Threading.Tasks;

namespace AllocsFixes.NetConnections.Servers.Web.Handlers {
	public class SSEHandler : PathHandler {
		public SSEHandler (string _moduleName = null) : base (_moduleName) {}

		async public override void HandleRequest (HttpListenerRequest _req, HttpListenerResponse _resp, WebConnection _user,
			int _permissionLevel) {
                Log.Out("HANDLING A SSE THING");

                // Keep the request open
                _resp.KeepAlive = true;

                _resp.AddHeader("Content-Type", "text/event-stream");
                _resp.OutputStream.Flush();
              
/*                 Logger.Main.LogCallbacks += (string _msg, string _trace, LogType _type) => {
			        byte[] buf = Encoding.UTF8.GetBytes (_msg);
			        _resp.OutputStream.Write (buf, 0, buf.Length);
                    _resp.OutputStream.FlushAsync();
                }; */
                int count = 0;

                while (count < 10)
                {
                    Log.Out("Pingingggg");
                    byte[] buf = Encoding.UTF8.GetBytes ("PING");
			        await _resp.OutputStream.WriteAsync (buf, 0, buf.Length);
                    await _resp.OutputStream.FlushAsync();
                    await Task.Delay(1000);
                    count++;
                }

                _resp.Close();

		}


	}
}