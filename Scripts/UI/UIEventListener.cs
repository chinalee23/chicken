using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.Events;

public class UIEventListener : UnityEngine.EventSystems.EventTrigger {
    public delegate void VoidDelegate(GameObject go);

    public VoidDelegate onClick;
    public VoidDelegate onDown;

    public static UIEventListener Get(GameObject go) {
        UIEventListener listener = go.GetComponent<UIEventListener>();
        if (listener == null) {
            listener = go.AddComponent<UIEventListener>();
        }
        return listener;
    }

    public override void OnPointerClick(PointerEventData eventData) {
        if (onClick != null) {
            onClick(gameObject);
        }
    }

    public override void OnPointerDown(PointerEventData eventData) {
        if (onDown != null) {
            onDown(gameObject);
        }
    }

    private void callback(BaseEventData data) {
        Debug.Log(data);
    }

    public void AddEvent(GameObject go, EventTriggerType type) {
        EventTrigger trigger = go.GetComponent<EventTrigger>();
        if (trigger == null) {
            trigger = go.AddComponent<EventTrigger>();
        }

        Entry entry = new Entry();
        entry.eventID = type;
        entry.callback.AddListener(callback);
        trigger.triggers.Add(entry);
    }
}
