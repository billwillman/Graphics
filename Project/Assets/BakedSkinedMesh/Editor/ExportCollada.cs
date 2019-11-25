using System;
using System.Text;
using System.Threading;
using System.Collections.Generic;
#if UNITY_EDITOR
using System.Xml;
using UnityEditor;
#endif
using UnityEngine;

#if UNITY_EDITOR

class ExportCollada {
    private static string ConvertToContentStr(Vector3[] vertexs, float scale = 1.0f) {
        if (vertexs == null || vertexs.Length <= 0)
            return string.Empty;
        StringBuilder builder = new StringBuilder();
        if (vertexs.Length > 0)
            builder.Append('\n');
        for (int i = 0; i < vertexs.Length; ++i) {
            var v = vertexs[i];
            if (i > 0) {
                builder.Append('\n');
            }
            builder.Append((v.x * scale).ToString()).Append(' ').Append((v.y * scale).ToString()).Append(' ').Append((v.z * scale).ToString());
        }
        if (vertexs.Length > 0)
            builder.Append('\n');
        string ret = builder.ToString();
        return ret;
    }

    private static string ConvertToContentStr(List<BoneWeight> lst, bool isBoneIndex) {
        if (lst == null || lst.Count <= 0)
            return string.Empty;
        StringBuilder builder = new StringBuilder();
        builder.Append('\n');
        for (int i = 0; i < lst.Count; ++i) {
            var weight = lst[i];
            if (i > 0) {
                builder.Append('\n');
            }
            if (isBoneIndex) {
                builder.Append(weight.boneIndex0).Append(' ').Append(weight.boneIndex1).Append(' ').Append(weight.boneIndex2).Append(' ').Append(weight.boneIndex3);
            } else {
                builder.Append(weight.weight0).Append(' ').Append(weight.weight1).Append(' ').Append(weight.weight2).Append(' ').Append(weight.weight3);
            }
        }

        builder.Append('\n');
        string ret = builder.ToString();
        return ret;
    }

    private static string ConvertToContentStr(Vector2[] uvs) {
        if (uvs == null || uvs.Length <= 0)
            return string.Empty;
        StringBuilder builder = new StringBuilder();
        builder.Append('\n');

        for (int i = 0; i < uvs.Length; ++i) {
            var v = uvs[i];
            if (i > 0) {
                builder.Append('\n');
            }
            builder.Append(v.x.ToString()).Append(' ').Append(v.y.ToString());
        }
        builder.Append('\n');
        string ret = builder.ToString();
        return ret;
    }

    private static string ConvertToContentStr(int[] idxs, int idxCnt) {
        if (idxs == null || idxs.Length <= 0)
            return string.Empty;
        StringBuilder builder = new StringBuilder();
        builder.Append('\n');
        for (int i = 0; i < idxs.Length; ++i) {
            var v = idxs[i];
            if (i%3 > 0) {
                builder.Append(' ');
            } else if ( (i % 3 == 0) && i > 0) {
                builder.Append('\n');
            }
            for (int j = 0; j < idxCnt; ++j) {
                if (j > 0)
                    builder.Append(' ');
                builder.Append(v);
            }
        }
        builder.Append('\n');
        string ret = builder.ToString();
        return ret;
    }

    private static string ConvertToContentStr(Matrix4x4 mat) {
        StringBuilder builder = new StringBuilder();
        for (int row = 0; row < 4; ++row) {
            for (int col = 0; col < 4; ++col) {
               float v = mat[row, col];
                if (builder.Length > 0)
                    builder.Append(' ');
                builder.Append(v.ToString());
            }
        }
        string ret = builder.ToString();
        return ret;
    }

    public static int m_LastExportBoneUVStart = -1;

