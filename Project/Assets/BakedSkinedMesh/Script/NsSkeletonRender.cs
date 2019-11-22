using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class NsSkeletonRender : MonoBehaviour
{
    public bool m_IsShowBone = true;
    public bool m_IsShowMesh = true;
    // 用来绘制骨骼
    public _SkeletonData m_SkeletonData = null;
    // 用来蒙皮的MESH
    public MeshFilter m_SkeletonMesh = null;
    [Range(0, 1)]
    public float m_AnimPos = 0f;
    private List<Vector4> m_BoneIndexList = new List<Vector4>();
    private List<Vector4> m_BoneWeightList = new List<Vector4>();
    private Vector3[] m_MeshVecs = null;
    private Mesh m_Mesh = null;
    private int m_LastMeshFilterInstance = -1;

    private void DestroyMesh() {
        if (m_Mesh != null) {
            GameObject.Destroy(m_Mesh);
            m_Mesh = null;
        }
    }

    void OnDestroy() {
            DestroyMesh();
        }

    private void ClearVertexBoneList() {
        m_BoneWeightList.Clear();
        m_BoneWeightList.Clear();
        m_MeshVecs = null;
    }

    private void InitBoneInfo() {
        if (m_SkeletonMesh == null || m_SkeletonMesh.sharedMesh == null || m_SkeletonData == null) {
            DestroyMesh();
            m_LastMeshFilterInstance = -1;
            ClearVertexBoneList();
            return;
        }

        DestroyMesh();
        m_Mesh = GameObject.Instantiate(m_SkeletonMesh.sharedMesh);
        var mesh = m_Mesh;
        // 动态BUFFER
        mesh.MarkDynamic();
        if (m_SkeletonMesh.GetInstanceID() != m_LastMeshFilterInstance) {
            m_LastMeshFilterInstance = m_SkeletonMesh.GetInstanceID();
            ClearVertexBoneList();

             var boneUVStartIdx = m_SkeletonData.m_StartBoneUV;
            mesh.GetUVs(boneUVStartIdx, m_BoneIndexList);
            mesh.GetUVs(boneUVStartIdx + 1, m_BoneWeightList);
            m_MeshVecs = mesh.vertices;
            //if (m_BoneIndexList.Count > 0) {
            //    Debug.LogError(m_BoneIndexList[0].ToString());
            // }
        }
    }

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
    private void DoCpuSkinMesh(bool isInitPos = true) {
        if (m_IsShowMesh && m_SkeletonData != null && m_SkeletonMesh != null && m_SkeletonMesh.sharedMesh != null && m_Mesh != null) {
            InitBoneInfo();
            if (m_BoneIndexList != null && m_BoneIndexList.Count > 0 && m_BoneWeightList != null && m_BoneWeightList.Count > 0) {

                //IntPtr pBuffer = mesh.GetNativeVertexBufferPtr();
                // if (pBuffer != default(IntPtr)) {

                //}
                //UnsafeUtil.Vector3HackArraySizeCall
                var bones = m_SkeletonData.m_BoneDatas;
                if (isInitPos) {
                    //var mat = Matrix4x4.identity;
                    if (m_MeshVecs != null && m_MeshVecs.Length > 0 && m_MeshVecs.Length == m_BoneIndexList.Count && m_MeshVecs.Length == m_BoneWeightList.Count) {
                        for (int i = 0; i < m_MeshVecs.Length; ++i) {
                            Vector3 vec = m_MeshVecs[i];
                            int idx1 = (int)m_BoneIndexList[i].x;
                            int idx2 = (int)m_BoneIndexList[i].y;
                            int idx3 = (int)m_BoneIndexList[i].z;
                            int idx4 = (int)m_BoneIndexList[i].w;
                            var bone1 = bones[idx1];
                            var bone2 = bones[idx2];
                            var bone3 = bones[idx3];
                            var bone4 = bones[idx4];

                            var p1 = bone1.GetInitGlobalTransMatrix(m_SkeletonData) * bone1.bindPose * vec;
                            var p2 = bone2.GetInitGlobalTransMatrix(m_SkeletonData) * bone2.bindPose * vec;
                            var p3 = bone3.GetInitGlobalTransMatrix(m_SkeletonData) * bone3.bindPose * vec;
                            var p4 = bone4.GetInitGlobalTransMatrix(m_SkeletonData) * bone4.bindPose * vec;
                            vec = p1 * m_BoneWeightList[i].x + p2 * m_BoneWeightList[i].y + p3 * m_BoneWeightList[i].z + p4 * m_BoneWeightList[i].w;
                            m_MeshVecs[i] = vec;
                        }

                       
                    }

                      m_Mesh.vertices = m_MeshVecs;
                      m_Mesh.UploadMeshData(false);

                    //mesh.bindposes = m_SkeletonData.bindPoseArray;
                    //mesh.UploadMeshData(false);
                }
                
            }
        }
    }

    private void DrawMesh() {
        if (m_IsShowMesh && m_SkeletonMesh != null && m_SkeletonMesh.sharedMesh != null && m_Mesh != null) {
            var trans = this.transform;
            Graphics.DrawMesh(m_Mesh, trans.localToWorldMatrix, null, 0);
           // Gizmos.color = Color.white;
           // Gizmos.DrawMesh(m_SkeletonMesh.sharedMesh, trans.position, trans.rotation, trans.lossyScale);
        }

    }

    private void DoBindPose() {
        DoCpuSkinMesh(true);
    }

    private void Start() {
        InitBoneInfo();
        DoBindPose();
    }

    private void Update() {
        UpdateAnim();
    }

    private void LateUpdate() {
        DrawMesh();
    }

    void OnDrawGizmosSelected() {
       
        DrawBones();
        
        
    }
}
