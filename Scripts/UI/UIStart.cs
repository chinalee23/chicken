using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class UIStart : MonoBehaviour {

	// Use this for initialization
	void Start () {
        Button btn = GetComponentInChildren<Button>();
        btn.onClick.AddListener(onStart);
	}
	
	// Update is called once per frame
	void Update () {
		
	}

    void onStart() {
        
    }
}
