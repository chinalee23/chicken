using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class UIDamageText : MonoBehaviour {
    public float interval = 5;
    public Text text;

    IEnumerator show(int d) {
        text.text = d.ToString();
        float start = Time.time;
        while ((Time.time - start) < interval) {
            yield return new WaitForEndOfFrame();
        }
        GameObject.Destroy(gameObject);
    }

    public void SetDamage(int d, Vector3 pos) {
        transform.position = pos;
        gameObject.SetActive(true);
        StartCoroutine(show(d));
    }
}
