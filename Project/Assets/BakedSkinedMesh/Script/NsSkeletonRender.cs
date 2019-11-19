using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class NsSkeletonRender : MonoBehaviour
{
    // 用来绘制骨骼
    public _SkeletonData m_SkeletonData = null;

    private void DrawBones() {
        if (m_SkeletonData == null)
            return;
       
    }

    void OnDrawGizmos() {
        DrawBones();
    }
}
