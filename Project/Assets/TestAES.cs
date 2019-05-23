using System.Collections;
using System.Collections.Generic;
using System;
using UnityEngine;
using System.Text;
using System.Security.Cryptography;
using System.IO;

public class TestAES : MonoBehaviour
{
    void testEncrypt(string source, string key, string iv, int keySize = 128) {
        byte[] buf = Encoding.UTF8.GetBytes(source);
        RijndaelManaged aes = new RijndaelManaged();
        aes.Mode = CipherMode.CBC;
        aes.Padding = PaddingMode.PKCS7;
        aes.KeySize = keySize;
        aes.BlockSize = keySize;
        //aes.BlockSize = Encoding.UTF8.GetByteCount(iv) * 8;
        aes.Key = Encoding.UTF8.GetBytes(key);
        int vecLen = keySize / 8;
        byte[] bVector = new Byte[vecLen];
       // byte[] ivBuf = Encoding.UTF8.GetBytes(iv);
        string ss = iv.PadRight(bVector.Length);
        Array.Copy(Encoding.UTF8.GetBytes(ss), bVector, bVector.Length);
        aes.IV = bVector;
        ICryptoTransform transform = aes.CreateEncryptor();
        byte[] aesBuf = transform.TransformFinalBlock(buf, 0, buf.Length);
        string ret = Convert.ToBase64String(aesBuf);
        Debug.LogError(ret);
    }

    string str = "abc";
    string key = "cgm8flslppdc19zm";
    string iv = "mlfu2zk4m2opin0y";
    private void Start() {
        
    }

    private void OnGUI() {
        if (GUI.Button(new Rect(100, 100, 200, 50), "测试AES")) {
            testEncrypt(str, key, iv, 256);
        }
    }
}
