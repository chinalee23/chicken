using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class UIStart : MonoBehaviour {
    public Toggle UseRVO;
	
	void Start () {
        UseRVO.onValueChanged.AddListener(delegate (bool status) {
            Config.USE_RVO = status;
        });
	}
}
