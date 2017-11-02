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

    public void AddEvent(EventTriggerType type, UnityAction<BaseEventData> cb) {
        EventTrigger trigger = gameObject.GetComponent<EventTrigger>();
        if (trigger == null) {
            trigger = gameObject.AddComponent<EventTrigger>();
        }

        Entry entry = new Entry();
        entry.eventID = type;
        entry.callback.AddListener(cb);
        trigger.triggers.Add(entry);
    }
}
