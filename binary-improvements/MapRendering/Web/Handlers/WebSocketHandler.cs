using System.Net;
using AllocsFixes.JSON;
using AllocsFixes.NetConnections.Servers.Web.API;

namespace AllocsFixes.NetConnections.Servers.Web.Handlers
{
    public class WebSocketHandler : PathHandler
    {
        public WebSocketHandler(string _moduleName = null) : base(_moduleName)
        {
        }

        public override void HandleRequest(HttpListenerRequest _req, HttpListenerResponse _resp, WebConnection _user,
            int _permissionLevel)
        {
            JSONObject result = new JSONObject();

            result.Add("test", new JSONString("hey"));


            WebAPI.WriteJSON(_resp, result);
        }
    }
}