using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEditor;
using UnityEngine;


/*
 * 预计支持功能：
 * 1.将多个SKINEDMESH合并到一个普通MESH，也可以直接转单独MESH
 * 2.默认的PoseMatrix到纹理纹理格式RGBAHALF
 * 3.动画到纹理格式RGBAHALF
 */
public class BakedSkinedMeshEditor : EditorWindow
{
    private GameObject m_SelGameObj = null;
    private SkinnedMeshRenderer[] m_SelSkinMehes = null;

    public BakedSkinedMeshEditor() {
        this.titleContent = new GUIContent("蒙皮骨骼动画工具");
    }

    [MenuItem("BakedMesh/蒙皮骨骼工具")]
    public static void CreateWindow() {
        EditorWindow.GetWindow(typeof(BakedSkinedMeshEditor));
    }

    // 合并SkinedMesh到MESH
    void CombineSkinedMeshes() {
#if UNITY_EDITOR
        
        if (m_SelGameObj == null || m_SelSkinMehes == null || m_SelSkinMehes.Length <= 0) {
            Debug.LogError("选中合并对象为NULL");
            return;
        }
        string filePath = AssetDatabase.GetAssetPath(m_SelGameObj);
        if (string.IsNullOrEmpty(filePath)) {
            string scenePath = AssetDatabase.GetAssetOrScenePath(m_SelGameObj);
            if (!string.IsNullOrEmpty(scenePath)) {
		#if !UNITY_5_3
                filePath = PrefabUtility.GetPrefabAssetPathOfNearestInstanceRoot(m_SelGameObj);
		#endif
                if (string.IsNullOrEmpty(filePath)) {
                    Debug.LogError("选中对象文件路径为空");
                    return;
                }
            }
           
        }

        List<Mesh> meshList = new List<Mesh>();
        for (int i = 0; i < m_SelSkinMehes.Length; ++i) {
            var sklMesh = m_SelSkinMehes[i];
            if (sklMesh != null && sklMesh.sharedMesh != null) {
                meshList.Add(sklMesh.sharedMesh);
                //var mesh = new Mesh();
                //sklMesh.BakeMesh(mesh);
                //meshList.Add(mesh);
            }
        }

        filePath = Path.ChangeExtension(filePath, ".dae");
        ExportCollada.Export(meshList, m_SelSkinMehes, filePath);
      //  ExportCollada.ExportToScene(meshList, m_SelSkinMehes);

        AssetDatabase.Refresh();
#endif
    }

    void OnGUI() {
        GameObject newSelect = null;
        SkinnedMeshRenderer[] sklMesh = null;
        newSelect = EditorGUILayout.ObjectField("选择骨骼动画对象", m_SelGameObj, typeof(GameObject), 
			#if UNITY_5_3
			false
			#else
			true
			#endif
		) as GameObject;
        if (newSelect != m_SelGameObj) {
            if (newSelect != null) {
                sklMesh = newSelect.GetComponentsInChildren<SkinnedMeshRenderer>();
                if (sklMesh == null || sklMesh.Length <= 0) {
                    newSelect = null;
                    sklMesh = null;
                }
            }
            m_SelGameObj = newSelect;
            m_SelSkinMehes = sklMesh;
        }

        if (m_SelGameObj != null) {
           // EditorGUILayout.Label
           if (m_SelSkinMehes != null && m_SelSkinMehes.Length > 0) {
                for (int i = 0; i < m_SelSkinMehes.Length; ++i) {
                    var sub = m_SelSkinMehes[i];
                    if (sub != null) {
                        EditorGUILayout.ObjectField(sub, typeof(SkinnedMeshRenderer), true);
                    }
                }
                if (GUILayout.Button("合并所有到普通MESH")) {
                    CombineSkinedMeshes();
                }
            }
        }
    }
}
