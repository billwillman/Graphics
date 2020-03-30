using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

public class ShadowCamera : MonoBehaviour
{

    private Camera m_Cam = null;

    private void Start() {
        m_Cam = Camera.main;
        if (m_Cam != null) {

        }
    }
}
