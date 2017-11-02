/*
 * Tencent is pleased to support the open source community by making xLua available.
 * Copyright (C) 2016 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
*/

using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using XLua;
using System;

[System.Serializable]
public class Injection {
    public string name;
    public GameObject value;
}

[LuaCallCSharp]
public class LuaBehaviour : MonoBehaviour {
    public string luaScript;
    public Injection[] injections;

    internal static LuaEnv luaEnv = null;   //all lua behaviour shared one luaenv only!
    internal static float lastGCTime = 0;
    internal const float GCInterval = 1;    //1 second

    private LuaTable ltScript;

    private LuaFunction lfAwake;
    private LuaFunction lfStart;
    private LuaFunction lfUpdate;
    private LuaFunction lfOndestroy;
    private LuaFunction lfFixedupdate;

    void Awake() {
        if (Game.Instance() == null) {
            LuaManager.Instance().Init();
        }
        luaEnv = LuaManager.Instance().GetEnv();

        object[] rst = LuaManager.Instance().DoLua(luaScript);
        if (rst == null) {
            return;
        }
        ltScript = rst[0] as LuaTable;
        ltScript.Set("self", this);

        ltScript.Get("awake", out lfAwake);
        if (lfAwake!= null) {
            lfAwake.Call(gameObject);
        }

        ltScript.Get("start", out lfStart);
        ltScript.Get("update", out lfUpdate);
        ltScript.Get("ondestroy", out lfOndestroy);
        ltScript.Get("fixedupdate", out lfFixedupdate);
    }

    // Use this for initialization
    void Start() {
        if (lfStart != null) {
            lfStart.Call();
        }
    }

    // Update is called once per frame
    void Update() {
        if (lfUpdate != null) {
            lfUpdate.Call();
        }
        if (Time.time - LuaBehaviour.lastGCTime > GCInterval) {
            luaEnv.Tick();
            LuaBehaviour.lastGCTime = Time.time;
        }
    }

    void FixedUpdate() {
        if (lfFixedupdate != null) {
            lfFixedupdate.Call();
        }
    }

    void OnDestroy() {
        if (lfOndestroy != null) {
            lfOndestroy.Call();
        }
        lfOndestroy = null;
        lfUpdate = null;
        lfStart = null;
        ltScript.Dispose();
        injections = null;
    }
}
