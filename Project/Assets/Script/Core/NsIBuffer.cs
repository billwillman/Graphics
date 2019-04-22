using System;

public class NsIBuffer {

    public static T[] ArrayCopyCount<T>(T[] srcArray, int count) {
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