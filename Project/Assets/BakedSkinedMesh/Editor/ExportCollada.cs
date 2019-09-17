using System;
using System.Text;
using System.Collections.Generic;
using UnityEngine;
#if UNITY_EDITOR
using System.Xml;
#endif

#if UNITY_EDITOR

class ExportCollada {
    private static string ConvertToContentStr(Vector3[] vertexs) {
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
            builder.Append(v.x.ToString()).Append(' ').Append(v.y.ToString()).Append(' ').Append(v.z.ToString());
        }
        if (vertexs.Length > 0)
            builder.Append('\n');
        string ret = builder.ToString();
        return ret;
    }

    private static string ConvertToContentStr(Vector2[] uvs) {
        if (uvs == null || uvs.Length <= 0)
            return string.Empty;
        StringBuilder builder = new StringBuilder();
        if (uvs.Length > 0)
            builder.Append('\n');
        for (int i = 0; i < uvs.Length; ++i) {
            var v = uvs[i];
            if (i > 0) {
                builder.Append('\n');
            }
            builder.Append(v.x.ToString()).Append(' ').Append(v.y.ToString());
        }
        if (uvs.Length > 0)
            builder.Append('\n');
        string ret = builder.ToString();
        return ret;
    }

    // 导出函数
    public static void Export(Vector3[] vertexs, Vector3[] normals, Vector2[] uvs, List<int[]> indexList, string fileName, string name = "UnDefine") {
        XmlDocument doc = new XmlDocument();
        XmlDeclaration decl = doc.CreateXmlDeclaration("1.0", "utf-8", null);
        doc.AppendChild(decl);

        // 1.增加顶点等数据根节点
        var geo = doc.CreateElement("", "library_geometries", "");
        doc.AppendChild(geo);

        XmlNode geoNode = doc.SelectSingleNode("library_geometries");
        var geometry = doc.CreateElement("geometry");
        geometry.SetAttribute("id", "id_" + name);
        geometry.SetAttribute("name", name);
        geoNode.AppendChild(geometry);

        var meshNode = doc.CreateElement("mesh");
        geometry.AppendChild(meshNode);

        /*-------------------------------增加Position--------------------------------*/
        var vertexSource = doc.CreateElement("source");
        vertexSource.SetAttribute("id", "vertexs_position");
        meshNode.AppendChild(vertexSource);

        var possNode = doc.CreateElement("float_array");
        possNode.SetAttribute("id", "position");
        possNode.SetAttribute("count", string.Format("{0:D}", vertexs.Length * 3));
        possNode.InnerText = ConvertToContentStr(vertexs);
        vertexSource.AppendChild(possNode);

        // 增加technique_common
        var tech = doc.CreateElement("technique_common");
        vertexSource.AppendChild(tech);
        /// position
        var posAccessor = doc.CreateElement("accessor");
        posAccessor.SetAttribute("id", "#position");
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
        if (normals != null && normals.Length > 0) {
            vertexSource = doc.CreateElement("source");
            vertexSource.SetAttribute("id", "vertexs_normal");
            meshNode.AppendChild(vertexSource);

            possNode = doc.CreateElement("float_array");
            possNode.SetAttribute("id", "normal");
            possNode.SetAttribute("count", string.Format("{0:D}", normals.Length * 3));
            possNode.InnerText = ConvertToContentStr(normals);
            vertexSource.AppendChild(possNode);

            tech = doc.CreateElement("technique_common");
            vertexSource.AppendChild(tech);

            posAccessor = doc.CreateElement("accessor");
            posAccessor.SetAttribute("id", "#normal");
            posAccessor.SetAttribute("count", vertexs.Length.ToString());
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

        if (uvs != null && uvs.Length > 0) {
            vertexSource = doc.CreateElement("source");
            vertexSource.SetAttribute("id", "vertexs_uv0");
            meshNode.AppendChild(vertexSource);

            possNode = doc.CreateElement("float_array");
            possNode.SetAttribute("id", "uv0");
            possNode.SetAttribute("count", string.Format("{0:D}", uvs.Length * 2));
            possNode.InnerText = ConvertToContentStr(uvs);
            vertexSource.AppendChild(possNode);
        }

        var vertexsNode = doc.CreateElement("vertices");
        vertexsNode.SetAttribute("id", "vertex");
        meshNode.AppendChild(vertexsNode);

        var inputNode = doc.CreateElement("input");
        inputNode.SetAttribute("semantic", "POSITION");
        inputNode.SetAttribute("source", "#vertexs_position");
        vertexsNode.AppendChild(inputNode);

        // 索引
        if (indexList != null && indexList.Count > 0) {
            for (int i = 0; i < indexList.Count; ++i) {
                var indexs = indexList[i];
                if (indexs != null && indexs.Length > 0) {
                    var trianglesNode = doc.CreateElement("triangles");
                    int tCnt = indexs.Length / 3;
                    trianglesNode.SetAttribute("count", tCnt.ToString());
                    meshNode.AppendChild(trianglesNode);

                    var iNode = doc.CreateElement("input");
                    iNode.SetAttribute("semantic", "VERTEX");
                    iNode.SetAttribute("offset", "0");
                    iNode.SetAttribute("source", "#vertexs_position");
                    meshNode.AppendChild(iNode);

                    if (normals != null && normals.Length > 0) {
                        iNode = doc.CreateElement("input");
                        iNode.SetAttribute("semantic", "NORMAL");
                        iNode.SetAttribute("offset", "1");
                        iNode.SetAttribute("source", "#vertexs_normal");
                        meshNode.AppendChild(iNode);
                    }

                    if (uvs != null && uvs.Length > 0) {
                        iNode = doc.CreateElement("input");
                        iNode.SetAttribute("semantic", "TEXCOORD");
                        iNode.SetAttribute("offset", "2");
                        iNode.SetAttribute("source", "#vertexs_uv0");
                        iNode.SetAttribute("set", "0");
                        meshNode.AppendChild(iNode);
                    }
                   
                }
            }
        }

        // 保存到文件
        doc.Save(fileName);
    }

}
#endif