    // isBoneWeightToUVs 是否将骨骼数据写入UV
    private static void AppendToRootNode(Mesh mesh, SkinnedMeshRenderer skl, XmlDocument doc, XmlElement root, string name, bool isBoneWeightToUVs = true) {
        m_LastExportBoneUVStart = -1;
        if (mesh == null || root == null || doc == null)
            return;
        List<Vector3> vec3List = new List<Vector3>();
#if UNITY_5_3
		vec3List.AddRange(mesh.vertices);
#else
        mesh.GetVertices(vec3List);
#endif
        if (vec3List.Count <= 0)
            return;

        var geometry = doc.CreateElement("geometry");
        geometry.SetAttribute("id", "id-" + name);
        geometry.SetAttribute("name", name);
        root.AppendChild(geometry);

        var meshNode = doc.CreateElement("mesh");
        geometry.AppendChild(meshNode);

        Vector3[] vertexs = vec3List.ToArray();

        /*-------------------------------增加Position--------------------------------*/
        var vertexSource = doc.CreateElement("source");
        vertexSource.SetAttribute("id", string.Format("{0}-vertexs_position", name));
        meshNode.AppendChild(vertexSource);

        var possNode = doc.CreateElement("float_array");
        possNode.SetAttribute("id", string.Format("{0}-position", name));
        possNode.SetAttribute("count", string.Format("{0:D}", vertexs.Length * 3));
        possNode.InnerText = ConvertToContentStr(vertexs, 1f);
        vertexSource.AppendChild(possNode);

        // 增加technique_common
        var tech = doc.CreateElement("technique_common");
        vertexSource.AppendChild(tech);
        /// position
        var posAccessor = doc.CreateElement("accessor");
        posAccessor.SetAttribute("id", string.Format("#{0}-position", name));
        posAccessor.SetAttribute("count", vertexs.Length.ToString());
        posAccessor.SetAttribute("stride", "3");
        tech.AppendChild(posAccessor);

        var paramNode = doc.CreateElement("param");
        paramNode.SetAttribute("name", "X");
        paramNode.SetAttribute("type", "float");
        posAccessor.AppendChild(paramNode);

        paramNode = doc.CreateElement("param");
        paramNode.SetAttribute("name", "Y");
        paramNode.SetAttribute("type", "float");
        posAccessor.AppendChild(paramNode);

        paramNode = doc.CreateElement("param");
        paramNode.SetAttribute("name", "Z");
        paramNode.SetAttribute("type", "float");
        posAccessor.AppendChild(paramNode);

        /*---------------------------增加Normal---------------------------------*/
        vec3List.Clear();
#if UNITY_5_3
		vec3List.AddRange(mesh.normals);
#else
        mesh.GetNormals(vec3List);
#endif
        Vector3[] normals = vec3List.ToArray();
      //  normals = null;
        if (normals != null && normals.Length > 0) {
            vertexSource = doc.CreateElement("source");
            vertexSource.SetAttribute("id", string.Format("{0}-vertexs_normal", name));
            meshNode.AppendChild(vertexSource);

            possNode = doc.CreateElement("float_array");
            possNode.SetAttribute("id", string.Format("{0}-normal", name));
            possNode.SetAttribute("count", string.Format("{0:D}", normals.Length * 3));
            possNode.InnerText = ConvertToContentStr(normals);
            vertexSource.AppendChild(possNode);

            tech = doc.CreateElement("technique_common");
            vertexSource.AppendChild(tech);

            posAccessor = doc.CreateElement("accessor");
            posAccessor.SetAttribute("id", string.Format("#{0}-normal", name));
            posAccessor.SetAttribute("count", normals.Length.ToString());
            posAccessor.SetAttribute("stride", "3");
            tech.AppendChild(posAccessor);

            paramNode = doc.CreateElement("param");
            paramNode.SetAttribute("name", "X");
            paramNode.SetAttribute("type", "float");
            posAccessor.AppendChild(paramNode);

            paramNode = doc.CreateElement("param");
            paramNode.SetAttribute("name", "Y");
            paramNode.SetAttribute("type", "float");
            posAccessor.AppendChild(paramNode);

            paramNode = doc.CreateElement("param");
            paramNode.SetAttribute("name", "Z");
            paramNode.SetAttribute("type", "float");
            posAccessor.AppendChild(paramNode);
        }

        List<Vector2[]> uvsList = new List<Vector2[]>();
        List<Vector2> vec2List = new List<Vector2>();

        int usedTexcordId = -1;

        for (int i = 0; i < 8; ++i) {
            vec2List.Clear();
            mesh.GetUVs(i, vec2List);
            // 发现为空则退出
            if (vec2List.Count <= 0)
                break;
          
            Vector2[] uvs = vec2List.ToArray();
            // uvs = null;
            if (uvs != null && uvs.Length > 0) {
                ++usedTexcordId;
                uvsList.Add(uvs);
                vertexSource = doc.CreateElement("source");
                vertexSource.SetAttribute("id", string.Format("{0}-vertexs_uv{1}", name, i));
                meshNode.AppendChild(vertexSource);

                possNode = doc.CreateElement("float_array");
                possNode.SetAttribute("id", string.Format("uv{0}", i));
                possNode.SetAttribute("count", string.Format("{0:D}", uvs.Length * 2));
                possNode.InnerText = ConvertToContentStr(uvs);
                vertexSource.AppendChild(possNode);

                tech = doc.CreateElement("technique_common");
                vertexSource.AppendChild(tech);

                posAccessor = doc.CreateElement("accessor");
                posAccessor.SetAttribute("id", string.Format("#{0}-uv{1}", name, i));
                posAccessor.SetAttribute("count", uvs.Length.ToString());
                posAccessor.SetAttribute("stride", "2");
                tech.AppendChild(posAccessor);

                paramNode = doc.CreateElement("param");
                paramNode.SetAttribute("name", "S");
                paramNode.SetAttribute("type", "float");
                posAccessor.AppendChild(paramNode);

                paramNode = doc.CreateElement("param");
                paramNode.SetAttribute("name", "T");
                paramNode.SetAttribute("type", "float");
                posAccessor.AppendChild(paramNode);
            }
        }

        List<BoneWeight> meshBoneWeightList = new List<BoneWeight>();
#if UNITY_5_3
		meshBoneWeightList.AddRange(mesh.boneWeights);
#else
        mesh.GetBoneWeights(meshBoneWeightList);
#endif
        if (meshBoneWeightList.Count > 0) {
            if (isBoneWeightToUVs && (usedTexcordId + 2 < 8)) {
                // 将骨骼索引信息接入UV
                vertexSource = doc.CreateElement("source");
                vertexSource.SetAttribute("id", string.Format("{0}-vertexs_boneIdx_uv{1}", name, ++usedTexcordId));
                meshNode.AppendChild(vertexSource);

                m_LastExportBoneUVStart = usedTexcordId;

                possNode = doc.CreateElement("float_array");
                possNode.SetAttribute("id", string.Format("boneIdx_uv{0}", usedTexcordId));
                possNode.SetAttribute("count", string.Format("{0:D}", meshBoneWeightList.Count * 4));
                possNode.InnerText = ConvertToContentStr(meshBoneWeightList, true);
                vertexSource.AppendChild(possNode);

                tech = doc.CreateElement("technique_common");
                vertexSource.AppendChild(tech);

                posAccessor = doc.CreateElement("accessor");
                posAccessor.SetAttribute("id", string.Format("#{0}-boneIdx_uv{1}", name, usedTexcordId));
                posAccessor.SetAttribute("count", meshBoneWeightList.Count.ToString());
                posAccessor.SetAttribute("stride", "4");
                tech.AppendChild(posAccessor);

                paramNode = doc.CreateElement("param");
                paramNode.SetAttribute("name", "BoneIndex1");
                paramNode.SetAttribute("type", "int");
                posAccessor.AppendChild(paramNode);

                paramNode = doc.CreateElement("param");
                paramNode.SetAttribute("name", "BoneIndex2");
                paramNode.SetAttribute("type", "int");
                posAccessor.AppendChild(paramNode);

                paramNode = doc.CreateElement("param");
                paramNode.SetAttribute("name", "BoneIndex3");
                paramNode.SetAttribute("type", "int");
                posAccessor.AppendChild(paramNode);

                paramNode = doc.CreateElement("param");
                paramNode.SetAttribute("name", "BoneIndex4");
                paramNode.SetAttribute("type", "int");
                posAccessor.AppendChild(paramNode);

                // 将骨骼权重信息写入UV
                vertexSource = doc.CreateElement("source");
                vertexSource.SetAttribute("id", string.Format("{0}-vertexs_boneWeight_uv{1}", name, ++usedTexcordId));
                meshNode.AppendChild(vertexSource);

                possNode = doc.CreateElement("float_array");
                possNode.SetAttribute("id", string.Format("boneWeight_uv{0}", usedTexcordId));
                possNode.SetAttribute("count", string.Format("{0:D}", meshBoneWeightList.Count * 4));
                possNode.InnerText = ConvertToContentStr(meshBoneWeightList, false);
                vertexSource.AppendChild(possNode);

                tech = doc.CreateElement("technique_common");
                vertexSource.AppendChild(tech);

                posAccessor = doc.CreateElement("accessor");
                posAccessor.SetAttribute("id", string.Format("#{0}-boneWeight_uv{1}", name, usedTexcordId));
                posAccessor.SetAttribute("count", meshBoneWeightList.Count.ToString());
                posAccessor.SetAttribute("stride", "4");
                tech.AppendChild(posAccessor);

                paramNode = doc.CreateElement("param");
                paramNode.SetAttribute("name", "BoneWeight1");
                paramNode.SetAttribute("type", "float");
                posAccessor.AppendChild(paramNode);

                paramNode = doc.CreateElement("param");
                paramNode.SetAttribute("name", "BoneWeight2");
                paramNode.SetAttribute("type", "float");
                posAccessor.AppendChild(paramNode);

                paramNode = doc.CreateElement("param");
                paramNode.SetAttribute("name", "BoneWeight3");
                paramNode.SetAttribute("type", "float");
                posAccessor.AppendChild(paramNode);

                paramNode = doc.CreateElement("param");
                paramNode.SetAttribute("name", "BoneWeight4");
                paramNode.SetAttribute("type", "float");
                posAccessor.AppendChild(paramNode);
            } else {
                Debug.LogError("TextureCoord Num > 8, Bone not support");
            }
        }

        var vertexsNode = doc.CreateElement("vertices");
        vertexsNode.SetAttribute("id", string.Format("{0}-vertex", name));
        meshNode.AppendChild(vertexsNode);

        var inputNode = doc.CreateElement("input");
        inputNode.SetAttribute("semantic", "POSITION");
        inputNode.SetAttribute("source", string.Format("#{0}-vertexs_position", name));
        vertexsNode.AppendChild(inputNode);

        List<int[]> indexList = new List<int[]>();
        for (int i = 0; i < mesh.subMeshCount; ++i) {
            var idxs = mesh.GetTriangles(i);
            if (idxs != null && idxs.Length > 0)
                indexList.Add(idxs);
        }

        // 索引
        if (indexList != null && indexList.Count > 0) {
            for (int i = 0; i < indexList.Count; ++i) {
                var indexs = indexList[i];
                if (indexs != null && indexs.Length > 0) {
                    var trianglesNode = doc.CreateElement("triangles");
                    int tCnt = indexs.Length / 3;
                    trianglesNode.SetAttribute("count", tCnt.ToString());
                    meshNode.AppendChild(trianglesNode);

                    int appCnt = 1;
                    var iNode = doc.CreateElement("input");
                    iNode.SetAttribute("semantic", "VERTEX");
                    iNode.SetAttribute("offset", "0");
					iNode.SetAttribute("source", string.Format("#{0}-vertex", name));
                    trianglesNode.AppendChild(iNode);

                    if (normals != null && normals.Length > 0) {
                        iNode = doc.CreateElement("input");
                        iNode.SetAttribute("semantic", "NORMAL");
                        iNode.SetAttribute("offset", "1");
                        iNode.SetAttribute("source", string.Format("#{0}-vertexs_normal", name));
                        trianglesNode.AppendChild(iNode);
                        ++appCnt;
                    }

                    usedTexcordId = -1;
                    for (int j = 0; j < uvsList.Count; ++j) {
                        var uvs = uvsList[j];
                        if (uvs != null && uvs.Length > 0) {
                            iNode = doc.CreateElement("input");
                            iNode.SetAttribute("semantic", "TEXCOORD");
                            iNode.SetAttribute("offset", (2 + (++usedTexcordId)).ToString());
                            iNode.SetAttribute("source", string.Format("#{0}-vertexs_uv{1}", name, j));
                            iNode.SetAttribute("set", (1 + usedTexcordId).ToString());
                            //iNode.SetAttribute("set", "0");
                            trianglesNode.AppendChild(iNode);
                            ++appCnt;
                        }
                    }

                    if (isBoneWeightToUVs && meshBoneWeightList.Count > 0) {
                        iNode = doc.CreateElement("input");
                        iNode.SetAttribute("semantic", "TEXCOORD");
                        iNode.SetAttribute("offset", (2 + (++usedTexcordId)).ToString());
                        iNode.SetAttribute("source", string.Format("#{0}-vertexs_boneIdx_uv{1}", name, usedTexcordId));
                        iNode.SetAttribute("set", (1 + usedTexcordId).ToString());
                        trianglesNode.AppendChild(iNode);
                        ++appCnt;

                        iNode = doc.CreateElement("input");
                        iNode.SetAttribute("semantic", "TEXCOORD");
                        iNode.SetAttribute("offset", (2 + (++usedTexcordId)).ToString());
                        iNode.SetAttribute("source", string.Format("#{0}-vertexs_boneWeight_uv{1}", name, usedTexcordId));
                        iNode.SetAttribute("set", (1 + usedTexcordId).ToString());
                        trianglesNode.AppendChild(iNode);
                        ++appCnt;
                    }

                    var pNode = doc.CreateElement("p");
                    pNode.InnerText = ConvertToContentStr(indexs, appCnt);
                    trianglesNode.AppendChild(pNode);


                }
            }
        }

    }

