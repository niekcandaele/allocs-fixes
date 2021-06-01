using System.IO;
using System.Net;
using AllocsFixes.FileCache;

namespace AllocsFixes.NetConnections.Servers.Web.Handlers {
	public class StaticHandler : PathHandler {
		private readonly AbstractCache cache;
		private readonly string datapath;
		private readonly bool logMissingFiles;
		private readonly string staticPart;

		public StaticHandler (string _staticPart, string _filePath, AbstractCache _cache, bool _logMissingFiles,
			string _moduleName = null) : base (_moduleName) {
			staticPart = _staticPart;
			datapath = _filePath + (_filePath [_filePath.Length - 1] == '/' ? "" : "/");
			cache = _cache;
			logMissingFiles = _logMissingFiles;
		}

		public override void HandleRequest (WebSocketSharp.Net.HttpListenerRequest _req, WebSocketSharp.Net.HttpListenerResponse _resp, WebConnection _user,
			int _permissionLevel) {
			string fn = _req.Url.AbsolutePath.Remove (0, staticPart.Length);

			byte[] content = cache.GetFileContent (datapath + fn);

			if (content != null) {
				_resp.ContentType = MimeType.GetMimeType (Path.GetExtension (fn));
				_resp.ContentLength64 = content.Length;
				_resp.OutputStream.Write (content, 0, content.Length);
			} else {
				_resp.StatusCode = (int) HttpStatusCode.NotFound;
				if (logMissingFiles) {
					Log.Out ("Web:Static:FileNotFound: \"" + _req.Url.AbsolutePath + "\" @ \"" + datapath + fn + "\"");
				}
			}
		}
	}
}