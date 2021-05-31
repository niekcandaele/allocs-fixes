using System.Net;

namespace AllocsFixes.NetConnections.Servers.Web.Handlers
{
    public class SimpleRedirectHandler : PathHandler
    {
        private readonly string target;

        public SimpleRedirectHandler(string _target, string _moduleName = null) : base(_moduleName)
        {
            target = _target;
        }

        public override void HandleRequest(WebSocketSharp.Net.HttpListenerRequest _req, WebSocketSharp.Net.HttpListenerResponse _resp, WebConnection _user,
            int _permissionLevel)
        {
            // There is a _resp.Redirect() method
            // But for some reason, it redirects to a file:// url
            // Which doesn't work (clients dont have these files locally)
            // So we do a redirect by manually setting header and status code
            _resp.StatusCode = (int)HttpStatusCode.Redirect;
            _resp.SetHeader("Location", target);
        }
    }
}