using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEditor;
using UnityEngine;


enum ToolItems
{ 
    Tool_None = 0,
    Tool_CombineMesh = 1,
    Tool_MeshBrush = 2
};

/*
 * 预计支持功能：
 * 1.将多个SKINEDMESH合并到一个普通MESH，也可以直接转单独MESH
 * 2.默认的PoseMatrix到纹理纹理格式RGBAHALF
 * 3.动画到纹理格式RGBAHALF
 */
public class BakedSkinedMeshEditor : EditorWindow
{
    private GameObject m_SelGameObj = null;
    private Renderer[] m_SelSkinMehes = null;
    private AnimationClip m_SelClip = null;
    private Vector2 m_Scroll = Vector2.zero;
    private ToolItems m_Tool = ToolItems.Tool_CombineMesh;

    private bool DrawExpandButton(string title, ToolItems itemType)
    {
        string preText = string.Empty;
        bool isExpand = m_Tool == itemType;
        if (isExpand)
            preText = "(缩进)";
        else
            preText = "(展开)";
        if (GUILayout.Button(string.Format("{0}{1}", preText, title)))
        {
            if (isExpand)
            {
                m_Tool = ToolItems.Tool_None;
                isExpand = false;
            }
            else
            {
                m_Tool = itemType;
                isExpand = true;
            }
        }
        return isExpand;
    }

    public BakedSkinedMeshEditor() {
        this.titleContent = new GUIContent("蒙皮骨骼动画工具");
    }

    [MenuItem("BakedMesh/蒙皮骨骼工具")]
    public static void CreateWindow() {
        EditorWindow.GetWindow(typeof(BakedSkinedMeshEditor));
    }

    // 合并SkinedMesh到MESH
    void CombineSkinedMeshes(int sel = 0) {
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
            if (sklMesh != null) {
                Mesh mesh = null;
                MeshRenderer mR = sklMesh as MeshRenderer;
                if (mR != null)
                {
                    MeshFilter mF = mR.GetComponent<MeshFilter>();
                    if (mF != null)
                        mesh = mF.sharedMesh;
                }
                else
                {
                    SkinnedMeshRenderer smR = sklMesh as SkinnedMeshRenderer;
                    if (smR != null) {
                        if (sel == 2) {
                            mesh = new Mesh();
                            smR.BakeMesh(mesh);
                        } else
                            mesh = smR.sharedMesh;
                    }
                }
                if (mesh != null)
                    meshList.Add(mesh);
                //var mesh = new Mesh();
                //sklMesh.BakeMesh(mesh);
                //meshList.Add(mesh);
            }
        }

        if (sel == 0)
        {
            filePath = Path.ChangeExtension(filePath, ".dae");
            ExportCollada.Export(meshList, m_SelSkinMehes, filePath);
        } else if (sel == 1)
        {
            ExportCollada.ExportSklsToAsset(m_SelSkinMehes, filePath);
        } else if (sel == 2) {
            string fileName = Path.GetFileNameWithoutExtension(filePath);
            filePath = string.Format("{0}/{1}_bakedMesh.dae", Path.GetDirectoryName(filePath), fileName);
            ExportCollada.Export(meshList, m_SelSkinMehes, filePath);
            if (meshList != null) {
                for (int i = 0; i < meshList.Count; ++i) {
                    var mesh = meshList[i];
                    if (mesh != null)
                        GameObject.DestroyImmediate(mesh);
                }
                meshList.Clear();
            }
        } else if (sel == 3) {
            // 合并动画到贴图
            filePath = Path.GetDirectoryName(filePath);
            ExportCollada.ExportAnimToTex(meshList, m_SelSkinMehes, m_SelClip, filePath);
            
        }
      //  ExportCollada.ExportToScene(meshList, m_SelSkinMehes);

        AssetDatabase.Refresh();
#endif
    }

    private void DrawCombineMesh()
    {
        GameObject newSelect = null;
        Renderer[] sklMesh = null;
        newSelect = EditorGUILayout.ObjectField("选择骨骼动画对象", m_SelGameObj, typeof(GameObject),
#if UNITY_5_3
			false
#else
 true
#endif
) as GameObject;
        if (newSelect != m_SelGameObj)
        {
            if (newSelect != null)
            {
                sklMesh = newSelect.GetComponentsInChildren<Renderer>();
                if (sklMesh == null || sklMesh.Length <= 0)
                {
                    newSelect = null;
                    sklMesh = null;
                    Debug.LogError("not found: Renderer Componet");
                }
            }
            m_SelGameObj = newSelect;
            m_SelSkinMehes = sklMesh;
            m_SelClip = null;
            // 处理空MESH的情况
            if (m_SelSkinMehes != null)
            {
                List<Renderer> rList = new List<Renderer>();
                for (int i = 0; i < m_SelSkinMehes.Length; ++i)
                {
                    var mR = m_SelSkinMehes[i] as MeshRenderer;
                    if (mR != null)
                    {
                        var mF = mR.GetComponent<MeshFilter>();
                        if (mF != null && mF.sharedMesh != null)
                            rList.Add(mR);
                    }
                    else
                    {
                        var sR = m_SelSkinMehes[i] as SkinnedMeshRenderer;
                        if (sR != null && sR.sharedMesh != null)
                        {
                            rList.Add(sR);
                        }
                    }
                }
                m_SelSkinMehes = rList.ToArray();
            }
        }

        if (m_SelGameObj != null)
        {
            // EditorGUILayout.Label
            if (m_SelSkinMehes != null && m_SelSkinMehes.Length > 0)
            {
                bool isHasSkinedMesh = false;
                m_Scroll = EditorGUILayout.BeginScrollView(m_Scroll, true, false);
                for (int i = 0; i < m_SelSkinMehes.Length; ++i)
                {
                    var sub = m_SelSkinMehes[i];
                    if (sub != null)
                    {
                        EditorGUILayout.ObjectField(sub, typeof(Renderer), true);
                        if (!isHasSkinedMesh) {
                            isHasSkinedMesh = (sub is SkinnedMeshRenderer);
                        }
                    }
                }

                if (isHasSkinedMesh) {
                   // EditorGUILayout.ObjectField
                    m_SelClip = EditorGUILayout.ObjectField("动画转贴图", m_SelClip, typeof(AnimationClip), true) as AnimationClip;
                }

                EditorGUILayout.EndScrollView();
                if (GUILayout.Button("合并所有到普通MESH"))
                {
                    CombineSkinedMeshes();
                }
                if (GUILayout.Button("导出SkinedMesh数据到Asset"))
                {
                    CombineSkinedMeshes(1);
                }
                if (isHasSkinedMesh && GUILayout.Button("导出SkinedMesh烘焙数据到Asset")) {
                    CombineSkinedMeshes(2);
                }

                if (isHasSkinedMesh && GUILayout.Button("合并动画到贴图")) {
                    CombineSkinedMeshes(3);
                }
            }
        }
    }

    private void DrawMeshBrush()
    {
        EditorGUILayout.BeginHorizontal();
        if (GUILayout.RepeatButton("圆"))
        {

        }
        if (GUILayout.RepeatButton("五角星"))
        {

        }
        EditorGUILayout.EndHorizontal();
    }

    void OnGUI() {
        if (DrawExpandButton("合并MESH", ToolItems.Tool_CombineMesh))
          DrawCombineMesh();
        if (DrawExpandButton("MESH Brush", ToolItems.Tool_MeshBrush))
            DrawMeshBrush();
    }
}
