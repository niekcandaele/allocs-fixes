using System.Net;
using System.Text;
using UnityEngine;
using AllocsFixes.JSON;
using System.Collections.Generic;
using System.Linq;

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
            Log.Out("HANDLING A SSE THING");

            // Keep the request open
            _resp.KeepAlive = true;

            _resp.AddHeader("Content-Type", "text/event-stream");
            _resp.OutputStream.Flush();

            openResps.Add(_resp);
            Log.Out($"OpenResps = {openResps.Count}");
        }

        private void LogCallback(string _msg, string _trace, LogType _type)
        {
            JSONObject obj = new JSONObject();
            obj.Add("msg", new JSONString(_msg));
            obj.Add("type", new JSONString(_type.ToString()));
            obj.Add("trace", new JSONString(_trace));

            // Create a copy of the list, so we can remove elements while iterating
            List<HttpListenerResponse> copy = this.openResps.ToList();
            copy.ForEach(_resp =>
            {
                try
                {

                    if (_resp.OutputStream.CanWrite)
                    {
                        byte[] buf = Encoding.UTF8.GetBytes(obj.ToString());
                        _resp.OutputStream.Write(buf, 0, buf.Length);
                        _resp.OutputStream.Flush();
                    }
                    else
                    {
                        this.openResps.Remove(_resp);
                    }
                }
                catch (System.Exception)
                {
                    _resp.OutputStream.Close();
                    this.openResps.Remove(_resp);
                }

            });
        }

    }
}