using UnityEngine;
using System.Collections;

[RequireComponent(typeof(Renderer))]
public class NsDevice: MonoBehaviour
{
	//private NsSurface m_BackSurface = null;
	private ComputeShader m_DeviceShader;
	private int m_ClearKernal = -1;
    private int m_FrontTexId = -1;
    private int m_ZBufTexId = -1;
    private int m_ClearColorId = -1;
    private NsVertexBuffer m_CurVerBuf = null;
    private NsIndex32Buffer m_CurIdxBuf = null;
    private int m_VertexBufId = -1;
    private int m_IndexBufId = -1;
    private int m_ColorBufId = -1;
    private int m_UV0BufId = -1;
    private int m_DrawBufKernal = -1;
    private int m_Index32BufId = -1;
    private int m_ScreenSizeId = -1;

    public Color ClearColor = Color.black;
	public int BackSurfaceWidth = 1024;
    public int BackSurfaceHeight = 768;

	const string _cFrontSurface = "frontSurface";
	const string _czBufferSurface = "zBufferSurface";
	const string _ciColorColor = "iClearColor";
	const string _ciVertexBuffer = "iVertexBuffer";
	const string _ciIndex32Buffer = "iIndex32Buffer";
	const string _ciColorBuffer = "iColorBuffer";
	const string _ciUV0Buffer = "iUV0Buffer";
	const string _ciScreenSize = "iScreenSize";

    private void GeneratorIds() {
		m_FrontTexId = Shader.PropertyToID(_cFrontSurface);
		m_ZBufTexId = Shader.PropertyToID(_czBufferSurface);
		m_ClearColorId = Shader.PropertyToID(_ciColorColor);

        // Buffer
		m_VertexBufId = Shader.PropertyToID(_ciVertexBuffer);
		m_IndexBufId = Shader.PropertyToID(_ciIndex32Buffer);
		m_ColorBufId = Shader.PropertyToID(_ciColorBuffer);
		m_UV0BufId = Shader.PropertyToID(_ciUV0Buffer);
		m_Index32BufId = Shader.PropertyToID(_ciIndex32Buffer);
		m_ScreenSizeId = Shader.PropertyToID(_ciScreenSize);
    }

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

    void InitDraw() {
        if (m_DeviceShader != null) {
			#if UNITY_5_3_7
			m_DeviceShader.SetInts(_ciScreenSize, BackSurfaceWidth, BackSurfaceHeight);
			#else
            m_DeviceShader.SetInts(m_ScreenSizeId, BackSurfaceWidth, BackSurfaceHeight);
			#endif
        }
    }

    void PreDraw() {
        
    }


	void Update()
	{
        PreDraw();
        Clear ();
	}

	void Start()
	{
        GeneratorIds();
        CreateComputeShader ();
		CreateSurface ();
        InitDraw();
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
        m_DrawBufKernal = m_DeviceShader.FindKernel("CSDrawBuf");

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
	public void Clear()
	{
		if (m_DeviceShader != null && m_FrontSurface != null) {

            
			#if UNITY_5_3_7
			m_DeviceShader.SetTexture(m_ClearKernal, _cFrontSurface, m_FrontSurface.Target); 
			m_DeviceShader.SetTexture(m_ClearKernal, _czBufferSurface, m_FrontSurface.ZTarget);
			m_DeviceShader.SetFloats(_ciColorColor, ClearColor.r, ClearColor.g, ClearColor.b, ClearColor.a);
			#else
			m_DeviceShader.SetTexture(m_ClearKernal, m_FrontTexId, m_FrontSurface.Target);
			m_DeviceShader.SetTexture(m_ClearKernal, m_ZBufTexId, m_FrontSurface.ZTarget);
            m_DeviceShader.SetFloats(m_ClearColorId, ClearColor.r, ClearColor.g, ClearColor.b, ClearColor.a);
			#endif
			m_DeviceShader.Dispatch (m_ClearKernal, BackSurfaceWidth/32, BackSurfaceHeight/32, 1);
		}
	}

    public void DrawBuffer(NsVertexBuffer vertBuf, NsIndex32Buffer idxBuf) {
        BindVertexBuffer(vertBuf);
        BindIndex32Buffer(idxBuf);
    }

    protected void BindVertexBuffer(NsVertexBuffer buffer) {
        if (m_CurVerBuf != buffer) {
            m_CurVerBuf = buffer;
			#if UNITY_5_3_7
			m_DeviceShader.SetBuffer(m_DrawBufKernal, _ciVertexBuffer, buffer.VertexBuf);
			m_DeviceShader.SetBuffer(m_DrawBufKernal, _ciColorBuffer, buffer.ColorBuf);
			m_DeviceShader.SetBuffer(m_DrawBufKernal, _ciUV0Buffer, buffer.UV0Buf);
			#else
            m_DeviceShader.SetBuffer(m_DrawBufKernal, m_VertexBufId, buffer.VertexBuf);
            m_DeviceShader.SetBuffer(m_DrawBufKernal, m_ColorBufId, buffer.ColorBuf);
            m_DeviceShader.SetBuffer(m_DrawBufKernal, m_UV0BufId, buffer.UV0Buf);
			#endif
        }
    }

    protected void BindIndex32Buffer(NsIndex32Buffer buffer) {
        if (m_CurIdxBuf != buffer) {
            m_CurIdxBuf = buffer;
			#if UNITY_5_3_7
			m_DeviceShader.SetBuffer(m_DrawBufKernal, _ciIndex32Buffer, buffer.Buffer);
			#else
            m_DeviceShader.SetBuffer(m_DrawBufKernal, m_Index32BufId, buffer.Buffer);
			#endif
        }
    }
}