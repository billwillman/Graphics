using System;
using System.Runtime.InteropServices;
using UnityEngine;

public class NsVertexBuffer: NsIBuffer {
    private Vector3[] m_VertexBuf = null;
    private Color[] m_ColorBuf = null;
    private Vector2[] m_UV0Buf = null;
    private bool m_IsDirty = false;

    private ComputeBuffer m_VCB = null;
    private ComputeBuffer m_CCB = null;
    private ComputeBuffer m_UCB = null;

    private void FreeCB(ref ComputeBuffer buf) {
        if (buf != null) {
            buf.Dispose();
            buf = null;
        }
    }

    public void Dispose() {
        FreeCB(ref m_VCB);
        FreeCB(ref m_CCB);
        FreeCB(ref m_UCB);
    }

    public ComputeBuffer VertexBuf {
        get {
            return GetCB(m_VertexBuf, m_VCB, Marshal.SizeOf(typeof(Vector3)), m_IsDirty);
        }
    }

    public ComputeBuffer ColorBuf {
        get {
            return GetCB(m_ColorBuf, m_CCB, Marshal.SizeOf(typeof(Color)), m_IsDirty);
        }
    }

    public ComputeBuffer UV0Buf {
        get {
            return GetCB(m_UV0Buf, m_UCB, Marshal.SizeOf(typeof(Vector2)), m_IsDirty);
        }
    }

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
            m_UV0Buf = ArrayCopyCount(m_UV0Buf, newCnt);
            m_IsDirty = true;
        }
    }

    public void Fill(int index, Vector3 vertex, Color color, Vector2 uv) {
        m_VertexBuf[index] = vertex;
        m_ColorBuf[index] = color;
        m_UV0Buf[index] = uv;
        m_IsDirty = true;
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
