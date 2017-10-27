using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.EventSystems;

public class Rocker : MonoBehaviour {
    public float maxOffset;
    
    public Vector3 direction {
        get;
        private set;
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
        direction = Vector3.zero;
        image.transform.localPosition = Vector3.zero;
        btn.gameObject.SetActive(false);
    }

    void onDrag(BaseEventData data) {
        PointerEventData pd = (PointerEventData)data;

        Vector2 pos = pd.position;
        Vector3 offset = pd.position - dragStartPos;
        if (offset.magnitude > maxOffset) {
            direction = offset.normalized;
            offset = maxOffset * direction;
        } else {
            direction = Vector3.zero;
        }

        image.transform.localPosition = offset;
    }

    void Start() {
        UIEventListener.Get(gameObject).AddEvent(EventTriggerType.PointerUp, onPointerUp);
        UIEventListener.Get(gameObject).AddEvent(EventTriggerType.Drag, onDrag);
        UIEventListener.Get(gameObject).AddEvent(EventTriggerType.PointerDown, onPointerDown);

        btn = transform.Find("Button");
        image = btn.transform.Find("Image");
        
        btn.gameObject.SetActive(false);
    }
}
