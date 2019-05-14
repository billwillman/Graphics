using UnityEngine;
using System.Collections;

public class LineShape : MonoBehaviour, ILightShape {

	public Vector3 p0, p1;
    public BoxCollider Bind = null;

    void Awake() {
        if (Bind != null) {
            var b = Bind.bounds;
            float x = (b.max.x - b.min.x) / 2f;
            float z = (b.max.z - b.min.z) / 2f;
            Vector3 center = b.center;
            center.y = 0;
            Vector3 dir = new Vector3(x, 0, z);
            p0 = center - dir;
            p1 = center + dir;
        }
    }

	public bool IsVaild
	{
		get {
			Vector3 delta = p1 - p0;
			return ((Mathf.Abs (delta.x) > float.Epsilon) || (Mathf.Abs(delta.y) > float.Epsilon) || (Mathf.Abs(delta.z) > float.Epsilon));
		}
	}

	public void BuildShadowMesh (Light2D light, Mesh shadowMesh)
	{
		if ((shadowMesh == null) || (light == null))
			return;

        shadowMesh.Clear();
        if (!IsVaild) {
			return;
		}


	}
}
