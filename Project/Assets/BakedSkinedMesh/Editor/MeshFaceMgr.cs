using System.Collections;
using System.Collections.Generic;
using UnityEngine;

// ByteAddressBuffer里面的数据记得4字节对齐

struct FaceData
{
    // 对应VertexBuffData的实例化ID
    public int vertexBuffInstanceID;
    // 索引
    public int[] vertexIndexes;
}

// 用于传入Compute Shader的顶点对象
struct VertexData
{
    // 模型坐标系坐标(局部坐标)
    Vector3 localPosition;
}

struct VertexBuffData
{
    public int instanceID;
    public VertexData[] datas;
}

public class MeshFaceMgr 
{ 
}