    private static void EpxortVisualSceneNode(Mesh mesh, Renderer skl, XmlDocument doc, XmlElement root, string name, string url) {
        var node = doc.CreateElement("node");
        node.SetAttribute("name", name);
        node.SetAttribute("id", name);
        node.SetAttribute("sid", name);
        root.AppendChild(node);

        var trans = skl.transform;
        var offset = trans.localPosition;
        var rot = trans.localRotation;
        var scale = trans.localScale;

         Matrix4x4 mat = Matrix4x4.TRS(offset, rot, scale);
        //Matrix4x4 mat = Matrix4x4.identity;
        var matrixNode = doc.CreateElement("matrix");
        matrixNode.SetAttribute("sid", "matrix");
        matrixNode.InnerText = ConvertToContentStr(mat);
        node.AppendChild(matrixNode);

        var instanceNode = doc.CreateElement("instance_geometry");
        instanceNode.SetAttribute("url", url);
        node.AppendChild(instanceNode);

		var extraNode = doc.CreateElement("extra");
		node.AppendChild(extraNode);

		var tNode = doc.CreateElement("technique");
		tNode.SetAttribute("profile", "FCOLLADA");
		extraNode.AppendChild(tNode);

		var visNode = doc.CreateElement("visibility");
		visNode.InnerText = "1.000000";
		tNode.AppendChild(visNode);
    }

