using UnityEngine;
using System.Collections;

// 陰影管理
[RequireComponent(typeof(Light2D))]
public class LightShadows : MonoBehaviour {
    private Light2D m_ParentLight = null;

    protected Light2D ParentLight {
        get {
            if (m_ParentLight == null)
                m_ParentLight = GetComponent<Light2D>();
            return m_ParentLight;
        }
    }

    
}
