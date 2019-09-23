using UnityEngine;
using UnityEditor;

public class OHRGroundUV3GUI : ShaderGUI
{

    Material target;
    MaterialEditor editor;
    MaterialProperty[] properties;

    //粗糙度
    //enum RoughnessMixture
    //{
    //    roughness, mainTex, toVertex, threeVertex
    //}

    enum VertexMixture
    {
        mainTex, rgVertex, rgbVertex, vertexColor
    }

    enum NormalMixture
    {
        mainNormal, toNormal, threeNormal
    }

    enum LightMap
    {
        unityLightMap, innerLightMap
    }
    //配置标签内容 替换文本和工具提示 
    static GUIContent staticLabel = new GUIContent();
    static GUIContent MakeLabel(string text, string tooltip = null)
    {
        staticLabel.text = text;
        staticLabel.tooltip = tooltip;
        return staticLabel;
    }
    //如果不必从属性中提取显示名,MaterialProperty 实现
    static GUIContent MakeLabel(MaterialProperty property, string tooltip = null)
    {
        staticLabel.text = property.displayName;
        staticLabel.tooltip = tooltip;
        return staticLabel;
    }

    public override void OnGUI(MaterialEditor editor, MaterialProperty[] properties)
    {
        //材质属性
        this.target = editor.target as Material;
        this.editor = editor;
        this.properties = properties;
        DoMain();
        DoMask();
        //DoRenderTex();
        //Lightmap();
        //DoLightmap();
    }

    void DoMain()
    {
        GUILayout.Label("地 面 材 质 顶 点 色 混 合 UV3", EditorStyles.boldLabel);

        DoTexturNormal();

    }

    //光照贴图纹理
    void Lightmap()
    {
        GUILayout.Label("自 定 义 光 照 贴 图", EditorStyles.boldLabel);

        LightMap light = LightMap.unityLightMap;

        if (IsKeywordEnabled("_OHR_LIGHTMAP_UNITY"))
        {
            light = LightMap.unityLightMap;
        }
        else if (IsKeywordEnabled("_OHR_LIGHTMAP_INNER"))
        {
            light = LightMap.innerLightMap;
        }

        editor.EndAnimatedCheck();
        light = (LightMap)EditorGUILayout.EnumPopup(MakeLabel("Light Map"), light);

        if (EditorGUI.EndChangeCheck())
        {
            RecordAction("Light Map");
            SetKeyword("_OHR_LIGHTMAP_UNITY", light == LightMap.unityLightMap);
            SetKeyword("_OHR_LIGHTMAP_INNER", light == LightMap.innerLightMap);
        }

        MaterialProperty lightmap = FindProperty("_LightMap");
        Texture tex = lightmap.textureValue;
        EditorGUI.BeginChangeCheck();

        if (light == LightMap.innerLightMap)
        {
            editor.TexturePropertySingleLine(SetLabel(lightmap, "光照贴图，带ARBG，支持shadowmask，A通道为mask通道,如果为空，自动获取系统自带关照贴图信息"), lightmap, null);

            if (EditorGUI.EndChangeCheck())
            {
                if (tex != lightmap.textureValue)
                {
                    SetDefineInfo("_LightMap", lightmap.textureValue);
                }
                if (lightmap.textureValue == null)
                {
                    SetDefineInfo("CF_LIGHTMAP", false);
                }
                else
                {
                    SetDefineInfo("CF_LIGHTMAP", true);
                }
            }
            editor.TextureScaleOffsetProperty(lightmap);
        }


    }

    public GUIContent SetLabel(MaterialProperty property, string contentValue)
    {
        staticLabel.text = property.displayName;
        staticLabel.tooltip = contentValue;
        return staticLabel;
    }

    public void SetDefineInfo(string defineName, bool state)
    {
        foreach (Material sub in editor.targets)
        {
            if (state)
            {
                sub.EnableKeyword(defineName);
            }
            else
            {
                sub.DisableKeyword(defineName);
            }
        }
    }

    //void DoLightmap()
    //{
    //    MaterialProperty lightMap = FindProperty("_LightMap");
    //    editor.TexturePropertySingleLine(MakeLabel(lightMap, "Light Map"), lightMap);
    //}


