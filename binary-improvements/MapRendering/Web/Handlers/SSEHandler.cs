using System;
using System.Net;
using System.Text;
using UnityEngine;
using AllocsFixes.JSON;
using System.Collections.Generic;
using System.Linq;
using System.Text.RegularExpressions;

// Implemented following HTML spec
// https://html.spec.whatwg.org/multipage/server-sent-events.html

namespace AllocsFixes.NetConnections.Servers.Web.Handlers
{
    public class SSEHandler : PathHandler
    {
        private static readonly Regex logMessageMatcher =
			new Regex (@"^([0-9]{4}-[0-9]{2}-[0-9]{2})T([0-9]{2}:[0-9]{2}:[0-9]{2}) ([0-9]+[,.][0-9]+) [A-Z]+ (.*)$");

        private List<HttpListenerResponse> openLogResps = new List<HttpListenerResponse>();
        private readonly string moduleName;
        public SSEHandler(string _moduleName = null) : base(_moduleName)
        {
            Logger.Main.LogCallbacks += LogCallback;
            moduleName = _moduleName;
        }

        public override void HandleRequest(HttpListenerRequest _req, HttpListenerResponse _resp, WebConnection _user,
            int _permissionLevel)
        {
            string apiName = _req.Url.AbsolutePath.Remove (0, moduleName.Length + 2);

            // Keep the request open
            _resp.SendChunked = true;

            _resp.AddHeader("Content-Type", "text/event-stream");
            _resp.OutputStream.Flush();

            switch (apiName)
            {
                case "log":
                    openLogResps.Add(_resp);
                    break;
                default:
                    _resp.StatusCode = (int)HttpStatusCode.NotFound;
                    break;
            }
        }

        private void LogCallback(string _msg, string _trace, LogType _type)
        {
            LogEntry le = new LogEntry ();
            Match match = logMessageMatcher.Match (_msg);

    		if (match.Success) {
				le.date = match.Groups [1].Value;
				le.time = match.Groups [2].Value;
				le.uptime = match.Groups [3].Value;
				le.message = match.Groups [4].Value;
			} else {
				DateTime dt = DateTime.Now;
				le.date = string.Format ("{0:0000}-{1:00}-{2:00}", dt.Year, dt.Month, dt.Day);
				le.time = string.Format ("{0:00}:{1:00}:{2:00}", dt.Hour, dt.Minute, dt.Second);
				le.uptime = "";
				le.message = _msg;
			}

            StringBuilder sb = new StringBuilder();
            JSONObject data = new JSONObject();
            data.Add("msg", new JSONString(le.message));
            data.Add("type", new JSONString(_type.ToString()));
            data.Add("trace", new JSONString(_trace));
            data.Add("date", new JSONString(le.date));
            data.Add("time", new JSONString(le.time));
            data.Add("uptime", new JSONString(le.uptime));
            
            sb.AppendLine("event: logLine");
            sb.AppendLine($"data: {data.ToString()}");
            sb.AppendLine("");

            string output = sb.ToString();
            for (int i = openLogResps.Count - 1; i >= 0; i--)
            {
                HttpListenerResponse _resp = openLogResps[i];
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
                        this.openLogResps.RemoveAt (i);
                    }
                }
                catch (System.Exception e)
                {
                    _resp.OutputStream.Close();
                    this.openLogResps.RemoveAt (i);
                    Log.Error("Exception while handling SSE log send:");
                    Log.Exception(e);
                }
            }

        }

        public class LogEntry {
			public string date;
			public string message;
			public string time;
			public string trace;
			public LogType type;
			public string uptime;
		}
    }
}