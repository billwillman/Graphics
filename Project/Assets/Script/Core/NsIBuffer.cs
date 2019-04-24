using System;
using UnityEngine;

public class NsIBuffer {

    protected static ComputeBuffer GetCB(Array buf, ComputeBuffer CB, int stride, bool isDirty = false) {
        if (buf == null)
            return null;
        if (CB == null || CB.count != buf.Length || CB.stride != stride) {
            if (CB != null)
                CB.Dispose();
            if (buf.Length > 0) {
                CB = new ComputeBuffer(buf.Length, stride);
                CB.SetData(buf);
            }
        } else if (isDirty) {
            CB.SetData(buf);
        }
        return CB;
    }

    protected static T[] ArrayCopyCount<T>(T[] srcArray, int count) {
        T[] dstArray = null;
        if (count <= 0)
            return dstArray;
        if (srcArray != null && srcArray.Length == count)
            return srcArray;
        dstArray = new T[count];
        if (srcArray == null)
            return dstArray;
        int oldCnt = srcArray.Length;
        int newCnt = dstArray.Length;
        int copyCnt = oldCnt > newCnt ? newCnt : oldCnt;
        Array.Copy(srcArray, dstArray, copyCnt);
        return dstArray;
    }
}