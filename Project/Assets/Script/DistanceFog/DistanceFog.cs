using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(Camera))]
public class DistanceFog : MonoBehaviour
{

    public Color m_DepthFogColor = Color.black;
    public float m_DepthFogStart = 0f;
    public float m_DepthFogRange = 1.0f;
    public float m_DepthFogDensity = 0.262f;
    public float m_HeightFogStart = 1.0f;
    public float m_HeightFogRange = 1000.0f;

    private int m_DepthFogColorId = 0;
    private int m_DepthFogStartId = 0;
    private int m_DepthFogRangeId = 0;
    private int m_DepthFogDensityId = 0;
    private int m_HeightFogStartId = 0;
    private int m_HeightFogRangeId = 0;

    protected int DepthFogColorId {
        get {
            if (m_DepthFogColorId == 0)
                m_DepthFogColorId = Shader.PropertyToID("_DepthFogColor");
            return m_DepthFogColorId;
        }
    }

    protected int DepthFogStartId {
        get {
            if (m_DepthFogStartId == 0)
                m_DepthFogStartId = Shader.PropertyToID("_DepthFogStart");
            return m_DepthFogStartId;
        }
    }

    protected int DepthFogRangeId {
        get {
            if (m_DepthFogRangeId == 0)
                m_DepthFogRangeId = Shader.PropertyToID("_DepthFogRange");
            return m_DepthFogRangeId;
        }
    }

    protected int DepthFogDensityId {
        get {
            if (m_DepthFogDensityId == 0)
                m_DepthFogDensityId = Shader.PropertyToID("_DepthFogDensity");
            return m_DepthFogDensityId;
        }
    }

    protected int HeightFogStartId {
        get {
            if (m_HeightFogStartId == 0)
                m_HeightFogStartId = Shader.PropertyToID("_HeightFogStart");
            return m_HeightFogStartId;
        }
    }

    protected int HeightFogRangeId {
        get {
            if (m_HeightFogRangeId == 0)
                m_HeightFogRangeId = Shader.PropertyToID("_HeightFogRange");
            return m_HeightFogRangeId;
        }
    }

    public void SendToFogShader() {
        // 全部设置
        Shader.SetGlobalColor(DepthFogColorId, m_DepthFogColor);
        Shader.SetGlobalFloat(DepthFogStartId, m_DepthFogStart);
        Shader.SetGlobalFloat(DepthFogRangeId, m_DepthFogRange);
        Shader.SetGlobalFloat(DepthFogDensityId, m_DepthFogDensityId);
        Shader.SetGlobalFloat(HeightFogStartId, m_HeightFogStart);
        Shader.SetGlobalFloat(HeightFogRangeId, m_HeightFogRangeId);
    }

    void OnPreRender() {
        SendToFogShader();
    }
}
