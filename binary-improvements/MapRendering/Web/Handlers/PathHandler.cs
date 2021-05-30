using System.Net;

namespace AllocsFixes.NetConnections.Servers.Web.Handlers
{
    public abstract class PathHandler
    {
        private readonly string moduleName;

        protected PathHandler(string _moduleName, int _defaultPermissionLevel = 0)
        {
            moduleName = _moduleName;
            WebPermissions.Instance.AddKnownModule(_moduleName, _defaultPermissionLevel);
        }

        public string ModuleName
        {
            get { return moduleName; }
        }

        public abstract void HandleRequest(WebSocketSharp.Net.HttpListenerRequest _req, WebSocketSharp.Net.HttpListenerResponse _resp, WebConnection _user,
            int _permissionLevel);

        public bool IsAuthorizedForHandler(WebConnection _user, int _permissionLevel)
        {
            if (moduleName != null)
            {
                return WebPermissions.Instance.ModuleAllowedWithLevel(moduleName, _permissionLevel);
            }

            return true;
        }
    }
}