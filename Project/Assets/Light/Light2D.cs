using UnityEngine;
using System.Collections;

public enum AttenuationType
{
	// 线性
	line = 0
}

public class Light2D : MonoBehaviour {

	// 半径
	public float Radius = 1f;
	// 颜色
	public Color LightColor = Color.white;
	// 衰减
	public float Attenuation = 1f;
	// 衰减方式
	public AttenuationType AttenType = AttenuationType.line;
}
