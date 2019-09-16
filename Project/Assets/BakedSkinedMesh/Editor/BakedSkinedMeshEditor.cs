using System.Collections;
using System.Collections.Generic;
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

    }

    void OnGUI() {
        GameObject newSelect = null;
        SkinnedMeshRenderer[] sklMesh = null;
        newSelect = EditorGUILayout.ObjectField("选择骨骼动画对象", m_SelGameObj, typeof(GameObject), true) as GameObject;
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
