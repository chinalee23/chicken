using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using RVO;

public class RVONew : MonoBehaviour {
    public Transform RootObstacle;
    public Transform general;
    public GameObject GoRocker;
    public Transform RootNpc;

    public Vector3 Goal;
    public float Speed;

    public float timeStep = 0.25f;
    public float neighborDist = 15f;
    public int maxNeighbors = 10;
    public float timeHorizon = 10f;
    public float timeHorizonObst = 10f;
    public float radius = 1.5f;
    public float maxSpeed = 2f;

    Rocker rocker;
    List<Transform> npcs;
    Dictionary<Transform, int> agents;
    Dictionary<Transform, int> layers;
    int generalAgentIndex;
    bool isObstacle;
    int generalObstacleIndex;
    float retinueGap = 50f;
    float recruitGap = 100f;

    void init() {
        agents = new Dictionary<Transform, int>();
        layers = new Dictionary<Transform, int>();

        generalAgentIndex = -1;
        generalObstacleIndex = -1;

        Simulator.Instance.Clear();
    }

    void initGeneral() {
        addGeneralObstacle();
        isObstacle = true;
    }

    void initNpc() {
        npcs = new List<Transform>();
        if (RootNpc == null) {
            return;
        }
        for (int i = 0; i < RootNpc.childCount; i++) {
            Transform npc = RootNpc.GetChild(i);
            npcs.Add(npc);
        }
    }

    void addGeneralObstacle() {
        IList<RVO.Vector2> obstacle = new List<RVO.Vector2>();

        Vector3 pos = general.localPosition;
        obstacle.Add(new RVO.Vector2(pos.x - 20, pos.y + 20));
        obstacle.Add(new RVO.Vector2(pos.x - 20, pos.y - 20));
        obstacle.Add(new RVO.Vector2(pos.x + 20, pos.y - 20));
        obstacle.Add(new RVO.Vector2(pos.x + 20, pos.y + 20));

        generalObstacleIndex = Simulator.Instance.addObstacle(obstacle);
    }

    void addSolidObstacle() {
        if (RootObstacle != null) {
            for (int i = 0; i < RootObstacle.childCount; i++) {
                Transform trans = RootObstacle.GetChild(i);
                RectTransform rt = trans.GetComponent<RectTransform>();
                IList<RVO.Vector2> obstacle = new List<RVO.Vector2>();
                Vector3 pos = trans.localPosition;
                obstacle.Add(new RVO.Vector2(pos.x - rt.sizeDelta.x / 2, pos.y + rt.sizeDelta.y / 2));
                obstacle.Add(new RVO.Vector2(pos.x - rt.sizeDelta.x / 2, pos.y - rt.sizeDelta.y / 2));
                obstacle.Add(new RVO.Vector2(pos.x + rt.sizeDelta.x / 2, pos.y - rt.sizeDelta.y / 2));
                obstacle.Add(new RVO.Vector2(pos.x + rt.sizeDelta.x / 2, pos.y + rt.sizeDelta.y / 2));
                Simulator.Instance.addObstacle(obstacle);
            }
        }
    }

    void setScenario() {
        Simulator.Instance.setTimeStep(timeStep);
        Simulator.Instance.setAgentDefaults(neighborDist, maxNeighbors, timeHorizon, timeHorizonObst, radius, maxSpeed, new RVO.Vector2(2f, 2f));

        addGeneralObstacle();
        addSolidObstacle();
        Simulator.Instance.processObstacles();
    }

    void removeGeneralAgent() {
        Simulator.Instance.removeAgent(generalAgentIndex);
        agents.Remove(general);
        List<Transform> l = new List<Transform>();
        foreach (var kvp in agents) {
            if (kvp.Value > generalAgentIndex) {
                l.Add(kvp.Key);
            }
        }
        for (int i = 0; i < l.Count; i++) {
            agents[l[i]] = agents[l[i]] - 1;
        }

        generalAgentIndex = -1;
    }

    void removeGeneralObstacle() {
        for (int i = 0; i < 4; i++) {
            Simulator.Instance.removeObstacle(generalObstacleIndex);
        }
        generalObstacleIndex = -1;
    }

    void setMajorVelocity() {
        if (rocker.direction == Vector3.zero) {
            if (!isObstacle) {
                isObstacle = true;
                removeGeneralAgent();
                addGeneralObstacle();
                Simulator.Instance.processObstacles();
            }
        } else {
            if (isObstacle) {
                isObstacle = false;
                removeGeneralObstacle();
                Simulator.Instance.processObstacles();
                Vector3 pos = general.localPosition;
                generalAgentIndex = Simulator.Instance.addAgent(new RVO.Vector2(pos.x, pos.y));
                agents[general] = generalAgentIndex;
            }
            RVO.Vector2 velocity = new RVO.Vector2(rocker.direction.x, rocker.direction.y);
            Simulator.Instance.setAgentPrefVelocity(generalAgentIndex, Speed * velocity);
        }
    }

    void setRetinueVelocity_() {
        foreach (var kvp in agents) {
            if (kvp.Value == generalAgentIndex) {
                continue;
            }
            Vector3 velocity = rocker.direction;
            if (rocker.direction == Vector3.zero) {
                Vector3 offset = general.localPosition - kvp.Key.localPosition;
                if (offset.magnitude > layers[kvp.Key] * retinueGap) {
                    velocity = offset.normalized;
                }
            }
            Simulator.Instance.setAgentPrefVelocity(kvp.Value, Speed * new RVO.Vector2(velocity.x, velocity.y));
        }
    }

    void setRetinueVelocity() {
        foreach (var kvp in agents) {
            if (kvp.Value == generalAgentIndex) {
                continue;
            }
            Vector3 velocity = rocker.direction;
            Vector3 offset = general.localPosition - kvp.Key.localPosition;
            if (offset.magnitude > layers[kvp.Key] * retinueGap) {
                velocity = offset.normalized;
            }
            Simulator.Instance.setAgentPrefVelocity(kvp.Value, Speed * new RVO.Vector2(velocity.x, velocity.y));
        }
    }
    
    void setPreferVelocity() {
        setMajorVelocity();
        setRetinueVelocity();
    }

    void setPosition() {
        foreach (var kvp in agents) {
            RVO.Vector2 v = Simulator.Instance.getAgentPosition(kvp.Value);
            kvp.Key.localPosition = new Vector3(v.x(), v.y(), 0);
        }
    }

    void updateAgent() {
        setPreferVelocity();
        Simulator.Instance.doStep();
        setPosition();
    }

    void updateNpc() {
        for (int i = 0; i < npcs.Count; i++) {
            foreach (var kvp in agents) {
                Vector3 offset = npcs[i].localPosition - kvp.Key.localPosition;
                if (offset.magnitude > recruitGap) {
                    continue;
                }
                Vector3 pos = npcs[i].localPosition;
                int index = Simulator.Instance.addAgent(new RVO.Vector2(pos.x, pos.y));
                agents[npcs[i]] = index;
                layers[npcs[i]] = (agents.Count - 2) / 7 + 1;
                npcs.RemoveAt(i);
                i--;
                break;
            }
        }
    }
	
	void Start () {
        init();
        initGeneral();
        initNpc();
        setScenario();
        
        rocker = GoRocker.GetComponent<Rocker>();
	}
	
	
	void Update () {
        updateAgent();
        updateNpc();
	}
}
