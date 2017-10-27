using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using XLua;
using System.IO;

public class LuaManager : Singleton<LuaManager> {
    public LuaEnv luaEnv;
    
    private LuaFunction lfUpdate;
    private LuaFunction lfFixedUpdate;
    private LuaFunction lfProcessMsg;

    byte[] load(ref string filepath) {
        filepath = filepath.Replace('.', '/');
#if UNITY_EDITOR
        string realPath = Path.Combine(Application.dataPath, "LuaScripts/" + filepath + ".lua");
        if (File.Exists(realPath)) {
            return File.ReadAllBytes(realPath);
        } else {
            return null;
        }
#else
        TextAsset asset = Resources.Load("LuaScripts/" + filepath) as TextAsset;
        if (asset == null) {
            return null;
        } else {
            return asset.bytes;
        }
#endif
    }

    public void Init() {
        luaEnv = new LuaEnv();
        luaEnv.AddLoader(load);

        DoLua("init");

        object[] rst = DoLua("bootstrap");
        if (rst == null || rst.Length == 0) {
            return;
        }
        LuaTable lt = rst[0] as LuaTable;
                
        lt.Get("update", out lfUpdate);
        lt.Get("fixedUpdate", out lfFixedUpdate);
        lt.Get("processMsg", out lfProcessMsg);
    }

    public object[] DoLua(string name, string chunk = "chunk", LuaTable env = null) {
        byte[] bt = load(ref name);
        if (bt == null) {
            return null;
        }

        return luaEnv.DoString(bt, chunk, env);
    }

    public LuaEnv GetEnv() {
        return luaEnv;
    }

    public void Update() {
        if (lfUpdate != null) {
            lfUpdate.Call();
        }
    }

    public void FixedUpdate() {
        if (lfFixedUpdate != null) {
            lfFixedUpdate.Call();
        }
    }

    public void Dispose() {
        if (lfUpdate != null) {
            lfUpdate.Dispose();
        }
        if (lfFixedUpdate != null) {
            lfFixedUpdate.Dispose();
        }
        if (luaEnv!= null) {
            luaEnv.Dispose();
        }
    }

    public void ProcessMsg(int msgType, byte[] msg) {
        if (lfProcessMsg == null) {
            return;
        }
        string jd = System.Text.Encoding.UTF8.GetString(msg);
        lfProcessMsg.Call(jd);
    }
}