    void DoTexturNormal()
    {
        //顶点色
        EditorGUI.BeginChangeCheck();
        VertexMixture rgbaVertex = VertexMixture.mainTex;

        if (IsKeywordEnabled("_MIAN_VERTEX"))
        {
            rgbaVertex = VertexMixture.mainTex;
        }

        if (IsKeywordEnabled("_RG_VERTEX"))
        {
            rgbaVertex = VertexMixture.rgVertex;
        }

        if (IsKeywordEnabled("_RGB_VERTEX"))
        {
            rgbaVertex = VertexMixture.rgbVertex;
        }


        if (IsKeywordEnabled("_VERTEX_COLOR"))
        {
            rgbaVertex = VertexMixture.vertexColor;
        }


        EditorGUI.BeginChangeCheck();
        rgbaVertex = (VertexMixture)EditorGUILayout.EnumPopup(MakeLabel("切换贴图数量"), rgbaVertex);

        if (EditorGUI.EndChangeCheck())
        {
            RecordAction("Vertex Mixture");
            SetKeyword("_MIAN_VERTEX", rgbaVertex == VertexMixture.mainTex);
            SetKeyword("_RG_VERTEX", rgbaVertex == VertexMixture.rgVertex);
            SetKeyword("_RGB_VERTEX", rgbaVertex == VertexMixture.rgbVertex);
            SetKeyword("_VERTEX_COLOR", rgbaVertex == VertexMixture.vertexColor);
        }

        //搜索Tex

        MaterialProperty mainTex = FindProperty("_MainTex");
        //MaterialProperty colorR = FindProperty("_Color");

        MaterialProperty GTex = FindProperty("_GTex");
        //MaterialProperty colorG = FindProperty("_ColorGVertex");

        MaterialProperty BTex = FindProperty("_BTex");
        //MaterialProperty colorB = FindProperty("_ColorBVertex");

        //搜索nromal
        MaterialProperty mainN = FindProperty("_MainNromalMap");
        MaterialProperty GN = FindProperty("_GNormalMap");
        MaterialProperty BN = FindProperty("_BNormalMap");

        //normal强度
        MaterialProperty amoutn = FindProperty("_NormalAmoutnN1");

        //金属度Metallic 粗糙度Roughness
        //R
        MaterialProperty metallicR = FindProperty("_Metallic");
        MaterialProperty roughnessR = FindProperty("_Roughness");
        //G
        MaterialProperty metallicG = FindProperty("_MetallicG");
        MaterialProperty roughnessG = FindProperty("_RoughnessG");
        //B
        MaterialProperty metallicB = FindProperty("_MetallicB");
        MaterialProperty roughnessB = FindProperty("_RoughnessB");

        //高度图强度
        MaterialProperty strength = FindProperty("_Strength");
        EditorGUI.BeginChangeCheck();

        // 创建UI部件
        if (rgbaVertex == VertexMixture.mainTex)
        {
            editor.TexturePropertySingleLine(MakeLabel(mainTex, "Main Tex"), mainTex, FindProperty("_Color"));
            EditorGUI.indentLevel += 2;
            editor.TexturePropertySingleLine(MakeLabel(mainN), mainN);
            editor.ShaderProperty(metallicR, MakeLabel(metallicR));
            editor.ShaderProperty(roughnessR, MakeLabel(roughnessR));
            editor.TextureScaleOffsetProperty(mainTex);
            EditorGUI.indentLevel -= 2;

        }

        if (rgbaVertex == VertexMixture.rgVertex)
        {
            editor.TexturePropertySingleLine(MakeLabel(mainTex, "R顶点色纹理(RGB)"), mainTex, FindProperty("_Color"));
            EditorGUI.indentLevel += 2;
            editor.TexturePropertySingleLine(MakeLabel(mainN), mainN);
            editor.ShaderProperty(metallicR, MakeLabel(metallicR));
            editor.ShaderProperty(roughnessR, MakeLabel(roughnessR));
            editor.TextureScaleOffsetProperty(mainTex);

            EditorGUI.indentLevel -= 2;

            editor.TexturePropertySingleLine(MakeLabel(GTex, "G顶点色纹理(RGB)"), GTex, FindProperty("_ColorGVertex"));
            EditorGUI.indentLevel += 2;
            editor.TexturePropertySingleLine(MakeLabel(GN), GN);
            editor.ShaderProperty(metallicG, MakeLabel(metallicG));
            editor.ShaderProperty(roughnessG, MakeLabel(roughnessG));
            editor.TextureScaleOffsetProperty(GTex);

            EditorGUI.indentLevel -= 2;

        }

        if (rgbaVertex == VertexMixture.rgbVertex)
        {
            editor.TexturePropertySingleLine(MakeLabel(mainTex, "R顶点色纹理(RGB)"), mainTex, FindProperty("_Color"));
            EditorGUI.indentLevel += 2;
            editor.TexturePropertySingleLine(MakeLabel(mainN), mainN);
            editor.ShaderProperty(metallicR, MakeLabel(metallicR));
            editor.ShaderProperty(roughnessR, MakeLabel(roughnessR));
            editor.TextureScaleOffsetProperty(mainTex);

            EditorGUI.indentLevel -= 2;

            editor.TexturePropertySingleLine(MakeLabel(GTex, "G顶点色纹理(RGB)"), GTex, FindProperty("_ColorGVertex"));
            EditorGUI.indentLevel += 2;
            editor.TexturePropertySingleLine(MakeLabel(GN), GN);
            editor.ShaderProperty(metallicG, MakeLabel(metallicG));
            editor.ShaderProperty(roughnessG, MakeLabel(roughnessG));
            editor.TextureScaleOffsetProperty(GTex);

            EditorGUI.indentLevel -= 2;

            editor.TexturePropertySingleLine(MakeLabel(BTex, "RGB顶点色纹理(RGB)"), BTex, FindProperty("_ColorBVertex"));
            EditorGUI.indentLevel += 2;
            editor.TexturePropertySingleLine(MakeLabel(BN), BN);
            editor.ShaderProperty(metallicB, MakeLabel(metallicB));
            editor.ShaderProperty(roughnessB, MakeLabel(roughnessB));
            editor.TextureScaleOffsetProperty(BTex);

            EditorGUI.indentLevel -= 2;

        }

        EditorGUI.indentLevel += 2;
        editor.ShaderProperty(amoutn, MakeLabel(amoutn));
        editor.ShaderProperty(strength, MakeLabel(strength));
        EditorGUI.indentLevel -= 2;

    }

