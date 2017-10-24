using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using RVO;
using System;
using UnityEngine.UI;

public class RVOTest : MonoBehaviour {
    public GameObject Prefab;
    public GameObject Obstacle;

    public float timeStep = 0.25f;
    public float neighborDist = 15f;
    public int maxNeighbors = 10;
    public float timeHorizon = 10f;
    public float timeHorizonObst = 10f;
    public float radius = 1.5f;
    public float maxSpeed = 2f;

    #region rvo
    IList<RVO.Vector2> goals = new List<RVO.Vector2>();
    System.Random random = new System.Random();

    void setupScenario_Circle() {
        Simulator.Instance.setTimeStep(timeStep);

        Simulator.Instance.setAgentDefaults(neighborDist, maxNeighbors, timeHorizon, timeHorizonObst, radius, maxSpeed, new RVO.Vector2(2f, 2f));

        int count = 8;
        for (int i = 0; i < count; i++) {
            Simulator.Instance.addAgent(100f * new RVO.Vector2((float)Math.Cos(i * 2.0f * Math.PI / (float)count), (float)Math.Sin(i * 2.0f * Math.PI / (float)count)));
            goals.Add(-Simulator.Instance.getAgentPosition(i));
        }
    }

    void setupScenario_Block_() {
        Simulator.Instance.setTimeStep(timeStep);

        Simulator.Instance.setAgentDefaults(neighborDist, maxNeighbors, timeHorizon, timeHorizonObst, radius, maxSpeed, new RVO.Vector2(2f, 2f));

        for (int i = 0; i < 5; ++i) {
            for (int j = 0; j < 5; ++j) {
                RVO.Vector2 v1 = new RVO.Vector2(55f + i * 10f, 55f + j * 10f);
                Simulator.Instance.addAgent(v1);
                goals.Add(new RVO.Vector2(-v1.x(), -v1.y()));

                RVO.Vector2 v2 = new RVO.Vector2(-55f - i * 10f, 55f + j * 10f);
                Simulator.Instance.addAgent(v2);
                goals.Add(new RVO.Vector2(-v2.x(), -v2.y()));

                RVO.Vector2 v3 = new RVO.Vector2(55f + i * 10f, -55f - j * 10f);
                Simulator.Instance.addAgent(v3);
                goals.Add(new RVO.Vector2(-v3.x(), -v3.y()));

                RVO.Vector2 v4 = new RVO.Vector2(-55f - i * 10f, -55f - j * 10f);
                Simulator.Instance.addAgent(v4);
                goals.Add(new RVO.Vector2(-v4.x(), -v4.y()));
            }
        }

        addObstacles_();
    }

    void addObstacles_() {
        /*
         * Add (polygonal) obstacles, specifying their vertices in
         * counterclockwise order.
         */
        IList<RVO.Vector2> obstacle1 = new List<RVO.Vector2>();
        obstacle1.Add(new RVO.Vector2(-10f, 40f));
        obstacle1.Add(new RVO.Vector2(-40f, 40f));
        obstacle1.Add(new RVO.Vector2(-40f, 10f));
        obstacle1.Add(new RVO.Vector2(-10f, 10f));
        Simulator.Instance.addObstacle(obstacle1);

        IList<RVO.Vector2> obstacle2 = new List<RVO.Vector2>();
        obstacle2.Add(new RVO.Vector2(10f, 40f));
        obstacle2.Add(new RVO.Vector2(10f, 10f));
        obstacle2.Add(new RVO.Vector2(40f, 10f));
        obstacle2.Add(new RVO.Vector2(40f, 40f));
        Simulator.Instance.addObstacle(obstacle2);

        IList<RVO.Vector2> obstacle3 = new List<RVO.Vector2>();
        obstacle3.Add(new RVO.Vector2(10f, -40f));
        obstacle3.Add(new RVO.Vector2(40f, -40f));
        obstacle3.Add(new RVO.Vector2(40f, -10f));
        obstacle3.Add(new RVO.Vector2(10f, -10f));
        Simulator.Instance.addObstacle(obstacle3);

        IList<RVO.Vector2> obstacle4 = new List<RVO.Vector2>();
        obstacle4.Add(new RVO.Vector2(-10f, -40f));
        obstacle4.Add(new RVO.Vector2(-10f, -10f));
        obstacle4.Add(new RVO.Vector2(-40f, -10f));
        obstacle4.Add(new RVO.Vector2(-40f, -40f));
        Simulator.Instance.addObstacle(obstacle4);

        /*
         * Process the obstacles so that they are accounted for in the
         * simulation.
         */
        Simulator.Instance.processObstacles();
    }

