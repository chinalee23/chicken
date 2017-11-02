using System.Collections.Generic;
using UnityEngine;
using RVO;
using System;

public class Circle : MonoBehaviour {
    /* Store the goals of the agents. */
    IList<RVO.Vector2> goals;

    Circle() {
        goals = new List<RVO.Vector2>();
    }

    void setupScenario() {
        /* Specify the global time step of the simulation. */
        Simulator.Instance.setTimeStep(0.25f);

        /*
         * Specify the default parameters for agents that are subsequently
         * added.
         */
        Simulator.Instance.setAgentDefaults(15.0f, 10, 10.0f, 10.0f, 1.5f, 2.0f, new RVO.Vector2(0.0f, 0.0f));

        /*
         * Add agents, specifying their start position, and store their
         * goals on the opposite side of the environment.
         */
        for (int i = 0; i < 10; ++i) {
            Simulator.Instance.addAgent(200.0f *
                new RVO.Vector2((float)Math.Cos(i * 2.0f * Math.PI / 10.0f),
                    (float)Math.Sin(i * 2.0f * Math.PI / 10.0f)));
            goals.Add(-Simulator.Instance.getAgentPosition(i));
        }
    }

    void updateVisualization()
    {
        /* Output the current global time. */
        Debug.Log(Simulator.Instance.getGlobalTime());

        /* Output the current position of all the agents. */
        for (int i = 0; i < Simulator.Instance.getNumAgents(); ++i)
        {
            Debug.Log(string.Format(" {0}", Simulator.Instance.getAgentPosition(i)));
        }

        Console.WriteLine();
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

            Simulator.Instance.setAgentPrefVelocity(i, goalVector);
        }
    }

    bool reachedGoal() {
        /* Check if all agents have reached their goals. */
        for (int i = 0; i < Simulator.Instance.getNumAgents(); ++i) {
            if (RVOMath.absSq(Simulator.Instance.getAgentPosition(i) - goals[i]) > Simulator.Instance.getAgentRadius(i) * Simulator.Instance.getAgentRadius(i)) {
                return false;
            }
        }

        return true;
    }

    void main() {
        Circle circle = new Circle();

        /* Set up the scenario. */
        circle.setupScenario();

        /* Perform (and manipulate) the simulation. */
        do {
            circle.updateVisualization();
            circle.setPreferredVelocities();
            Simulator.Instance.doStep();
        }
        while (!circle.reachedGoal());
    }

    // Use this for initialization
    void Start () {
        main();
	}
	
	// Update is called once per frame
	void Update () {
		
	}
}
