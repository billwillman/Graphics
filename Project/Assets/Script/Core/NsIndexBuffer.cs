using System;

public class NsIndexBuffer<T> : NsIBuffer {
    private T[] m_IndexBuf = null;

    public void SetCount(int newCnt) {
        int oldCount;
        if (m_IndexBuf == null)
            oldCount = 0;
        else {
            oldCount = m_IndexBuf.Length;
        }
        if (newCnt != oldCount) {
            m_IndexBuf = ArrayCopyCount(m_IndexBuf, newCnt);
        }
    }

    public void Fill(int index, T value) {
        m_IndexBuf[index] = value;
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
}

public class NsIndex16Buffer : NsIndexBuffer<ushort> { }

public class NsIndex32Buffer : NsIndexBuffer<uint> { }