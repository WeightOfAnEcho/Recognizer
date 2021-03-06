﻿using UnityEngine;
using UnityEngine.UI;
using System.Collections;
using UnityEngine.SceneManagement;

public class Timer : MonoBehaviour
{
    public float timePassed = 0f; // reference for the amount of time left

    public Text Timertext; // reference the UI text
    public Text BestTime; // reference for highscore in UI

    public GameObject StartBarriers; // reference the starting barriers
    public GameObject FinalSpawners;
    public GameObject Shortcut;

    public static Timer instace; // a static variable for other scripts to access
    public  int score = 0; // interger reference for score
    public int highScore = 0; // interger reference for highscore
    string highScoreKey = "Best Time: "; // reference for string kept for player prefs


    void Start()
    {
        instace = this; // set the static variable to this script
        highScore = PlayerPrefs.GetInt(highScoreKey);  //Get the highScore from player prefs if it is there, 0 otherwise.
        BestTime.text = "Best Time: " + (highScore); // set the best time text to read as the highest score
        FinalSpawners.gameObject.SetActive(false); // ensure the final waves of spawners are not active
    }

    void Update()
    {
        
        score = Mathf.RoundToInt(timePassed); //score int = time passed float but rounded to the nearest int
        Timertext.text = score.ToString(); // set the timer passed text value to the score int string

        if (SceneManager.GetActiveScene() == SceneManager.GetSceneByName("Level01")) // get the active scene and check if it's LevelO1
        {
            timePassed += Time.deltaTime; //time left minus delta time

            if (timePassed >= 0) // if time left is greater or equal to 0
            {
                Timertext.text = "Survived For: " + Mathf.Round(timePassed); // display the time left in referenced UI text
            }

            if (Mathf.Round(timePassed) >= 25) // when survived for 30 seconds
            {
                Destroy(StartBarriers); // destory the starting barriers
            }

            if (Mathf.Round(timePassed) >= 120) // when survived for 120 seconds
            {
                FinalSpawners.gameObject.SetActive (true); // set the final spawner waves to active (good luck)
                Shortcut.gameObject.SetActive(false);
            }

        }
        
    }

    public void UpdateHighScore() // update high score function (called by the player when they enter the teleport)
    {
        if (score > highScore) // if the score int is higher than the currently stored high score int
        {
            PlayerPrefs.SetInt(highScoreKey, score); // set the high score key as the current score
            PlayerPrefs.Save(); // ensure the player prefs are saved to be retrieved on reload
            SceneManager.LoadScene("CompleteScreen"); // load the complete screen
        }

        else
        {
            SceneManager.LoadScene("CompleteScreen"); // load the complete screen
        }
    }
}