    private static void EpxortVisualSceneNodes(List<Mesh> meshes, Renderer[] skls, XmlDocument doc, XmlElement root, string name) {
        for (int i = 0; i < meshes.Count; ++i) {
            var mesh = meshes[i];
            string n = string.Format("node-{0}-{1:D}", name, i);
            string url = string.Format("#id-{0}-{1:D}", name, i);
            EpxortVisualSceneNode(mesh, skls[i], doc, root, n, url);
        }
    }

    public static void ExportToScene(List<Mesh> meshes, SkinnedMeshRenderer[] skls, string name = "Noname") {
        GameObject rootObj = new GameObject("name");
        for (int i = 0; i < skls.Length; ++i) {
            string n = string.Format("id-{0}-{1:D}", name, i);
            MeshRenderer renderer = new GameObject(n, typeof(MeshRenderer)).GetComponent<MeshRenderer>();
            renderer.transform.SetParent(rootObj.transform, false);
            renderer.transform.localPosition = skls[i].transform.localPosition;
            renderer.transform.localScale = skls[i].transform.localScale;
            renderer.transform.localRotation = skls[i].transform.localRotation;
            MeshFilter filter = renderer.gameObject.AddComponent<MeshFilter>();
            filter.sharedMesh = GameObject.Instantiate(meshes[i]);
        }
    }

