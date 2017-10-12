﻿using System.Collections;
using UnityEngine;
using UnityEngine.SceneManagement;
using XLua;

public class LuaInterface {
    public static void Connect() {

    }

    public static void LoadScene(string name, System.Action cb) {
        Game.Instance().StartCoroutine(loadScene(name, cb));
    }

    private static IEnumerator loadScene(string name, System.Action cb) {
        AsyncOperation ao = SceneManager.LoadSceneAsync(name);
        while (!ao.isDone) {
            yield return new WaitForSeconds(0.5f);
        }
        if (cb != null) {
            cb();
        }
    }

    public static GameObject LoadPrefab(string path, GameObject parent = null) {
        Object o = Resources.Load(path);
        if (o == null) {
            return null;
        }
        GameObject go = MonoBehaviour.Instantiate(o) as GameObject;
        if (parent != null) {
            go.transform.parent = parent.transform;
            go.transform.localPosition = Vector3.zero;
            go.transform.localScale = Vector3.one;
        }
        return go;
    }

    public static void SetLocalPosition(GameObject go, float x, float y, float z) {
        go.transform.localPosition = new Vector3(x, y, z);
    }
}
