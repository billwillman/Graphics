﻿using UnityEngine;
using System.Collections.Generic;

[AddComponentMenu("Dynamic Bone/Dynamic Bone")]
public class DynamicBone : MonoBehaviour
{
#if UNITY_5
	[Tooltip("The root of the transform hierarchy to apply physics.")]
#endif
    public Transform m_Root = null;
	
#if UNITY_5
	[Tooltip("Internal physics simulation rate.")]
#endif
    public float m_UpdateRate = 60.0f;
	
    public enum UpdateMode
    {
        Normal,
        AnimatePhysics,
        UnscaledTime
    }
    public UpdateMode m_UpdateMode = UpdateMode.Normal;
	
#if UNITY_5
	[Tooltip("How much the bones slowed down.")]
#endif
    [Range(0, 1)]
    public float m_Damping = 0.1f;
    public AnimationCurve m_DampingDistrib = null;
	
#if UNITY_5
	[Tooltip("How much the force applied to return each bone to original orientation.")]
#endif
    [Range(0, 1)]
    public float m_Elasticity = 0.1f;
    public AnimationCurve m_ElasticityDistrib = null;
	
#if UNITY_5
	[Tooltip("How much bone's original orientation are preserved.")]
#endif
    [Range(0, 1)]
    public float m_Stiffness = 0.1f;
    public AnimationCurve m_StiffnessDistrib = null;
	
#if UNITY_5
	[Tooltip("How much character's position change is ignored in physics simulation.")]
#endif
    [Range(0, 1)]
    public float m_Inert = 0;
    public AnimationCurve m_InertDistrib = null;
	
#if UNITY_5
	[Tooltip("Each bone can be a sphere to collide with colliders. Radius describe sphere's size.")]
#endif
    public float m_Radius = 0;
    public AnimationCurve m_RadiusDistrib = null;

#if UNITY_5
	[Tooltip("If End Length is not zero, an extra bone is generated at the end of transform hierarchy.")]
#endif
    public float m_EndLength = 0;
	
#if UNITY_5
	[Tooltip("If End Offset is not zero, an extra bone is generated at the end of transform hierarchy.")]
#endif
    public Vector3 m_EndOffset = Vector3.zero;
	
#if UNITY_5
	[Tooltip("The force apply to bones. Partial force apply to character's initial pose is cancelled out.")]
#endif
    public Vector3 m_Gravity = Vector3.zero;
	
#if UNITY_5
	[Tooltip("The force apply to bones.")]
#endif
    public Vector3 m_Force = Vector3.zero;
	
#if UNITY_5
	[Tooltip("Collider objects interact with the bones.")]
#endif
    public List<DynamicBoneColliderBase> m_Colliders = null;
	
#if UNITY_5
	[Tooltip("Bones exclude from physics simulation.")]
#endif
    // 真实骨骼排除列表
    public List<Transform> m_Exclusions = null;
	
	
    public enum FreezeAxis
    {
        None, X, Y, Z
    }
#if UNITY_5
	[Tooltip("Constrain bones to move on specified plane.")]
#endif	
    public FreezeAxis m_FreezeAxis = FreezeAxis.None;

#if UNITY_5
	[Tooltip("Disable physics simulation automatically if character is far from camera or player.")]
#endif
    // 是否开启距离检测，超过参照物m_ReferenceObject距离时（如果为NULL，则去当前主相机作为参考系），则不使用动态骨骼功能
    public bool m_DistantDisable = false;
    public Transform m_ReferenceObject = null;
    public float m_DistanceToObject = 20;

    Vector3 m_LocalGravity = Vector3.zero;
    Vector3 m_ObjectMove = Vector3.zero;
    Vector3 m_ObjectPrevPosition = Vector3.zero;
    float m_BoneTotalLength = 0;
    float m_ObjectScale = 1.0f;
    float m_Time = 0;
    float m_Weight = 1.0f;
    bool m_DistantDisabled = false;

    class Particle
    {
        public Transform m_Transform = null;
        public int m_ParentIndex = -1;
        public float m_Damping = 0;
        public float m_Elasticity = 0;
        public float m_Stiffness = 0;
        public float m_Inert = 0;
        public float m_Radius = 0;
        public float m_BoneLength = 0;

