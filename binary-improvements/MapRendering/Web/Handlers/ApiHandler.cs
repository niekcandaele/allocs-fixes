using System;
using System.Collections.Generic;
using System.Net;
using System.Reflection;
using AllocsFixes.NetConnections.Servers.Web.API;
using UnityEngine.Profiling;

namespace AllocsFixes.NetConnections.Servers.Web.Handlers
{
    public class ApiHandler : PathHandler
    {
        private readonly Dictionary<string, WebAPI> apis = new CaseInsensitiveStringDictionary<WebAPI>();
        private readonly string staticPart;

        public ApiHandler(string _staticPart, string _moduleName = null) : base(_moduleName)
        {
            staticPart = _staticPart;

            foreach (Type t in Assembly.GetExecutingAssembly().GetTypes())
            {
                if (!t.IsAbstract && t.IsSubclassOf(typeof(WebAPI)))
                {
                    ConstructorInfo ctor = t.GetConstructor(new Type[0]);
                    if (ctor != null)
                    {
                        WebAPI apiInstance = (WebAPI)ctor.Invoke(new object[0]);
                        addApi(apiInstance.Name, apiInstance);
                    }
                }
            }

            // Add dummy types
            Type dummy_t = typeof(Null);
            ConstructorInfo dummy_ctor = dummy_t.GetConstructor(new Type[0]);
            if (dummy_ctor != null)
            {
                WebAPI dummy_apiInstance = (WebAPI)dummy_ctor.Invoke(new object[0]);

                // Permissions that don't map to a real API
                addApi("viewallclaims", dummy_apiInstance);
                addApi("viewallplayers", dummy_apiInstance);
            }
        }

        private void addApi(string _apiName, WebAPI _api)
        {
            apis.Add(_apiName, _api);
            WebPermissions.Instance.AddKnownModule("webapi." + _apiName, _api.DefaultPermissionLevel());
        }

#if ENABLE_PROFILER
		private static readonly CustomSampler apiHandlerSampler = CustomSampler.Create ("API_Handler");
#endif

        public override void HandleRequest(WebSocketSharp.Net.HttpListenerRequest _req, WebSocketSharp.Net.HttpListenerResponse _resp, WebConnection _user,
            int _permissionLevel)
        {
            string apiName = _req.Url.AbsolutePath.Remove(0, staticPart.Length);

            WebAPI api;
            if (!apis.TryGetValue(apiName, out api))
            {
                Log.Out("Error in ApiHandler.HandleRequest(): No handler found for API \"" + apiName + "\"");
                _resp.StatusCode = (int)HttpStatusCode.NotFound;
                return;
            }

            if (!AuthorizeForCommand(apiName, _user, _permissionLevel))
            {
                _resp.StatusCode = (int)HttpStatusCode.Forbidden;
                if (_user != null)
                {
                    //Log.Out ("ApiHandler: user '{0}' not allowed to execute '{1}'", user.SteamID, apiName);
                }

                return;
            }

            try
            {
#if ENABLE_PROFILER
				apiHandlerSampler.Begin ();
#endif
                api.HandleRequest(_req, _resp, _user, _permissionLevel);
#if ENABLE_PROFILER
				apiHandlerSampler.End ();
#endif
            }
            catch (Exception e)
            {
                Log.Error("Error in ApiHandler.HandleRequest(): Handler {0} threw an exception:", api.Name);
                Log.Exception(e);
                _resp.StatusCode = (int)HttpStatusCode.InternalServerError;
            }
        }

        private bool AuthorizeForCommand(string _apiName, WebConnection _user, int _permissionLevel)
        {
            return WebPermissions.Instance.ModuleAllowedWithLevel("webapi." + _apiName, _permissionLevel);
        }
    }
}