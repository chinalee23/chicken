using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class UIStart : MonoBehaviour {
    public Text textLog;
    public Button btnTest;

    void onConnect(bool status) {
        if (status) {
            textLog.text += "connect success\n";
        } else {
            textLog.text += "connect fail\n";
        }
    }

    void onBtnTest() {
        textLog.text += "click test\n";
    }
	
	void Start () {
        btnTest.onClick.AddListener(onBtnTest);
	}
		
	void Update () {
		
	}

    void onStart() {
        
    }
}