        public Vector3 m_Position = Vector3.zero;
        public Vector3 m_PrevPosition = Vector3.zero;
        public Vector3 m_EndOffset = Vector3.zero;
        public Vector3 m_InitLocalPosition = Vector3.zero;
        public Quaternion m_InitLocalRotation = Quaternion.identity;
    }

    List<Particle> m_Particles = new List<Particle>();

    void Start()
    {
        SetupParticles();
    }

    void FixedUpdate()
    {
        if (m_UpdateMode == UpdateMode.AnimatePhysics)
            PreUpdate();
    }

    void Update()
    {
        if (m_UpdateMode != UpdateMode.AnimatePhysics)
            PreUpdate();
    }

    void LateUpdate()
    {
        if (m_DistantDisable)
            CheckDistance();

        if (m_Weight > 0 && !(m_DistantDisable && m_DistantDisabled))
        {
#if UNITY_5
            float dt = m_UpdateMode == UpdateMode.UnscaledTime ? Time.unscaledDeltaTime : Time.deltaTime;
#else
            float dt = Time.deltaTime;
#endif
            UpdateDynamicBones(dt);
        }
    }

    void PreUpdate()
    {
        // m_DistantDisable是否开启距离检测，如果开启距离检测，超过RefernceObject的距离就不再使用虚拟更新
        // 每次在更新前都需要恢复到初始位置，保证后面计算正确
        if (m_Weight > 0 && !(m_DistantDisable && m_DistantDisabled))
            InitTransforms();
    }

    void CheckDistance()
    {
        Transform rt = m_ReferenceObject;
        if (rt == null && Camera.main != null)
            rt = Camera.main.transform;
        if (rt != null)
        {
            float d = (rt.position - transform.position).sqrMagnitude;
            bool disable = d > m_DistanceToObject * m_DistanceToObject;
            if (disable != m_DistantDisabled)
            {
                if (!disable)
                    ResetParticlesPosition();
                m_DistantDisabled = disable;
            }
        }
    }

    void OnEnable()
    {
        ResetParticlesPosition();
    }

    void OnDisable()
    {
        InitTransforms();
    }

    void OnValidate()
    {
        m_UpdateRate = Mathf.Max(m_UpdateRate, 0);
        m_Damping = Mathf.Clamp01(m_Damping);
        m_Elasticity = Mathf.Clamp01(m_Elasticity);
        m_Stiffness = Mathf.Clamp01(m_Stiffness);
        m_Inert = Mathf.Clamp01(m_Inert);
        m_Radius = Mathf.Max(m_Radius, 0);

        if (Application.isEditor && Application.isPlaying)
        {
            InitTransforms();
            SetupParticles();
        }
    }

    void OnDrawGizmosSelected()
    {
        if (!enabled || m_Root == null)
            return;

        if (Application.isEditor && !Application.isPlaying && transform.hasChanged)
        {
            InitTransforms();
            SetupParticles();
        }

        Gizmos.color = Color.white;
        for (int i = 0; i < m_Particles.Count; ++i)
        {
            Particle p = m_Particles[i];
            if (p.m_ParentIndex >= 0)
            {
                Particle p0 = m_Particles[p.m_ParentIndex];
                Gizmos.DrawLine(p.m_Position, p0.m_Position);
            }
            if (p.m_Radius > 0)
                Gizmos.DrawWireSphere(p.m_Position, p.m_Radius * m_ObjectScale);
        }
    }

    public void SetWeight(float w)
    {
        if (m_Weight != w)
        {
            if (w == 0)
                InitTransforms();
            else if (m_Weight == 0)
                ResetParticlesPosition();
            m_Weight = w;
        }
    }

    public float GetWeight()
    {
        return m_Weight;
    }