    private static void ExportMeshAsset(SkinnedMeshRenderer skl, string fileName)
    {
        if (skl == null || string.IsNullOrEmpty(fileName))
            return;
#if UNITY_EDITOR
        var mesh = skl.sharedMesh;
        if (mesh == null)
            return;
        _VertexsData vertexsData = ScriptableObject.CreateInstance<_VertexsData>();
        vertexsData.Init(mesh);
        AssetDatabase.CreateAsset(vertexsData, fileName);
#endif
    }

    // 自定義Asset
    private static void ExportSklAsset(SkinnedMeshRenderer skl, string fileName) {
        if (skl == null)
            return;
        var bones = skl.bones;
        if (bones != null && bones.Length > 0) {
#if UNITY_EDITOR
            var mesh = skl.sharedMesh;
            if (mesh == null)
                return;
            var bindposes = mesh.bindposes;
            if (bindposes == null || bindposes.Length <= 0)
                return;
            // 先遍历InstanceID对应INDEX
            Dictionary<int, int> boneInstanceIDToIndexMap = new Dictionary<int, int>();
            for (int i = 0; i < bones.Length; ++i) {
                var bone = bones[i];
                boneInstanceIDToIndexMap[bone.GetInstanceID()] = i;
            }
            
            _SkeletonData sklData = ScriptableObject.CreateInstance<_SkeletonData>();
            sklData.m_BoneDatas = new _BoneData[bones.Length];
            for (int i = 0; i < bones.Length; ++i) {
                var bone = bones[i];
                _BoneData boneData = new _BoneData();
                boneData.initOffset = bone.localPosition;
                boneData.initScale = bone.localScale;
                boneData.initRot = bone.localRotation;
                boneData.bindPose = mesh.bindposes[i];
                boneData.name = bone.name;
                if (bone.parent == null) {
                    boneData.parentBone = -1;
                    sklData.m_RootBoneIndex = i;
                } else {
                    int parentBoneIdx;
                    if (!boneInstanceIDToIndexMap.TryGetValue(bone.parent.GetInstanceID(), out parentBoneIdx)) {
                        parentBoneIdx = -2;
                        sklData.m_RootBoneIndex = i;
                        Debug.LogErrorFormat("bone: {0} parent: {1} not found", bone.name, bone.parent.name);
                    }
                    boneData.parentBone = parentBoneIdx;
                }
                sklData.m_BoneDatas[i] = boneData;
                sklData.m_StartBoneUV = m_LastExportBoneUVStart;
            }

            for (int i = 0; i < sklData.m_BoneDatas.Length; ++i) {
                sklData.m_BoneDatas[i].InitGlobalMatrix(sklData);
            }

            if (skl.sharedMesh != null && skl.sharedMesh.isReadable) {
                if (skl.sharedMesh.vertexCount > 0) {
                    var boneWeights = skl.sharedMesh.boneWeights;
                    if (boneWeights != null && boneWeights.Length > 0) {
                        sklData.m_VertexBoneData = new _VertexBoneData[boneWeights.Length];
                        for (int i = 0; i < boneWeights.Length; ++i) {
                            var vBoneData = new _VertexBoneData();
                            vBoneData.boneIndex1 = boneWeights[i].boneIndex0;
                            vBoneData.boneIndex2 = boneWeights[i].boneIndex1;
                            vBoneData.boneIndex3 = boneWeights[i].boneIndex2;
                            vBoneData.boneIndex4 = boneWeights[i].boneIndex3;
                            vBoneData.boneWeight1 = boneWeights[i].weight0;
                            vBoneData.boneWeight2 = boneWeights[i].weight1;
                            vBoneData.boneWeight3 = boneWeights[i].weight2;
                            vBoneData.boneWeight4 = boneWeights[i].weight3;

                            sklData.m_VertexBoneData[i] = vBoneData;
                        }
                    }
                }
            } else
                Debug.LogError("SkinedMesh is not isReadable~! so _vertexBoneData not export");

            AssetDatabase.CreateAsset(sklData, fileName);
#endif
        }
    }

