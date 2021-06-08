using System;
using System.Collections.Generic;
using System.IO;
using System.Net;
using System.Net.Sockets;
using System.Reflection;
using System.Text;
using System.Threading;
using AllocsFixes.FileCache;
using AllocsFixes.NetConnections.Servers.Web.Handlers;
using UnityEngine;
using UnityEngine.Profiling;

namespace AllocsFixes.NetConnections.Servers.Web
{
    public class Web : IConsoleServer
    {
        private const int GUEST_PERMISSION_LEVEL = 2000;
        public static int handlingCount;
        public static int currentHandlers;
        public static long totalHandlingTime = 0;
        private readonly HttpListener _listener = new HttpListener();
        private readonly string dataFolder;
        private readonly Dictionary<string, PathHandler> handlers = new CaseInsensitiveStringDictionary<PathHandler>();
        private readonly bool useStaticCache;

        public ConnectionHandler connectionHandler;

        public Web()
        {
            try
            {
                int webPort = GamePrefs.GetInt(EnumUtils.Parse<EnumGamePrefs>("ControlPanelPort"));
                if (webPort < 1 || webPort > 65533)
                {
                    Log.Out("Webserver not started (ControlPanelPort not within 1-65533)");
                    return;
                }

                if (!Directory.Exists(Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location) +
                                       "/webserver"))
                {
                    Log.Out("Webserver not started (folder \"webserver\" not found in WebInterface mod folder)");
                    return;
                }

                // TODO: Read from config
                useStaticCache = false;

                dataFolder = Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location) + "/webserver";

                if (!HttpListener.IsSupported)
                {
                    Log.Out("Webserver not started (needs Windows XP SP2, Server 2003 or later or Mono)");
                    return;
                }

                handlers.Add(
                    "/index.htm",
                    new SimpleRedirectHandler("/static/index.html"));
                handlers.Add(
                    "/favicon.ico",
                    new SimpleRedirectHandler("/static/favicon.ico"));
                handlers.Add(
                    "/session/",
                    new SessionHandler(
                        "/session/",
                        dataFolder,
                        this)
                );
                handlers.Add(
                    "/userstatus",
                    new UserStatusHandler()
                );
                if (useStaticCache)
                {
                    handlers.Add(
                        "/static/",
                        new StaticHandler(
                            "/static/",
                            dataFolder,
                            new SimpleCache(),
                            false)
                    );
                }
                else
                {
                    handlers.Add(
                        "/static/",
                        new StaticHandler(
                            "/static/",
                            dataFolder,
                            new DirectAccess(),
                            false)
                    );
                }

                handlers.Add(
                    "/itemicons/",
                    new ItemIconHandler(
                        "/itemicons/",
                        true)
                );

                handlers.Add(
                    "/map/",
                    new StaticHandler(
                        "/map/",
                        GameUtils.GetSaveGameDir() + "/map",
                        MapRendering.MapRendering.GetTileCache(),
                        false,
                        "web.map")
                );

                handlers.Add(
                    "/api/",
                    new ApiHandler("/api/")
                );

                handlers.Add(
                    "/sse/",
                    new SSEHandler("sse")
                );

                connectionHandler = new ConnectionHandler();

                _listener.Prefixes.Add(string.Format("http://*:{0}/", webPort + 2));
                _listener.Start();

                SdtdConsole.Instance.RegisterServer(this);

                _listener.BeginGetContext(HandleRequest, _listener);

                Log.Out("Started Webserver on " + (webPort + 2));
            }
            catch (Exception e)
            {
                Log.Out("Error in Web.ctor: " + e);
            }
        }

        public void Disconnect()
        {
            try
            {
                _listener.Stop();
                _listener.Close();
            }
            catch (Exception e)
            {
                Log.Out("Error in Web.Disconnect: " + e);
            }
        }

        public void SendLine(string _line)
        {
            connectionHandler.SendLine(_line);
        }

        public void SendLog(string _text, string _trace, LogType _type)
        {
            // Do nothing, handled by LogBuffer internally
        }

        public static bool isSslRedirected(HttpListenerRequest _req)
        {
            string proto = _req.Headers["X-Forwarded-Proto"];
            if (!string.IsNullOrEmpty(proto))
            {
                return proto.Equals("https", StringComparison.OrdinalIgnoreCase);
            }

            return false;
        }

        private readonly Version HttpProtocolVersion = new Version(1, 1);

#if ENABLE_PROFILER
		private readonly CustomSampler authSampler = CustomSampler.Create ("Auth");
		private readonly CustomSampler handlerSampler = CustomSampler.Create ("Handler");
