using UnityEngine;
using UnityEngine.SceneManagement;

public class Game : MonoBehaviour {
    private static Game instance;
    public static Game Instance() {
        return instance;
    }

    public Camera UICamera;

    void Awake() {
        Debug.Log("Gamestart...");

        instance = this;
        DontDestroyOnLoad(this);

        Application.runInBackground = true;

        LuaManager.Instance().Init();
        NetSystem.Instance().Init();

        GameObject goCamera = LuaInterface.LoadPrefab("Prefab/UICamera");
        UICamera = goCamera.GetComponent<Camera>();
        DontDestroyOnLoad(goCamera);

        LuaInterface.LoadPrefab("Prefab/UIStart");
    }

	// Use this for initialization
	void Start () {
        
	}
	
	// Update is called once per frame
	void Update () {
        NetSystem.Instance().Update();
        LuaManager.Instance().Update();
	}

    void FixedUpdate() {
        LuaManager.Instance().FixedUpdate();
    }

    void OnApplicationQuit() {
        Debug.Log("quit game");
        NetSystem.Instance().Dispose();
    }
}
