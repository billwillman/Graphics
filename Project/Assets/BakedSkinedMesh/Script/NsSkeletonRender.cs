using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class NsSkeletonRender : MonoBehaviour
{
    public bool m_IsShowBone = true;
    // 用来绘制骨骼
    public _SkeletonData m_SkeletonData = null;
    // 用来蒙皮的MESH
    public Mesh m_SkeletonMesh = null;
    [Range(0, 1)]
    public float m_AnimPos = 0f;

    private void DrawBones() {
        if (m_SkeletonData == null || m_SkeletonData.m_BoneDatas == null || m_SkeletonData.m_BoneDatas.Length <= 0 || !m_IsShowBone)
            return;

        //Matrix4x4 m = Matrix4x4.Translate(new Vector3(2, 2, 2));
        // 绘制骨骼点
        var trans = this.transform;
        var curMat = trans.localToWorldMatrix;
        for (int i = 0; i < m_SkeletonData.m_BoneDatas.Length; ++i) {
            Gizmos.color = Color.red;
            var bone = m_SkeletonData.m_BoneDatas[i];
            Vector3 center = bone.GetInitBoneCenter(m_SkeletonData, curMat);
            Gizmos.DrawSphere(center, 0.01f);

            // 画骨骼连接
            if (bone.parentBone >= 0) {
                Gizmos.color = Color.blue;
                var parentBone = m_SkeletonData.m_BoneDatas[bone.parentBone];
                Vector3 parentCenter = parentBone.GetInitBoneCenter(m_SkeletonData, curMat);
                Gizmos.DrawLine(center, parentCenter);
            }
        }
    }

    private void UpdateAnim() {
        if (m_SkeletonData != null && m_SkeletonData.m_AnimClip != null) {
            // 动画
            var anim = m_SkeletonData.m_AnimClip;
        }
    }

    // 蒙皮
    private void DoSkinMesh() {

    }

    void OnDrawGizmos() {
        UpdateAnim();
        DrawBones();
        DoSkinMesh();
    }
}
