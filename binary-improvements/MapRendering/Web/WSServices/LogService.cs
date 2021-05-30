using WebSocketSharp;
using WebSocketSharp.Server;


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
            Send("Hello World");
        }

    }

}