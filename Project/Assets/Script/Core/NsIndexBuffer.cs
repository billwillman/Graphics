using System;
using System.Runtime.InteropServices;
using UnityEngine;

public interface NsIIndexBuffer {
    void SetCount(int newCnt);
    int Count {
        get;
        set;
    }
}


public class NsIndexBuffer<T> : NsIBuffer, NsIIndexBuffer {
    private T[] m_IndexBuf = null;
    private ComputeBuffer m_CB = null;
    private bool m_IsDirty = false;

    public void SetCount(int newCnt) {
        int oldCount;
        if (m_IndexBuf == null)
            oldCount = 0;
        else {
            oldCount = m_IndexBuf.Length;
        }
        if (newCnt != oldCount) {
            m_IndexBuf = ArrayCopyCount(m_IndexBuf, newCnt);
            m_IsDirty = true;
        }
    }

    public void Fill(int index, T value) {
        m_IndexBuf[index] = value;
        m_IsDirty = true;
    }

    public int Count {
        get {
            if (m_IndexBuf != null)
                return m_IndexBuf.Length;
            return 0;
        }
        set {
            SetCount(value);
        }
    }

    public ComputeBuffer Buffer {
        get {
            return GetCB(m_IndexBuf, m_CB, Marshal.SizeOf(typeof(T)), m_IsDirty);
        }
    }
}

public class NsIndex16Buffer : NsIndexBuffer<ushort> { }

public class NsIndex32Buffer : NsIndexBuffer<uint> { }