    void UpdateDynamicBones(float t)
    {
        if (m_Root == null)
            return;

        m_ObjectScale = Mathf.Abs(transform.lossyScale.x);
        m_ObjectMove = transform.position - m_ObjectPrevPosition;
        m_ObjectPrevPosition = transform.position;

        int loop = 1;
        if (m_UpdateRate > 0)
        {
            float dt = 1.0f / m_UpdateRate;
            m_Time += t;
            loop = 0;

            while (m_Time >= dt)
            {
                m_Time -= dt;
                if (++loop >= 3)
                {
                    m_Time = 0;
                    break;
                }
            }
        }

        if (loop > 0)
        {
            for (int i = 0; i < loop; ++i)
            {
                UpdateParticles1();
                UpdateParticles2();
                m_ObjectMove = Vector3.zero;
            }
        }
        else
        {
            SkipUpdateParticles();
        }

        ApplyParticlesToTransforms();
    }

    void SetupParticles()
    {
        m_Particles.Clear();
        if (m_Root == null)
            return;

        m_LocalGravity = m_Root.InverseTransformDirection(m_Gravity);
        m_ObjectScale = Mathf.Abs(transform.lossyScale.x);
        m_ObjectPrevPosition = transform.position;
        m_ObjectMove = Vector3.zero;
        m_BoneTotalLength = 0;
        AppendParticles(m_Root, -1, 0);
        UpdateParameters();
    }

    void AppendParticles(Transform b, int parentIndex, float boneLength)
    {
        // 只有树状结果的叶子粒子才有可能b = null表示结束节点
       // if (b == null)
        //    return;

        Particle p = new Particle();
        p.m_Transform = b;
        // 骨骼父类节点索引
        p.m_ParentIndex = parentIndex;
        if (b != null)
        {
            /*-------------------------- 初始化粒子数据 ---------------------------------*/

            // 世界坐标系位置
            p.m_Position = p.m_PrevPosition = b.position;
            // 局部坐标系位置
            p.m_InitLocalPosition = b.localPosition;
            // 局部坐标系旋转(四元数)
            p.m_InitLocalRotation = b.localRotation;
            /*---------------------------------------------------------------------------*/
        }
        else 	// end bone
        {
            // m_EndLength和m_EndOffset只会其中一个起效，m_EndLength优先

            // 传入TRANS为NULL的粒子目的是？？特殊的末尾节点？？？
            Transform pb = m_Particles[parentIndex].m_Transform;
            if (m_EndLength > 0)
            {
                Transform ppb = pb.parent;
                if (ppb != null) {
                    p.m_EndOffset = pb.InverseTransformPoint((pb.position * 2 - ppb.position)) * m_EndLength;
                    // 为什么不是下面的写法，感觉效果一致啊
                    //p.m_EndOffset = pb.InverseTransformDirection((pb.position - ppb.position).normalized) * m_EndLength;
                } else
                    p.m_EndOffset = new Vector3(m_EndLength, 0, 0);
            }
            else
            {
                // InverseTransformPoint将点从世界坐标系到局部坐标系
                // TransformDirection 将向量从局部坐标系变成世界坐标系，然后加上父节点的的世界坐标位置，然后再反转到父节点的局部坐标系上
                // 所以m_EndOffset其实是相对于父节点坐标系的
                // m_EndOffset是相对于脚本的GAMEOBJECT的位置

                // TransformDirection 将方向从本地坐标转换为世界坐标，这个操作不会受到变换的缩放和位置的影响。返回的向量与direction有同样的长度
                // TransformPoint 将位置从本地坐标转换为世界坐标，受缩放影响。
                // TransformVector：将坐标点从本地坐标转换为世界坐标，不受位置影响但受缩放影响。 

                var worldOffset = transform.TransformDirection(m_EndOffset);

                // 此处m_EndOffset保存的是粒子节点相对于父节点的位置
                p.m_EndOffset = pb.InverseTransformPoint(worldOffset + pb.position);
            }

            // 将相对于父节点的位置转成世界坐标传入m_Position
            p.m_Position = p.m_PrevPosition = pb.TransformPoint(p.m_EndOffset);
        }

        if (parentIndex >= 0)
        {
            // 因为P的参数m_Transform是有可能为NULL，所以要用m_Position，但有parentIndex的肯定不会是NULL粒子
            boneLength += (m_Particles[parentIndex].m_Transform.position - p.m_Position).magnitude;
            // 当前粒子距离根节点的骨骼路径长度
            p.m_BoneLength = boneLength;
            // 整个虚拟骨骼的最大长度（因为骨骼树有个能有多个分支，长度不一样的）
            m_BoneTotalLength = Mathf.Max(m_BoneTotalLength, boneLength);
        }

        // 新增粒子在列表中的索引
        int index = m_Particles.Count;
        // 添加新粒子到列表
        m_Particles.Add(p);

        // 添加这个节点下的其他子类骨骼节点
        if (b != null)
        {
            for (int i = 0; i < b.childCount; ++i)
            {
                bool exclude = false;
                if (m_Exclusions != null)
                {
                    // 检查真实骨骼是否在排除列表中，如果在，则不添加
                    for (int j = 0; j < m_Exclusions.Count; ++j)
                    {
                        Transform e = m_Exclusions[j];
                        if (e == b.GetChild(i))
                        {
                            // 说明真实骨骼被排除了
                            exclude = true;
                            break;
                        }
                    }
                }
                if (!exclude)
                    // 如果此真实骨骼没有被排除则添加到粒子列表里
                    AppendParticles(b.GetChild(i), index, boneLength);
                else if (m_EndLength > 0 || m_EndOffset != Vector3.zero) {
                    // 如果真实骨骼被排除，则添加一个粒子（没有真实骨骼对应的）到列表里
                    AppendParticles(null, index, boneLength);
                }
            }

            // 看是否需要添加一个结束节点粒子
            if (b.childCount == 0 && (m_EndLength > 0 || m_EndOffset != Vector3.zero))
                AppendParticles(null, index, boneLength);
        }
    }

