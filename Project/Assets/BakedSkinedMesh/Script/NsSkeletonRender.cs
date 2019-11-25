using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(MeshRenderer), typeof(MeshFilter))]
public class NsSkeletonRender : MonoBehaviour
{
    public bool m_IsShowBone = true;
    public bool m_IsShowMesh = true;
    public bool m_IsUseUVBoneWeight = true;
    public Material m_SkeletonMeshMat = null;
    // 用来绘制骨骼
    public _SkeletonData m_SkeletonData = null;
    // 用来蒙皮的MESH
    public Mesh m_SkeletonMesh = null;
    public _VertexsData m_VertexsData = null;
    [Range(0, 1)]
    public float m_AnimPos = 0f;
    private List<Vector4> m_BoneIndexList = new List<Vector4>();
    private List<Vector4> m_BoneWeightList = new List<Vector4>();
    private Vector3[] m_MeshVecs = null;
    private Mesh m_Mesh = null;
    private int m_LastMeshFilterInstance = -1;
    private MeshRenderer m_MeshRender = null;
    private MeshFilter m_MeshFilter = null;

    public Mesh RunTimeMesh {
        get {
            return m_Mesh;
        }
    }

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
        if ((m_SkeletonMesh == null && m_VertexsData == null) || m_SkeletonData == null) {
            DestroyMesh();
            m_LastMeshFilterInstance = -1;
            ClearVertexBoneList();
            return;
        }

        

        DestroyMesh();
        int instanceID = 0;
        if (m_SkeletonMesh != null)
        {
            instanceID = m_SkeletonMesh.GetInstanceID();
            m_Mesh = GameObject.Instantiate(m_SkeletonMesh);
        }
        else if (m_VertexsData != null)
        {
            m_Mesh = new Mesh();
            m_Mesh.MarkDynamic();
            if (m_VertexsData.m_Vertexs != null && m_VertexsData.m_Vertexs.Length > 0)
            {
                m_Mesh.vertices = m_VertexsData.m_Vertexs[0].positons;
                m_Mesh.indexFormat = m_VertexsData.m_Vertexs[0].indexFormat;
                m_Mesh.colors = m_VertexsData.m_Vertexs[0].colors;
                m_Mesh.normals = m_VertexsData.m_Vertexs[0].normals;
                m_Mesh.uv = m_VertexsData.m_Vertexs[0].uvs;

                if (m_VertexsData.m_Vertexs[0].indexes != null)
                {
                    m_Mesh.subMeshCount = m_VertexsData.m_Vertexs[0].indexes.Length;
                    for (int i = 0; i < m_VertexsData.m_Vertexs[0].indexes.Length; ++i)
                    {
                        var indexData = m_VertexsData.m_Vertexs[0].indexes[i];
                        m_Mesh.SetIndices(indexData.index, indexData.topology, i);
                    }
                }

                m_Mesh.UploadMeshData(false);
                instanceID = m_Mesh.GetInstanceID();
                
            }
        }
        else
        {
            return;
        }
        var mesh = m_Mesh;
        // 动态BUFFER
        mesh.MarkDynamic();
       // m_Mesh.UploadMeshData(false);
        if (instanceID != m_LastMeshFilterInstance)
        {
            m_LastMeshFilterInstance = instanceID;
            ClearVertexBoneList();

            if (m_IsUseUVBoneWeight && m_SkeletonMesh != null)
            {
                var boneUVStartIdx = m_SkeletonData.m_StartBoneUV;
                mesh.GetUVs(boneUVStartIdx, m_BoneIndexList);
                mesh.GetUVs(boneUVStartIdx + 1, m_BoneWeightList);
            } else {
                m_BoneIndexList = m_SkeletonData.BoneIndexList;
                m_BoneWeightList = m_SkeletonData.BoneWeightList;
            }
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
    }

    private string Vec3ToString(Vector3 v)
    {
        string ret = string.Format("(x:{0}, y:{1}, z{2})", v.x.ToString(), v.y.ToString(), v.z.ToString());
        return ret;
    }

