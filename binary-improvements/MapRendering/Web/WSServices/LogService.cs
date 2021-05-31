using WebSocketSharp;
using WebSocketSharp.Server;
using UnityEngine;


namespace AllocsFixes.NetConnections.Servers.Web.WSServices
{
    public class LogService : WebSocketBehavior
    {

        public LogService()
        {
            Logger.Main.LogCallbacks += LogCallback;
        }
        protected override void OnMessage(MessageEventArgs e)
        {
            Send("PONG");
        }

        protected override void OnOpen()
        {
            Send("Connected");
        }

        private void LogCallback(string _msg, string _trace, LogType _type)
        {
            Send(_msg);
        }

    }

}