    public void UpdateParameters()
    {
        if (m_Root == null)
            return;

        m_LocalGravity = m_Root.InverseTransformDirection(m_Gravity);

        for (int i = 0; i < m_Particles.Count; ++i)
        {
            Particle p = m_Particles[i];
            p.m_Damping = m_Damping;
            p.m_Elasticity = m_Elasticity;
            p.m_Stiffness = m_Stiffness;
            p.m_Inert = m_Inert;
            p.m_Radius = m_Radius;

            if (m_BoneTotalLength > 0)
            {
                float a = p.m_BoneLength / m_BoneTotalLength;
                if (m_DampingDistrib != null && m_DampingDistrib.keys.Length > 0)
                    p.m_Damping *= m_DampingDistrib.Evaluate(a);
                if (m_ElasticityDistrib != null && m_ElasticityDistrib.keys.Length > 0)
                    p.m_Elasticity *= m_ElasticityDistrib.Evaluate(a);
                if (m_StiffnessDistrib != null && m_StiffnessDistrib.keys.Length > 0)
                    p.m_Stiffness *= m_StiffnessDistrib.Evaluate(a);
                if (m_InertDistrib != null && m_InertDistrib.keys.Length > 0)
                    p.m_Inert *= m_InertDistrib.Evaluate(a);
                if (m_RadiusDistrib != null && m_RadiusDistrib.keys.Length > 0)
                    p.m_Radius *= m_RadiusDistrib.Evaluate(a);
            }

            p.m_Damping = Mathf.Clamp01(p.m_Damping);
            p.m_Elasticity = Mathf.Clamp01(p.m_Elasticity);
            p.m_Stiffness = Mathf.Clamp01(p.m_Stiffness);
            p.m_Inert = Mathf.Clamp01(p.m_Inert);
            p.m_Radius = Mathf.Max(p.m_Radius, 0);
        }
    }

    void InitTransforms()
    {
        for (int i = 0; i < m_Particles.Count; ++i)
        {
            Particle p = m_Particles[i];
            if (p.m_Transform != null)
            {
                p.m_Transform.localPosition = p.m_InitLocalPosition;
                p.m_Transform.localRotation = p.m_InitLocalRotation;
            }
        }
    }

    void ResetParticlesPosition()
    {
        for (int i = 0; i < m_Particles.Count; ++i)
        {
            Particle p = m_Particles[i];
            if (p.m_Transform != null)
            {
                p.m_Position = p.m_PrevPosition = p.m_Transform.position;
            }
            else	// end bone
            {
                Transform pb = m_Particles[p.m_ParentIndex].m_Transform;
                p.m_Position = p.m_PrevPosition = pb.TransformPoint(p.m_EndOffset);
            }
        }
        m_ObjectPrevPosition = transform.position;
    }

