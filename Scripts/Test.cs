using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Test : MonoBehaviour {
    class Retinue {
        public Vector3 offset;
        public Transform trans;
        public Retinue(Vector3 v, Transform t) {
            offset = v;
            trans = t;
        }

        public void UpdatePos(Vector3 pos) {
            trans.localPosition = pos + offset;
        }
    }

    class Major {
        public Transform trans;
        public List<Vector3> availables;
        public Major(Transform t) {
            trans = t;
        }
    }

    public float speed = 1f;
    public float scope = 40f;

    private float sqrt;
    private float gap = 25f;
    Major major;
    Transform rootNpc;
    Transform rootSub;
    List<Transform> npcs = new List<Transform>();
    List<Retinue> retinues = new List<Retinue>();

    void addRetinue(Transform t) {
        
    }

    void updateMajor() {
        Vector3 offset = Vector3.zero;
        if (Input.GetKey(KeyCode.W)) {
            offset.y += 1;
        }
        if (Input.GetKey(KeyCode.S)) {
            offset.y -= 1;
        }
        if (Input.GetKey(KeyCode.A)) {
            offset.x -= 1;
        }
        if (Input.GetKey(KeyCode.D)) {
            offset.x += 1;
        }
        if (offset.x * offset.y != 0) {
            offset.x = offset.x * sqrt;
            offset.y = offset.y * sqrt;

        }

        Vector3 newPos = major.trans.localPosition + offset * speed;
        newPos.x = Mathf.Min(1136 / 2 - 10, newPos.x);
        newPos.x = Mathf.Max(-1136 / 2 + 10, newPos.x);
        newPos.y = Mathf.Min(640 / 2 - 10, newPos.y);
        newPos.y = Mathf.Max(-640 / 2 + 10, newPos.y);
        major.trans.localPosition = newPos;
    }

    void updateRetinue() {
        for (int i = 0; i < retinues.Count; ++i) {
            retinues[i].UpdatePos(major.trans.localPosition);
        }
    }

    void updateNpc() {
        for (int i = 0; i < npcs.Count; ++i) {
            Transform npc = npcs[i];
            Vector3 offset = npc.localPosition - major.trans.localPosition;
            float distance = offset.magnitude;
            if (distance > scope) {
                continue;
            }

            npcs.RemoveAt(i);
            npc.name = "retinue";
            npc.parent = rootSub;

            addRetinue(npc);
            
            retinues.Add(new Retinue(offset, npc));

            i--;
        }
    }
	
	void Start () {
        sqrt = Mathf.Sqrt(0.5f);
        
        major = new Major(transform.Find("major"));
        rootNpc = transform.Find("npcs");
        rootSub = transform.Find("retinues");
        for (int i = 0; i < rootNpc.childCount; ++i) {
            Transform npc = rootNpc.GetChild(i);
            npcs.Add(npc);
        }
	}
		
	void Update () {
        updateMajor();
        updateRetinue();
        updateNpc();
    }
}
