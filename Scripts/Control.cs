using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Control : MonoBehaviour {
    public GameObject CubeCamera;
    public float speed = 0.2f;

    Vector3 cameraOffset;
    int command = 0;

    void updateInput() {
        if (Input.GetKey(KeyCode.W)) {
            command += 1000;
        }
        if (Input.GetKey(KeyCode.S)) {
            command += 100;
        }
        if (Input.GetKey(KeyCode.A)) {
            command += 10;
        }
        if (Input.GetKey(KeyCode.D)) {
            command += 1;
        }
    }

	// Use this for initialization
	void Start () {
        cameraOffset = transform.position - CubeCamera.transform.position;
    }
	
	// Update is called once per frame
	void Update () {
        updateInput();

        Vector3 offset = Vector3.zero;
        bool up = command >= 1000;
        bool down = (command % 1000) >= 100;
        bool left = (command % 100) >= 10;
        bool right = (command % 10) == 1;
        if (up && !down) {
            offset.z = 1;
        }
        if (down && !up) {
            offset.z = -1;
        }
        if (left && !right) {
            offset.x = -1;
        }
        if (right && !left) {
            offset.x = 1;
        }

        transform.position = transform.position + offset * speed;
        CubeCamera.transform.position = transform.position - cameraOffset;

        command = 0;
	}
}
