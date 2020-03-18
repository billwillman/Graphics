using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TextProj : MonoBehaviour
{
    public Camera m_ProjCam = null;

    private Material m_Mat = null;

    private void Awake() {
       var renderer =  GetComponent<Renderer>();
        if (renderer != null) {
            m_Mat = renderer.sharedMaterial;
            //renderer.SetPropertyBlock
        }
    }

    private void Update() {
        if (m_Mat != null && m_ProjCam != null) {
           var matrix = m_ProjCam.projectionMatrix * m_ProjCam.worldToCameraMatrix;
            m_Mat.SetMatrix("_ProjMat", matrix);
            m_Mat.SetTexture("_ProjTex", m_ProjCam.targetTexture);
        }
    }
}
