using System.Collections;
using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.UI;
using XLua;

public class LuaInterface {
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

    public static void SetLocalScale(GameObject go, float x, float y, float z) {
        go.transform.localScale = new Vector3(x, y, z);
    }

    public static void DestroyGameObject(GameObject go) {
        MonoBehaviour.Destroy(go);
    }

    public static void AddClick(GameObject go, LuaFunction cb) {
        Button btn = go.GetComponent<Button>();
        btn.onClick.AddListener(delegate () {
            cb.Call(go);
        });
    }

    public static GameObject Find(GameObject root, string path) {
        Transform trans = root.transform.Find(path);
        if (trans == null) {
            return null;
        } else {
            return trans.gameObject;
        }
    }

    #region net
    public static void Connect(string ip, int port, LuaFunction cb) {
        NetSystem.Instance().Connect(ip, port, delegate (bool status) {
            cb.Call(status);
        });
    }

    public static void Send(string msg) {
        byte[] data = System.Text.Encoding.UTF8.GetBytes(msg);
        NetSystem.Instance().Send(data);
    }
    #endregion
}