    //mask 3套 UV
    void DoMask()
    {
        EditorGUI.BeginChangeCheck();
        bool maskTexBool = EditorGUILayout.Toggle(MakeLabel("细 节 贴 图 UV1", "Mask Tex"), IsKeywordEnabled("_MASK_DETAIL"));
        MaterialProperty maskTex = FindProperty("_MaskTex");
        MaterialProperty ao = FindProperty("_Occlusion");
        if (EditorGUI.EndChangeCheck())
        {
            SetKeyword("_MASK_DETAIL", maskTexBool);
        }
        if (maskTexBool)
        {
            editor.TexturePropertySingleLine(MakeLabel(maskTex, "Mask Tex"), maskTex);
            editor.TextureScaleOffsetProperty(maskTex);
            editor.ShaderProperty(ao, MakeLabel(ao));
        }
    }


    //RenderTex
    //void DoRenderTex()
    //{
    //    EditorGUI.BeginChangeCheck();
    //    bool RenderTexBool = EditorGUILayout.Toggle(MakeLabel("Render Tex Reflect", "渲染反射物体"), IsKeywordEnabled("_RENDERTEX_REFLECT"));
    //    MaterialProperty renderTex = FindProperty("_RefTex");
    //    if (EditorGUI.EndChangeCheck())
    //    {
    //        SetKeyword("_RENDERTEX_REFLECT", RenderTexBool);
    //    }

    //    if (RenderTexBool)
    //    {
    //        editor.TexturePropertySingleLine(MakeLabel(renderTex, "_RefTex"), renderTex);
    //    }
    //}

    //法线
    //void DoNormals()
    //{
    //MaterialProperty map = FindProperty("_MainNromalMap");
    ////检测是否有UI属性的编辑操作
    //EditorGUI.BeginChangeCheck();
    //EditorGUI.indentLevel += 2;
    //editor.TexturePropertySingleLine(MakeLabel(map), map, FindProperty("_NormalAmoutnN1"));
    //EditorGUI.indentLevel -= 2;

    //if (EditorGUI.EndChangeCheck())
    //{
    //    //关键字判断引用
    //    SetKeyword("_NORMAL_MAP", map.textureValue);
    //}

    //}

    //金属度 
    //void DoMetallic()
    //{
    //    MaterialProperty slider = FindProperty("_Metallic");
    //    editor.ShaderProperty(slider, MakeLabel(slider));

    //}

    //粗糙度
    //void Roughness()
    //{
    //    EditorGUI.BeginChangeCheck();
    //    MaterialProperty slider = FindProperty("_Roughness");
    //    editor.ShaderProperty(slider, MakeLabel(slider));
    //}

    //GUI检查启用关键字进行选择
    bool IsKeywordEnabled(string keyword)
    {
        return target.IsKeywordEnabled(keyword);
    }

    //UI撤销
    void RecordAction(string label)
    {
        editor.RegisterPropertyChangeUndo(label);
    }

    //添加关键字
    void SetKeyword(string keyword, bool state)
    {
        if (state)
        {
            target.EnableKeyword(keyword);
        }
        else
        {
            target.DisableKeyword(keyword);
        }
    }

    //搜索变量名
    MaterialProperty FindProperty(string name)
    {
        return FindProperty(name, properties);
    }
}
