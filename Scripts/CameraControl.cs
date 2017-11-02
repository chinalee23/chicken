using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraControl : MonoBehaviour {
    public GameObject Focus;

    Vector3 offset;

	// Use this for initialization
	void Start () {
        offset = Focus.transform.position - transform.position;
	}
	
	// Update is called once per frame
	void Update () {
        transform.position = Focus.transform.position - offset;
	}
}
