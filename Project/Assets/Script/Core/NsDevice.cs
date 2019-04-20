﻿using UnityEngine;
using System.Collections;

[RequireComponent(typeof(Renderer))]
public class NsDevice: MonoBehaviour
{
	//private NsSurface m_BackSurface = null;
	private ComputeShader m_DeviceShader;
	private int m_ClearKernal = -1;

	public int BackSurfaceWidth = 1024;
	public int BackSurfaceHeight = 768;

	// 前缓冲
	private NsSurface m_FrontSurface = null;

	public void Bind(Renderer render)
	{
		if (m_FrontSurface != null) {
			m_FrontSurface.Attach (render);
		}
	}

	private void CreateSurface()
	{
		m_FrontSurface = NsSurface.Create (BackSurfaceWidth, BackSurfaceHeight);
	}

	private void DestroySurface()
	{
		if (m_FrontSurface != null) {
			m_FrontSurface.Dispose ();
			m_FrontSurface = null;
		}
	}


	void Update()
	{
		Clear (Color.black);
	}

	void Start()
	{
		CreateComputeShader ();
		CreateSurface ();
		Bind (GetComponent<Renderer> ());
	}

	void OnDestroy()
	{
		DestroySurface ();
		DestroyComputeShader ();
	}

	private void CreateComputeShader()
	{
		m_DeviceShader = Resources.Load<ComputeShader> ("Device");
		m_ClearKernal = m_DeviceShader.FindKernel ("CSClear");
	}

	private void DestroyComputeShader()
	{
		if (m_DeviceShader != null) {
			Resources.UnloadAsset (m_DeviceShader);
			m_DeviceShader = null;
		}
	}
		

	// 提交
	public void Flip()
	{
		// 必须不为空
		if (m_FrontSurface != null) {
		}
	}

	// 清理的颜色
	public void Clear(Color cleanColor)
	{
		if (m_DeviceShader != null) {
			m_DeviceShader.SetTexture (m_ClearKernal, "Result", m_FrontSurface.Target);
			m_DeviceShader.Dispatch (m_ClearKernal, 2, 2, 0);
		}
	}
}