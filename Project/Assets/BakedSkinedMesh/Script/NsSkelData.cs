using System;
using UnityEngine;

[Serializable]
public struct _BoneData {
    // 根节点为-1
    public int parentBone;
    // 相对于父节点的偏移
    public Vector3 initOffset;
    // 相对于父节点的缩放
    public Vector3 initScale;
    // 相对于父节点的旋转
    public Quaternion initRot;
}

[Serializable]
public class _SkeletonData : ScriptableObject {
    public int m_RootBoneIndex = -1;
    public _BoneData[] m_BoneDatas = null;
    public AnimationClip m_AnimClip = null;
}
