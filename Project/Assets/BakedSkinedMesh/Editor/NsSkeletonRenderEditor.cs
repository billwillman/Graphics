using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

[CustomEditor(typeof(NsSkeletonRender))]
public class NsSkeletonRenderEditor : Editor
{
    public override void OnInspectorGUI() {
        base.OnInspectorGUI();
        var r = this.target as NsSkeletonRender;
        if (r != null) {
            if (Application.isPlaying) {
                if (GUILayout.Button("导出当前Mesh")) {
                    var mesh = r.RunTimeMesh;
                    if (mesh != null) {
                        List<Mesh> lst = new List<Mesh>();
                        lst.Add(mesh);
                        Renderer[] rlst = new Renderer[1];
                        rlst[0] = r.GetComponent<Renderer>();

                        ExportCollada.Export(lst, rlst, "Assets/NsSkeleton_RunTime.dae");
                    }
                }
            }
        }
    }
}

//[CustomEditor(typeof(GameObject))]
public class NsGameObjectEditor: Editor {

    private void DrawMat(Matrix4x4 mat) {
        for (int i = 0; i < 4; ++i) {
            Vector4 v = mat.GetRow(i);
            EditorGUILayout.BeginHorizontal();
            EditorGUILayout.Vector4Field("Row_" + i.ToString(), v);
            EditorGUILayout.EndHorizontal();
        }
        
        if (GUILayout.Button("复制矩阵")) {
            System.Text.StringBuilder strBuild = new System.Text.StringBuilder();
            for (int i = 0; i < 4; ++i) {
                Vector4 v = mat.GetColumn(i);
                strBuild.AppendFormat("m0{0:D}:{1}\tm1{0:D}:{2}\tm2{0:D}:{3}\tm3{0:D}:{4}\r\n", i, v.x.ToString(), v.y.ToString(), v.z.ToString(), v.w.ToString());
            }
            GUIUtility.systemCopyBuffer = strBuild.ToString();
        }

        EditorGUILayout.Space();
    }

    public override void OnInspectorGUI() {
        base.OnInspectorGUI();
        var gameObj = this.target as GameObject;
        if (gameObj != null) {
            var mat = gameObj.transform.localToWorldMatrix;
            DrawMat(mat);
        }
    }
}
