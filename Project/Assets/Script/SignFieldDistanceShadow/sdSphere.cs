using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class sdSphere : sdGameObj {
    public float m_Radius = 1f;
    private int m_Mat_Radius = 0;

    protected int Material_Radius {
        get {
            if (m_Mat_Radius == 0) {
                m_Mat_Radius = Shader.PropertyToID("radius");
            }
            return m_Mat_Radius;
        }
    }

    public override bool Attach(Material mat) {
        bool ret = base.Attach(mat);
        if (!ret)
            return ret;
        ret = mat.HasProperty(Material_Radius);
        if (!ret)
            return ret;
        mat.SetFloat(Material_Radius, m_Radius);
        return true;
    }
}
