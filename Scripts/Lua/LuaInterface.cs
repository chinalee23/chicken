using System.Collections;
using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.UI;
using UnityEngine.EventSystems;
using UnityEngine.Events;
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

    public static void AddClick(GameObject gameObject, LuaFunction cb) {
        EventTrigger trigger = gameObject.GetComponent<EventTrigger>();
        if (trigger == null) {
            trigger = gameObject.AddComponent<EventTrigger>();
        }
        EventTrigger.Entry entry = new EventTrigger.Entry();
        entry.eventID = EventTriggerType.PointerClick;
        entry.callback.AddListener(delegate (BaseEventData data) {
            cb.Call(gameObject);
        });
        trigger.triggers.Add(entry);
    }

    public static void AddEvent(GameObject go, EventTriggerType type, LuaFunction cb) {
        EventTrigger trigger = go.GetComponent<EventTrigger>();
        if (trigger == null) {
            trigger = go.AddComponent<EventTrigger>();
        }
        EventTrigger.Entry entry = new EventTrigger.Entry();
        entry.eventID = type;
        entry.callback.AddListener(delegate (BaseEventData data) {
            cb.Call(go);
        });
        trigger.triggers.Add(entry);
    }

    public static object Find(GameObject root, string path, string component = null) {
        Transform trans = root.transform.Find(path);
        if (trans == null) {
            return null;
        } else {
            if (component == null) {
                return trans.gameObject;
            } else {
                object o = trans.GetComponent(component);
                return o;
            }
        }
    }

    #region net
    public static void Connect(string ip, int port, LuaFunction cb) {
        NetSystem.Instance().Connect(ip, port, cb);
    }

    public static void Send(int msgType, string msg) {
        byte[] data = System.Text.Encoding.UTF8.GetBytes(msg);
        NetSystem.Instance().Send(msgType, data);
    }
    #endregion

    public static void LuaError(string s) {
        Debug.LogError(s);
    }

    public static void SetText(Text text, string s) {
        text.text += s + "\n";
    }
}