    private Vector3 BoneInitTransVec(_SkeletonData skl, _BoneData bone, Vector4 vec)
    {
        vec.w = 1; // 這裏要注意
        Vector3 ret = bone.GetInitGlobalTransMatrix(skl) * bone.bindPose * vec;
        return ret;
    }

    // 蒙皮
    private void DoCpuSkinMesh(bool isInitPos = true) {
        if (m_IsShowMesh && m_SkeletonData != null && m_Mesh != null && m_Mesh != null) {
            InitBoneInfo();
            if (m_BoneIndexList != null && m_BoneIndexList.Count > 0 && m_BoneWeightList != null && m_BoneWeightList.Count > 0) {

                //IntPtr pBuffer = mesh.GetNativeVertexBufferPtr();
                // if (pBuffer != default(IntPtr)) {

                //}
                //UnsafeUtil.Vector3HackArraySizeCall
                var bones = m_SkeletonData.m_BoneDatas;
                if (isInitPos) {
                    //var mat = Matrix4x4.identity;
                    if (m_MeshVecs != null && m_MeshVecs.Length > 0) {
                        int maxVec = m_MeshVecs.Length;
                        if (m_BoneIndexList.Count < maxVec)
                            maxVec = m_BoneIndexList.Count;
                        if (m_BoneWeightList.Count < maxVec)
                            maxVec = m_BoneWeightList.Count;
                        for (int i = 0; i < maxVec; ++i) {
                            Vector3 vec = m_MeshVecs[i];
                            int idx1 = (int)m_BoneIndexList[i].x;
                            int idx2 = (int)m_BoneIndexList[i].y;
                            int idx3 = (int)m_BoneIndexList[i].z;
                            int idx4 = (int)m_BoneIndexList[i].w;
                            var bone1 = bones[idx1];
                            var bone2 = bones[idx2];
                            var bone3 = bones[idx3];
                            var bone4 = bones[idx4];
                            float w1 = m_BoneWeightList[i].x;
                            float w2 = m_BoneWeightList[i].y;
                            float w3 = m_BoneWeightList[i].z;
                            float w4 = m_BoneWeightList[i].w;

                            var p1 = BoneInitTransVec(m_SkeletonData, bone1, vec);
                            var p2 = BoneInitTransVec(m_SkeletonData, bone2, vec);
                            var p3 = BoneInitTransVec(m_SkeletonData, bone3, vec);
                            var p4 = BoneInitTransVec(m_SkeletonData, bone4, vec);
                            vec = p1 * w1 + p2 * w2 + p3 * w3 + p4 * w4;
                            Debug.LogFormat("old vec: {0} === new vec: {1}", Vec3ToString(m_MeshVecs[i]), Vec3ToString(vec));
                            // m_MeshVecs[i] = new Vector3(1, 1, 1);
                            m_MeshVecs[i] = vec;
                        }

                       
                    } else {
                        Debug.LogError("MeshVec num is not equal boneindex and boneweight");
                    }

                      m_Mesh.vertices = m_MeshVecs;
                      m_Mesh.UploadMeshData(false);

                   // m_Mesh.bindposes = m_SkeletonData.bindPoseArray;
                    //m_Mesh.UploadMeshData(false);
                }
                
            }
        }
    }

    private void DrawMesh() {
        if (m_IsShowMesh && m_Mesh != null) {
           //, Debug.Log("--------------------abcdef");
           if (m_MeshRender == null) {
                m_MeshRender = GetComponent<MeshRenderer>();
            }
            if (m_MeshFilter == null)
                m_MeshFilter = GetComponent<MeshFilter>();
            if (m_MeshFilter != null && m_MeshFilter.sharedMesh != m_Mesh) {
                m_MeshFilter.sharedMesh = m_Mesh;
            }
            //var trans = this.transform;
            // Graphics.DrawMesh(m_Mesh, trans.localToWorldMatrix, m_SkeletonMeshMat, 0);
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
        if (!Application.isPlaying) {
            if (m_IsShowMesh && m_SkeletonMesh != null) {
              //  var trans = this.transform;
               // Gizmos.DrawMesh(m_SkeletonMesh, trans.position, trans.rotation, trans.lossyScale);
            }
        }
        
    }
}
