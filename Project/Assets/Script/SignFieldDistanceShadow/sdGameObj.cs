using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class sdGameObj : MonoBehaviour
{
    private int m_Mat_Pos = 0;

    protected int Material_Pos {
        get {
            if (m_Mat_Pos == 0)
                m_Mat_Pos = Shader.PropertyToID("pos");
            return m_Mat_Pos;
        }
    }

   public virtual bool Attach(Material mat) {
        if (mat == null)
            return false;
        if (!mat.HasProperty(Material_Pos)) {
            Debug.LogErrorFormat("material property pos not found");
            return false;
        }
        Vector4 pos = this.transform.position;
        mat.SetVector(Material_Pos, pos);
        return true;
    }
}
