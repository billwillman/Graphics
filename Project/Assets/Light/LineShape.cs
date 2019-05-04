using UnityEngine;
using System.Collections;

public class LineShape : MonoBehaviour, ILightShape {

	public Vector3 p0, p1;

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
		if (!IsVaild) {
			shadowMesh.Clear ();
			return;
		}
	}
}
