using System;
using UnityEngine;

// 形状
public interface ILightShape {
	void BuildShadowMesh (Light2D light, Mesh shadowMesh);
}
