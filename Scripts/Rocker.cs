using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.EventSystems;
using XLua;

[LuaCallCSharp]
public class Rocker : MonoBehaviour {
    public float maxOffset;

    public Vector2 direction {
        get;
        private set;
    }

    public bool inorigin {
        get {
            return direction == Vector2.zero;
        }
    }

    Transform btn;
    Transform image;
    Vector2 dragStartPos;

    void onPointerDown(BaseEventData data) {
        btn.gameObject.SetActive(true);
        PointerEventData pd = (PointerEventData)data;
        float ratio = (float)Screen.height / 640f;
        RectTransform rt = GetComponent<RectTransform>();
        btn.localPosition = new Vector3(pd.position.x - 1136f*rt.anchorMax.x/2*ratio, pd.position.y - 640f*rt.anchorMax.y/2*ratio, 0);

        dragStartPos = pd.position;
    }

    void onPointerUp(BaseEventData data) {
        direction = Vector2.zero;
        image.transform.localPosition = Vector2.zero;
        btn.gameObject.SetActive(false);
    }

    void onDrag(BaseEventData data) {
        PointerEventData pd = (PointerEventData)data;

        Vector2 pos = pd.position;
        Vector2 offset = pd.position - dragStartPos;
        if (offset.magnitude > maxOffset) {
            direction = offset.normalized;
            offset = maxOffset * direction;
        } else {
            direction = Vector2.zero;
        }

        image.transform.localPosition = offset;
    }

    public static float frameTime = 0f;
    void Start() {
        UIEventListener.Get(gameObject).AddEvent(EventTriggerType.PointerUp, onPointerUp);
        UIEventListener.Get(gameObject).AddEvent(EventTriggerType.Drag, onDrag);
        UIEventListener.Get(gameObject).AddEvent(EventTriggerType.PointerDown, onPointerDown);

        btn = transform.Find("Button");
        image = btn.transform.Find("Image");
        
        btn.gameObject.SetActive(false);

        direction = Vector2.zero;
    }
}
