using WebSocketSharp;
using WebSocketSharp.Server;
using UnityEngine;
using AllocsFixes.JSON;


namespace AllocsFixes.NetConnections.Servers.Web.WSServices
{
    public class LogService : WebSocketBehavior
    {
        protected override void OnMessage(MessageEventArgs e)
        {
            Send("PONG");
        }

        protected override void OnOpen()
        {
            Logger.Main.LogCallbacks += LogCallback;
            Send("Connected");
        }

        protected override void OnClose(CloseEventArgs e)
        {
            Logger.Main.LogCallbacks -= LogCallback;
        }

        private void LogCallback(string _msg, string _trace, LogType _type)
        {
            if (this.ConnectionState == WebSocketState.Open)
            {
                JSONObject obj = new JSONObject();
                obj.Add("msg", new JSONString(_msg));
                obj.Add("type", new JSONString(_type.ToString()));
                obj.Add("trace", new JSONString(_trace));
                Send(obj.ToString());
            }
        }

    }

}