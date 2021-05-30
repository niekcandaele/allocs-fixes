using System.Net;
using AllocsFixes.JSON;
using AllocsFixes.NetConnections.Servers.Web.API;
using System.Net.WebSockets;
using System.Threading.Tasks;
using System.Threading;
using System.Text;
using System;

namespace AllocsFixes.NetConnections.Servers.Web.Handlers
{
    public class WebSocketHandler : PathHandler
    {
        public WebSocketHandler(HttpListener _listener, string _moduleName = null) : base(_moduleName)
        {
            this._listener = _listener;
        }

        private HttpListener _listener { get; set; }

        public override async void HandleRequest(WebSocketSharp.Net.HttpListenerRequest _req, WebSocketSharp.Net.HttpListenerResponse _resp, WebConnection _user,
            int _permissionLevel)
        {
            Log.Out("Handling ws path");
            try
            {
                HttpListenerContext context = _listener.GetContext();
                Log.Out("got the context blyat");
                Log.Out(context.Request.ToString());
                if (context.Request.IsWebSocketRequest)
                {
                    Log.Out("Initialized a Websocket");
                    WebSocketContext webSocketContext = await context.AcceptWebSocketAsync(subProtocol: null);
                    WebSocket websocket = webSocketContext.WebSocket;
                    await SendString(websocket, "Hello World");
                }
                else
                {
                    Log.Out("Tis geen WS");
                    context.Response.StatusCode = (int)HttpStatusCode.BadRequest;
                    context.Response.Close();
                }

                Log.Out("tot ier");
            }
            catch (System.Exception e)
            {
                Log.Error("OEPSIE");
                Log.Error(e.ToString());
                throw;
            }


        }

        public static Task SendString(WebSocket ws, String data)
        {
            var encoded = Encoding.UTF8.GetBytes(data);
            var buffer = new ArraySegment<Byte>(encoded, 0, encoded.Length);
            return ws.SendAsync(buffer, WebSocketMessageType.Text, true, CancellationToken.None);
        }
    }
}