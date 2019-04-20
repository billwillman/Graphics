using UnityEngine;
using System.Collections;

// 表面
public class NsSurface
{
	private RenderTexture m_Target = null;

	public RenderTexture Target
	{
		get
		{
			return m_Target;
		}
	}

	public void Attach(Renderer render)
	{
		if ((render != null) && (render.sharedMaterial != null)) {
			render.sharedMaterial.mainTexture = m_Target;
		}
	}

	public void Dispose()
	{
		DelelteTarget();
	}

	private void DelelteTarget()
	{
		if (m_Target != null) {
			//RenderTexture.ReleaseTemporary (m_Target);
			GameObject.Destroy(m_Target);
			m_Target = null;
		}
	}

	private NsSurface(int AWidth, int AHeight)
	{
		//m_Target = RenderTexture.GetTemporary (AWidth, AHeight, 0, RenderTextureFormat.ARGB32, RenderTextureReadWrite.Linear); 
		m_Target = new RenderTexture(AWidth, AHeight, 0, RenderTextureFormat.ARGB32, RenderTextureReadWrite.Linear); 
		m_Target.enableRandomWrite = true;
		m_Target.Create ();
	}

	public static NsSurface Create(int AWidth = 1024, int AHeight = 768)
	{
		NsSurface ret = new NsSurface (AWidth, AHeight);
		return ret;
	}
}