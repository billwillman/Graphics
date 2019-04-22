using System;
using UnityEngine;

public class NsVertexBuffer: NsIBuffer {
    private Vector3[] m_VertexBuf = null;
    private Color[] m_ColorBuf = null;
    private Vector2[] m_UV0 = null;

    public void SetCount(int newCnt) {
        int oldCount;
        if (m_VertexBuf == null)
            oldCount = 0;
        else {
            oldCount = m_VertexBuf.Length;
        }
        if (newCnt != oldCount) {
            m_VertexBuf = ArrayCopyCount(m_VertexBuf, newCnt);
            m_ColorBuf = ArrayCopyCount(m_ColorBuf, newCnt);
            m_UV0 = ArrayCopyCount(m_UV0, newCnt);
        }
    }

    public void Fill(int index, Vector3 vertex, Color color, Vector2 uv) {
        m_VertexBuf[index] = vertex;
        m_ColorBuf[index] = color;
        m_UV0[index] = uv;
    }

    public int Count {
        get {
            if (m_VertexBuf != null)
                return m_VertexBuf.Length;
            return 0;
        }
        set {
            SetCount(value);
        }
    }
}