    private static void ExportBoneLocalToWorldMatrix(SkinnedMeshRenderer skl, string fileName) {

    }

    public static void ExportSklsToAsset(Renderer[] skls, string fileName)
    {
        if (skls == null || skls.Length <= 0 || string.IsNullOrEmpty(fileName))
            return;

        // 到處骨骼Skinned信息
        string noExtFileName = System.IO.Path.GetFileNameWithoutExtension(fileName);
        string filePathName = System.IO.Path.GetDirectoryName(fileName);
        noExtFileName = string.Format("{0}/{1}", filePathName, noExtFileName);
        noExtFileName = noExtFileName.Replace('\\', '/');
        int startPos = noExtFileName.IndexOf("Assets/", StringComparison.CurrentCultureIgnoreCase);
        if (startPos >= 0)
        {
            if (startPos > 0)
                noExtFileName = noExtFileName.Substring(startPos);
            if (skls != null && (skls.Length > 0))
            {
                for (int i = 0; i < skls.Length; ++i)
                {
                    string sklFileName = string.Format("{0}_{1:D}.asset", noExtFileName, i);
                    var skl = skls[i] as SkinnedMeshRenderer;
                    ExportSklAsset(skl, sklFileName);
                    string vecFileName = string.Format("{0}_vertex_{1:D}.asset", noExtFileName, i);
                    ExportMeshAsset(skl, vecFileName);
                    string localToWorldMatrixFileName = string.Format("{0}_LToW_Mat_{1:D}.asset", noExtFileName, i);
                    ExportBoneLocalToWorldMatrix(skl, localToWorldMatrixFileName);
                }

                AssetDatabase.Refresh();
            }
        }
        else
        {
            Debug.LogError("Skleton only Save Assets/ Path");
        }
    }

