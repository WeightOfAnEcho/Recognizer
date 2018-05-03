﻿using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;


public class RestartGame : MonoBehaviour
{

    public Collider collide; // create a reference for the collider in the IDE
    public GameObject RetryClickedTitle; // create a reference for the clicked version of the title in the IDE

    void Start()
    {
        collide = GetComponent<Collider>(); //retrieve the collider
        SetCursorState(); // call the cursor state function


    }

    void SetCursorState()
    {
        Cursor.lockState = CursorLockMode.None; // unlocks the cursor so the player can click Retry
    }

    void Update()

    {
        if (Input.GetMouseButtonDown(0)) // when the left mouse button is pressed
        {
            Ray ray = Camera.main.ScreenPointToRay(Input.mousePosition); //check the position of the raycast from that click
            RaycastHit hit; // variable of raycasting hitting something

            if (collide.Raycast(ray, out hit, 100.0F)) // if tyhe raycast hits the collider attached to this GO
            {
                StartCoroutine(ReLoadLevel()); // start the ReLoadLevel Coroutine
            }


        }

    }

    IEnumerator ReLoadLevel()
    {
        transform.position = new Vector3(-100.55f, 2.2f, -600.7f);// Move the Unclicked title (Blue) out of shot
        RetryClickedTitle.SetActive(true); // Set the Clicked title (Orange) GO to active - the illusion of changing colour
        yield return new WaitForSeconds(0.5f);// wait for 2.5 seconds
        string sceneName = PlayerPrefs.GetString("lastLoadedScene"); //find the string of the last loaded scene
        SceneManager.LoadScene(sceneName); // load the scene retrieved from the string
    }
}
