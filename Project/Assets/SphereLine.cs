using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SphereLine : MonoBehaviour
{
    public float m_BaseWidth = 0.2f;
    public float m_Scale = 1f;

    public void Update() {
        this.transform.localScale = new Vector3(m_Scale, m_Scale, 1f);
        var renderer = this.GetComponent<MeshRenderer>();
        if (renderer != null) {
            var mat = renderer.sharedMaterial;
            if (mat != null && mat.HasProperty("_LineWidth")) {
                // float value = m_BaseWidth - 0.01f * m_Scale;
                 // float value = m_BaseWidth / Mathf.Pow(m_Scale, 2);
                float value = m_BaseWidth - m_BaseWidth /20f * Mathf.Pow(m_Scale, 2);
                //float value = m_BaseWidth/m_Scale + (m_Scale - 1.0f) * m_BaseWidth/10f;

                //  float value = m_BaseWidth / m_Scale;
                //float value = m_BaseWidth;
                if (m_Scale >1f) {
                    // value = m_BaseWidth / m_Scale * 2;
                 //  value = m_BaseWidth - m_BaseWidth * 2/ 5 * m_Scale;
                 //   value = m_BaseWidth  - 1f /(m_Scale - 1.0f);
                }
                mat.SetFloat("_LineWidth", value);
            }
        }
    }
}
