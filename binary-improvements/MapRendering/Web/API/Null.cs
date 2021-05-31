using System.Net;
using System.Text;

namespace AllocsFixes.NetConnections.Servers.Web.API {
	public class Null : WebAPI {
		public override void HandleRequest (WebSocketSharp.Net.HttpListenerRequest _req, WebSocketSharp.Net.HttpListenerResponse _resp, WebConnection _user,
			int _permissionLevel) {
			_resp.ContentLength64 = 0;
			_resp.ContentType = "text/plain";
			_resp.ContentEncoding = Encoding.ASCII;
			_resp.OutputStream.Write (new byte[] { }, 0, 0);
		}
	}
}