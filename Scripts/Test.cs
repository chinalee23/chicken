using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Test : MonoBehaviour {

    public GameObject Cam;
    public float moveSpeed;
    public float rotateSpeed;

    Vector3 camOffset;
    bool moving;
    Animation anim;

    void updateCamera() {
        Cam.transform.localPosition = transform.localPosition + camOffset;
    }

    void updateMove() {
        Vector3 angle = Vector3.zero;
        Vector3 direct = Vector3.zero;
        if (Input.GetKey(KeyCode.W)) {
            angle = new Vector3(0, 0, 0);
            direct = Vector3.forward;
        } else if (Input.GetKey(KeyCode.S)) {
            angle = new Vector3(0, 180, 0);
            direct = Vector3.back;
        } else if (Input.GetKey(KeyCode.A)) {
            angle = new Vector3(0, -90, 0);
            direct = Vector3.left;
        } else if (Input.GetKey(KeyCode.D)) {
            angle = new Vector3(0, 90, 0);
            direct = Vector3.right;
        } else {
            if (moving) {
                GetComponent<Animation>().Play("idle0");
                moving = false;
            }
            return;
        }
        if (!moving) {
            moving = true;
            anim.Play("run");
        }
        transform.localPosition += moveSpeed * direct;
        transform.rotation = Quaternion.Slerp(transform.rotation, Quaternion.Euler(angle), rotateSpeed * Time.deltaTime);
    }

    void Start() {
        camOffset = Cam.transform.localPosition - transform.localPosition;
        moving= false;
        anim = GetComponent<Animation>();
        anim.Play("idle0");
    }

    void Update() {
        updateMove();
        updateCamera();
    }
}
