using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Test : MonoBehaviour {

    IEnumerator test() {
        while (true) {
            float time = Time.time;
            GetComponent<Animation>().Play("skill1");
            while ((Time.time - time) < 3) {
                yield return new WaitForEndOfFrame();
            }
        }
    }

    void Start() {
        StartCoroutine(test());
    }
}