    void UpdateParticles1()
    {
        // 世界坐标系重力
        Vector3 force = m_Gravity;
        // 世界坐标系重力的单位向量
        Vector3 fdir = m_Gravity.normalized;
        // 将当前位置的初始化重力方向（在m_Root坐标系，在初始化的时候会将当时的世界坐标系重力转换到m_Root局部坐标系中，保存在m_LocalGravity）转到世界坐标系
        Vector3 rf = m_Root.TransformDirection(m_LocalGravity);
        // 求出局部重力转到世界坐标系后在世界坐标系重力下的投影
        Vector3 pf = fdir * Mathf.Max(Vector3.Dot(rf, fdir), 0);	// project current gravity to rest gravity
        force -= pf;	// remove projected gravity
        // 外部自定义力m_Force和计算后的重力相加 * 一个系数m_ObjectScale
        force = (force + m_Force) * m_ObjectScale;

        for (int i = 0; i < m_Particles.Count; ++i)
        {
            Particle p = m_Particles[i];
            if (p.m_ParentIndex >= 0)
            {
                // verlet integration
                Vector3 v = p.m_Position - p.m_PrevPosition;
                Vector3 rmove = m_ObjectMove * p.m_Inert;
                p.m_PrevPosition = p.m_Position + rmove;
                // v * (1 - p.m_Damping)为阻尼力，阻尼力和速度有关
                p.m_Position += v * (1 - p.m_Damping) + force + rmove;
            }
            else
            {
                p.m_PrevPosition = p.m_Position;
                p.m_Position = p.m_Transform.position;
            }
        }
    }

    void UpdateParticles2()
    {
        Plane movePlane = new Plane();

        for (int i = 1; i < m_Particles.Count; ++i)
        {
            Particle p = m_Particles[i];
            Particle p0 = m_Particles[p.m_ParentIndex];

            float restLen;
            if (p.m_Transform != null)
                restLen = (p0.m_Transform.position - p.m_Transform.position).magnitude;
            else
                restLen = p0.m_Transform.localToWorldMatrix.MultiplyVector(p.m_EndOffset).magnitude;

            // keep shape
            float stiffness = Mathf.Lerp(1.0f, p.m_Stiffness, m_Weight);
            if (stiffness > 0 || p.m_Elasticity > 0)
            {
                Matrix4x4 m0 = p0.m_Transform.localToWorldMatrix;
                m0.SetColumn(3, p0.m_Position);
                Vector3 restPos;
                if (p.m_Transform != null)
                    restPos = m0.MultiplyPoint3x4(p.m_Transform.localPosition);
                else
                    restPos = m0.MultiplyPoint3x4(p.m_EndOffset);

                Vector3 d = restPos - p.m_Position;
                p.m_Position += d * p.m_Elasticity;

                if (stiffness > 0)
                {
                    d = restPos - p.m_Position;
                    float len = d.magnitude;
                    float maxlen = restLen * (1 - stiffness) * 2;
                    if (len > maxlen)
                        p.m_Position += d * ((len - maxlen) / len);
                }
            }

            // collide
            if (m_Colliders != null)
            {
                float particleRadius = p.m_Radius * m_ObjectScale;
                for (int j = 0; j < m_Colliders.Count; ++j)
                {
                    DynamicBoneColliderBase c = m_Colliders[j];
                    if (c != null && c.enabled)
                        c.Collide(ref p.m_Position, particleRadius);
                }
            }

            // freeze axis, project to plane 
            if (m_FreezeAxis != FreezeAxis.None)
            {
                switch (m_FreezeAxis)
                {
                    case FreezeAxis.X:
                        movePlane.SetNormalAndPosition(p0.m_Transform.right, p0.m_Position);
                        break;
                    case FreezeAxis.Y:
                        movePlane.SetNormalAndPosition(p0.m_Transform.up, p0.m_Position);
                        break;
                    case FreezeAxis.Z:
                        movePlane.SetNormalAndPosition(p0.m_Transform.forward, p0.m_Position);
                        break;
                }
                p.m_Position -= movePlane.normal * movePlane.GetDistanceToPoint(p.m_Position);
            }

            // keep length
            Vector3 dd = p0.m_Position - p.m_Position;
            float leng = dd.magnitude;
            if (leng > 0)
                p.m_Position += dd * ((leng - restLen) / leng);
        }
    }

