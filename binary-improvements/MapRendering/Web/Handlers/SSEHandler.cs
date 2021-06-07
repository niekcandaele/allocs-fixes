using System.Net;
using System.Text;
using UnityEngine;
using AllocsFixes.JSON;
using System.Collections.Generic;
using System.Linq;

// Implemented following HTML spec
// https://html.spec.whatwg.org/multipage/server-sent-events.html

namespace AllocsFixes.NetConnections.Servers.Web.Handlers
{
    public class SSEHandler : PathHandler
    {
        private List<HttpListenerResponse> openResps = new List<HttpListenerResponse>();
        public SSEHandler(string _moduleName = null) : base(_moduleName)
        {
            Logger.Main.LogCallbacks += LogCallback;
        }

        public override void HandleRequest(HttpListenerRequest _req, HttpListenerResponse _resp, WebConnection _user,
            int _permissionLevel)
        {
            // Keep the request open
            _resp.SendChunked = true;

            _resp.AddHeader("Content-Type", "text/event-stream");
            _resp.OutputStream.Flush();

            openResps.Add(_resp);
        }

        private void LogCallback(string _msg, string _trace, LogType _type)
        {
            StringBuilder sb = new StringBuilder();

            JSONObject data = new JSONObject();
            data.Add("msg", new JSONString(_msg));
            data.Add("type", new JSONString(_type.ToString()));
            data.Add("trace", new JSONString(_trace));

            sb.AppendLine("event: logLine");
            sb.AppendLine($"data: {data.ToString()}");
            sb.AppendLine("");

            string output = sb.ToString();
            for (int i = openResps.Count - 1; i >= 0; i--)
            {
                HttpListenerResponse _resp = openResps[i];
                try
                {

                    if (_resp.OutputStream.CanWrite)
                    {
                        byte[] buf = Encoding.UTF8.GetBytes(output);
                        _resp.OutputStream.Write(buf, 0, buf.Length);
                        _resp.OutputStream.Flush();
                    }
                    else
                    {
                        this.openResps.RemoveAt (i);
                    }
                }
                catch (System.Exception e)
                {
                    _resp.OutputStream.Close();
                    this.openResps.RemoveAt (i);
                    Log.Error("Exception while handling SSE log send:");
                    Log.Exception(e);
                }
            }

        }
    }
}