    void setupScenario_Block() {
        Simulator.Instance.setTimeStep(timeStep);

        Simulator.Instance.setAgentDefaults(neighborDist, maxNeighbors, timeHorizon, timeHorizonObst, radius, maxSpeed, new RVO.Vector2(2f, 2f));

        for (int i = 0; i < 5; ++i) {
            for (int j = 0; j < 5; ++j) {
                RVO.Vector2 v1 = new RVO.Vector2(150f + i * 25f, 150f + j * 25f);
                Simulator.Instance.addAgent(v1);
                goals.Add(new RVO.Vector2(-v1.x(), -v1.y()));

                RVO.Vector2 v2 = new RVO.Vector2(-150f - i * 25f, 150f + j * 25f);
                Simulator.Instance.addAgent(v2);
                goals.Add(new RVO.Vector2(-v2.x(), -v2.y()));

                RVO.Vector2 v3 = new RVO.Vector2(150f + i * 25f, -150f - j * 25f);
                Simulator.Instance.addAgent(v3);
                goals.Add(new RVO.Vector2(-v3.x(), -v3.y()));

                RVO.Vector2 v4 = new RVO.Vector2(-150f - i * 25f, -150f - j * 25f);
                Simulator.Instance.addAgent(v4);
                goals.Add(new RVO.Vector2(-v4.x(), -v4.y()));
            }
        }

        //addObstacle();
    }

    void addObstacle() {
        /*
         * Add (polygonal) obstacles, specifying their vertices in
         * counterclockwise order.
         */
        IList<RVO.Vector2> obstacle1 = new List<RVO.Vector2>();
        obstacle1.Add(new RVO.Vector2(-130f, 130f));
        obstacle1.Add(new RVO.Vector2(-130f, 70f));
        obstacle1.Add(new RVO.Vector2(-70f, 70f));
        obstacle1.Add(new RVO.Vector2(-70f, 130f));
        Simulator.Instance.addObstacle(obstacle1);

        IList<RVO.Vector2> obstacle2 = new List<RVO.Vector2>();
        obstacle2.Add(new RVO.Vector2(70f, 130f));
        obstacle2.Add(new RVO.Vector2(70f, 70f));
        obstacle2.Add(new RVO.Vector2(130f, 70f));
        obstacle2.Add(new RVO.Vector2(130f, 130f));
        Simulator.Instance.addObstacle(obstacle2);

        IList<RVO.Vector2> obstacle3 = new List<RVO.Vector2>();
        obstacle3.Add(new RVO.Vector2(70f, -70f));
        obstacle3.Add(new RVO.Vector2(70f, -130f));
        obstacle3.Add(new RVO.Vector2(130f, -130f));
        obstacle3.Add(new RVO.Vector2(130f, -70f));
        Simulator.Instance.addObstacle(obstacle3);

        IList<RVO.Vector2> obstacle4 = new List<RVO.Vector2>();
        obstacle4.Add(new RVO.Vector2(-130f, -70f));
        obstacle4.Add(new RVO.Vector2(-130f, -130f));
        obstacle4.Add(new RVO.Vector2(-70f, -130f));
        obstacle4.Add(new RVO.Vector2(-70f, -70f));
        Simulator.Instance.addObstacle(obstacle4);

        /*
         * Process the obstacles so that they are accounted for in the
         * simulation.
         */
        Simulator.Instance.processObstacles();
    }

    void addObstacle_xx() {
        IList<RVO.Vector2> obstacle3 = new List<RVO.Vector2>();
        obstacle3.Add(new RVO.Vector2(-30f, 30f));
        obstacle3.Add(new RVO.Vector2(-30f, -30f));
        obstacle3.Add(new RVO.Vector2(30f, -30f));
        obstacle3.Add(new RVO.Vector2(30f, 30f));
        Simulator.Instance.addObstacle(obstacle3);

        Simulator.Instance.processObstacles();
    }

    void setupScenario_Fight() {
        Simulator.Instance.setTimeStep(timeStep);
        Simulator.Instance.setAgentDefaults(neighborDist, maxNeighbors, timeHorizon, timeHorizonObst, radius, maxSpeed, new RVO.Vector2(2f, 2f));

        for (int i = 0; i < 3; i++) {
            for (int j = 0; j < 3; j++) {
                RVO.Vector2 v = new RVO.Vector2(-200f + j * 60f, 200f - i * 60f);
                Simulator.Instance.addAgent(v);
                //goals.Add(new RVO.Vector2(200f, -200f));
                goals.Add(-v);
            }
        }

        addObstacle_xx();
    }
    
    void setPreferredVelocities() {
        /*
         * Set the preferred velocity to be a vector of unit magnitude
         * (speed) in the direction of the goal.
         */
        for (int i = 0; i < Simulator.Instance.getNumAgents(); ++i) {
            RVO.Vector2 goalVector = goals[i] - Simulator.Instance.getAgentPosition(i);

            if (RVOMath.absSq(goalVector) > 1.0f) {
                goalVector = RVOMath.normalize(goalVector);
            }

            Simulator.Instance.setAgentPrefVelocity(i, 3 * goalVector);

            /* Perturb a little to avoid deadlocks due to perfect symmetry. */
            float angle = (float)random.NextDouble() * 2.0f * (float)Math.PI;
            float dist = (float)random.NextDouble() * 0.0001f;

            Simulator.Instance.setAgentPrefVelocity(i, Simulator.Instance.getAgentPrefVelocity(i) +
                dist * new RVO.Vector2((float)Math.Cos(angle), (float)Math.Sin(angle)));
        }
    }