    // only update stiffness and keep bone length
    void SkipUpdateParticles()
    {
        for (int i = 0; i < m_Particles.Count; ++i)
        {
            Particle p = m_Particles[i];
            if (p.m_ParentIndex >= 0)
            {
                p.m_PrevPosition += m_ObjectMove;
                p.m_Position += m_ObjectMove;

                Particle p0 = m_Particles[p.m_ParentIndex];

                float restLen;
                if (p.m_Transform != null)
                    restLen = (p0.m_Transform.position - p.m_Transform.position).magnitude;
                else
                    restLen = p0.m_Transform.localToWorldMatrix.MultiplyVector(p.m_EndOffset).magnitude;

                // keep shape
                float stiffness = Mathf.Lerp(1.0f, p.m_Stiffness, m_Weight);
                if (stiffness > 0)
                {
                    Matrix4x4 m0 = p0.m_Transform.localToWorldMatrix;
                    m0.SetColumn(3, p0.m_Position);
                    Vector3 restPos;
                    if (p.m_Transform != null)
                        restPos = m0.MultiplyPoint3x4(p.m_Transform.localPosition);
                    else
                        restPos = m0.MultiplyPoint3x4(p.m_EndOffset);

                    Vector3 d = restPos - p.m_Position;
                    float len = d.magnitude;
                    float maxlen = restLen * (1 - stiffness) * 2;
                    if (len > maxlen)
                        p.m_Position += d * ((len - maxlen) / len);
                }

                // keep length
                Vector3 dd = p0.m_Position - p.m_Position;
                float leng = dd.magnitude;
                if (leng > 0)
                    p.m_Position += dd * ((leng - restLen) / leng);
            }
            else
            {
                p.m_PrevPosition = p.m_Position;
                p.m_Position = p.m_Transform.position;
            }
        }
    }

    static Vector3 MirrorVector(Vector3 v, Vector3 axis)
    {
        return v - axis * (Vector3.Dot(v, axis) * 2);
    }

    void ApplyParticlesToTransforms()
    {
#if !UNITY_5_4_OR_NEWER	
        // detect negative scale
        Vector3 ax = Vector3.right;
        Vector3 ay = Vector3.up;
        Vector3 az = Vector3.forward;
        bool nx = false, ny = false, nz = false;

        Vector3 loosyScale = transform.lossyScale;
        if (loosyScale.x < 0 || loosyScale.y < 0 || loosyScale.z < 0)
        {
            Transform mirrorObject = transform;
            do
            {
                Vector3 ls = mirrorObject.localScale;
                nx = ls.x < 0;
                if (nx)
                    ax = mirrorObject.right;
                ny = ls.y < 0;
                if (ny)
                    ay = mirrorObject.up;
                nz = ls.z < 0;
                if (nz)
                    az = mirrorObject.forward;
                if (nx || ny || nz)
                    break;

                mirrorObject = mirrorObject.parent;
            }
            while (mirrorObject != null);
        }
#endif

        for (int i = 1; i < m_Particles.Count; ++i)
        {
            Particle p = m_Particles[i];
            Particle p0 = m_Particles[p.m_ParentIndex];

            if (p0.m_Transform.childCount <= 1)		// do not modify bone orientation if has more then one child
            {
                Vector3 v;
                if (p.m_Transform != null)
                    v = p.m_Transform.localPosition;
                else
                    v = p.m_EndOffset;
                Vector3 v2 = p.m_Position - p0.m_Position;
#if !UNITY_5_4_OR_NEWER					
                if (nx)
                    v2 = MirrorVector(v2, ax);
                if (ny)
                    v2 = MirrorVector(v2, ay);
                if (nz)
                    v2 = MirrorVector(v2, az);
#endif					
                Quaternion rot = Quaternion.FromToRotation(p0.m_Transform.TransformDirection(v), v2);
                p0.m_Transform.rotation = rot * p0.m_Transform.rotation;
            }

            if (p.m_Transform != null)
                p.m_Transform.position = p.m_Position;
        }
    }
}