#endif

        private void HandleRequest(IAsyncResult _result)
        {
            if (!_listener.IsListening)
            {
                return;
            }

            Interlocked.Increment(ref handlingCount);
            Interlocked.Increment(ref currentHandlers);

            //				MicroStopwatch msw = new MicroStopwatch ();
#if ENABLE_PROFILER
			Profiler.BeginThreadProfiling ("AllocsMods", "WebRequest");
			HttpListenerContext ctx = _listener.EndGetContext (_result);
			try {
#else
            HttpListenerContext ctx = _listener.EndGetContext(_result);
            _listener.BeginGetContext(HandleRequest, _listener);
#endif
            try
            {
                HttpListenerRequest request = ctx.Request;
                HttpListenerResponse response = ctx.Response;
                response.SendChunked = false;

                response.ProtocolVersion = HttpProtocolVersion;

                WebConnection conn;
#if ENABLE_PROFILER
				authSampler.Begin ();
#endif
                int permissionLevel = DoAuthentication(request, out conn);
#if ENABLE_PROFILER
				authSampler.End ();
#endif


                //Log.Out ("Login status: conn!=null: {0}, permissionlevel: {1}", conn != null, permissionLevel);


                if (conn != null)
                {
                    Cookie cookie = new Cookie("sid", conn.SessionID, "/");
                    cookie.Expired = false;
                    cookie.Expires = new DateTime(2020, 1, 1);
                    cookie.HttpOnly = true;
                    cookie.Secure = false;
                    response.AppendCookie(cookie);
                }

                // No game yet -> fail request
                if (GameManager.Instance.World == null)
                {
                    response.StatusCode = (int)HttpStatusCode.ServiceUnavailable;
                    return;
                }

                if (request.Url.AbsolutePath.Length < 2)
                {
                    handlers["/index.htm"].HandleRequest(request, response, conn, permissionLevel);
                    return;
                }
                else
                {
                    foreach (KeyValuePair<string, PathHandler> kvp in handlers)
                    {
                        if (request.Url.AbsolutePath.StartsWith(kvp.Key))
                        {
                            if (!kvp.Value.IsAuthorizedForHandler(conn, permissionLevel))
                            {
                                response.StatusCode = (int)HttpStatusCode.Forbidden;
                                if (conn != null)
                                {
                                    //Log.Out ("Web.HandleRequest: user '{0}' not allowed to access '{1}'", conn.SteamID, kvp.Value.ModuleName);
                                }
                            }
                            else
                            {
#if ENABLE_PROFILER
								handlerSampler.Begin ();
#endif
                                kvp.Value.HandleRequest(request, response, conn, permissionLevel);
#if ENABLE_PROFILER
								handlerSampler.End ();
#endif
                            }

                            return;
                        }
                    }
                }

                // Not really relevant for non-debugging purposes:
                //Log.Out ("Error in Web.HandleRequest(): No handler found for path \"" + request.Url.AbsolutePath + "\"");
                response.StatusCode = (int)HttpStatusCode.NotFound;
            }
            catch (IOException e)
            {
                if (e.InnerException is SocketException)
                {
                    Log.Out("Error in Web.HandleRequest(): Remote host closed connection: " +
                             e.InnerException.Message);
                }
                else
                {
                    Log.Out("Error (IO) in Web.HandleRequest(): " + e);
                }
            }
            catch (Exception e)
            {
                Log.Error("Error in Web.HandleRequest(): ");
                Log.Exception(e);
            }
            finally
            {
                if (ctx != null && !ctx.Response.SendChunked)
                {
                    ctx.Response.Close();
                }

                //					msw.Stop ();
                //					totalHandlingTime += msw.ElapsedMicroseconds;
                //					Log.Out ("Web.HandleRequest(): Took {0} µs", msw.ElapsedMicroseconds);
                Interlocked.Decrement(ref currentHandlers);
            }
#if ENABLE_PROFILER
			} finally {
				_listener.BeginGetContext (HandleRequest, _listener);
				Profiler.EndThreadProfiling ();
			}
#endif
        }

        private int DoAuthentication(HttpListenerRequest _req, out WebConnection _con)
        {
            _con = null;

            string sessionId = null;
            if (_req.Cookies["sid"] != null)
            {
                sessionId = _req.Cookies["sid"].Value;
            }

            if (!string.IsNullOrEmpty(sessionId))
            {
                WebConnection con = connectionHandler.IsLoggedIn(sessionId, _req.RemoteEndPoint.Address);
                if (con != null)
                {
                    _con = con;
                    return GameManager.Instance.adminTools.GetUserPermissionLevel(_con.SteamID.ToString());
                }
            }

            if (_req.QueryString["adminuser"] != null && _req.QueryString["admintoken"] != null)
            {
                WebPermissions.AdminToken admin = WebPermissions.Instance.GetWebAdmin(_req.QueryString["adminuser"],
                    _req.QueryString["admintoken"]);
                if (admin != null)
                {
                    return admin.permissionLevel;
                }

                Log.Warning("Invalid Admintoken used from " + _req.RemoteEndPoint);
            }

            if (_req.Url.AbsolutePath.StartsWith("/session/verify", StringComparison.OrdinalIgnoreCase))
            {
                try
                {
                    ulong id = OpenID.Validate(_req);
                    if (id > 0)
                    {
                        WebConnection con = connectionHandler.LogIn(id, _req.RemoteEndPoint.Address);
                        _con = con;
                        int level = GameManager.Instance.adminTools.GetUserPermissionLevel(id.ToString());
                        Log.Out("Steam OpenID login from {0} with ID {1}, permission level {2}",
                            _req.RemoteEndPoint.ToString(), con.SteamID, level);
                        return level;
                    }

                    Log.Out("Steam OpenID login failed from {0}", _req.RemoteEndPoint.ToString());
                }
                catch (Exception e)
                {
                    Log.Error("Error validating login:");
                    Log.Exception(e);
                }
            }

            return GUEST_PERMISSION_LEVEL;
        }

        public static void SetResponseTextContent(HttpListenerResponse _resp, string _text)
        {
            byte[] buf = Encoding.UTF8.GetBytes(_text);
            _resp.ContentLength64 = buf.Length;
            _resp.ContentType = "text/html";
            _resp.ContentEncoding = Encoding.UTF8;
            _resp.OutputStream.Write(buf, 0, buf.Length);
        }
    }
}