    bool reachedGoal() {
        /* Check if all agents have reached their goals. */
        for (int i = 0; i < Simulator.Instance.getNumAgents(); ++i) {
            if (RVOMath.absSq(Simulator.Instance.getAgentPosition(i) - goals[i]) > 0.1f) {
                return false;
            }
        }

        return true;
    }

    void _updateVisualization() {
        string str = "";
        /* Output the current global time. */
        str += Simulator.Instance.getGlobalTime();

        /* Output the current position of all the agents. */
        for (int i = 0; i < Simulator.Instance.getNumAgents(); ++i) {
            str += string.Format(" {0}", Simulator.Instance.getAgentPosition(i));
        }

        str += "\n";
        Debug.Log(str);
    }

    void updateVisualization(bool flag) {
        for (int i = 0; i < Simulator.Instance.getNumAgents(); ++i) {
            RVO.Vector2 p = Simulator.Instance.getAgentPosition(i);
            gos[i].transform.localPosition = new Vector3(p.x(), p.y(), 0);

            //if (flag) {
            //    Debug.Log(i + ", set go pos: " + p);
            //}

            RVO.Vector2 v = Simulator.Instance.getAgentVelocity(i);
            float angle;
            if (v.x() < 0) {
                angle = Vector3.Angle(Vector3.up, new Vector3(v.x(), v.y(), 0));
            } else {
                angle = -Vector3.Angle(Vector3.up, new Vector3(v.x(), v.y(), 0));
            }
            gos[i].transform.localEulerAngles = new Vector3(0, 0, angle);
        }
    }
    #endregion

    List<GameObject> gos = new List<GameObject>();
    void clone() {
        for (int i = 0; i < Simulator.Instance.getNumAgents(); i++) {
            GameObject go = MonoBehaviour.Instantiate<GameObject>(Prefab);

            //Image img = go.GetComponent<Image>();
            //if (i % 4 == 0) {
            //    img.color = Color.green;
            //} else if (i % 4 == 1) {
            //    img.color = Color.white;
            //} else if (i % 4 == 2) {
            //    img.color = Color.blue;
            //} else if (i % 4 == 3) {
            //    img.color = Color.gray;
            //}

            Text text = go.GetComponentInChildren<Text>();
            if (text != null) {
                text.text = i.ToString();
            }

            go.name = i.ToString();
            go.transform.parent = transform;
            RVO.Vector2 v = Simulator.Instance.getAgentPosition(i);
            go.transform.localPosition = new Vector3(v.x(), v.y(), 0);
            go.SetActive(true);
            gos.Add(go);
        }
    }

    IEnumerator move() {
        yield return new WaitForSeconds(1);
        float start = Time.realtimeSinceStartup;
        Debug.Log("start at " + start);
        do {
            //yield return new WaitForSeconds(timeStep);
            yield return new WaitForEndOfFrame();

            setPreferredVelocities();
            Simulator.Instance.doStep();

            if (Simulator.Instance.getNumAgents() > 1) {
                if ((Time.realtimeSinceStartup - start) > 1.5f) {
                    start = Time.realtimeSinceStartup;

                    updateVisualization(true);
                    
                    int index = Simulator.Instance.getNumAgents() - 1;
                    IList<RVO.Vector2> obstacle = new List<RVO.Vector2>();
                    RVO.Vector2 v = Simulator.Instance.getAgentPosition(index);
                    obstacle.Add(new RVO.Vector2(v.x() - 20, v.y() + 20));
                    obstacle.Add(new RVO.Vector2(v.x() - 20, v.y() - 20));
                    obstacle.Add(new RVO.Vector2(v.x() + 20, v.y() - 20));
                    obstacle.Add(new RVO.Vector2(v.x() + 20, v.y() + 20));
                    Simulator.Instance.addObstacle(obstacle);
                    Simulator.Instance.processObstacles();

                    Simulator.Instance.removeAgent(index);
                    gos.RemoveAt(index);
                    goals.RemoveAt(index);
                } else {
                    updateVisualization(false);
                }
            } else {
                updateVisualization(false);
            }
            //updateVisualization(false);

            //if ((Time.realtimeSinceStartup - start) > 1) {
            //    start = Time.realtimeSinceStartup;
            //    addObstacle_xx();
            //    Obstacle.SetActive(true);
            //}
        } while (!reachedGoal());
        Debug.Log("end at " + Time.realtimeSinceStartup);
    }

    void Start () {
        Application.runInBackground = true;

        //setupScenario_Circle();
        //setupScenario_Block();
        setupScenario_Fight();
        clone();
        StartCoroutine(move());
    }
	
	void Update () {
        
    }
}