    public static void Export(List<Mesh> meshes, Renderer[] skls, string fileName, string name = "Noname") {
        if (meshes == null || meshes.Count <= 0 || skls == null || meshes.Count != skls.Length)
            return;

        // ----增加COLLADA説明
        XmlDocument doc = new XmlDocument();
        XmlDeclaration decl = doc.CreateXmlDeclaration("1.0", "utf-8", null);
        doc.AppendChild(decl);

        var colladaNode = doc.CreateElement("COLLADA");
        colladaNode.SetAttribute("xmlns", "http://www.collada.org/2005/11/COLLADASchema");
        doc.AppendChild(colladaNode);
        //-----

        // 增加library_geometries
        var geo = doc.CreateElement("", "library_geometries", "");
        colladaNode.AppendChild(geo);

        for (int i = 0; i < meshes.Count; ++i) {
            var mesh = meshes[i];
            string n = string.Format("{0}-{1:D}", name, i);
            AppendToRootNode(mesh, skls[i] as SkinnedMeshRenderer, doc, geo, n);
        }

        var libraryScene = doc.CreateElement("library_visual_scenes");
        colladaNode.AppendChild(libraryScene);

        var sceneNode = doc.CreateElement("visual_scene");
        sceneNode.SetAttribute("id", "file");
        sceneNode.SetAttribute("name", "file");
        libraryScene.AppendChild(sceneNode);

        // 导出NODE到visual_scene
        EpxortVisualSceneNodes(meshes, skls, doc, sceneNode, name);

        var sNode = doc.CreateElement("scene");
        colladaNode.AppendChild(sNode);

        var instanceSceneNode = doc.CreateElement("instance_visual_scene");
        instanceSceneNode.SetAttribute("url", "#file");
        sNode.AppendChild(instanceSceneNode);

        // 保存到文件
        doc.Save(fileName);

       
    }

}
#endif
