using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using System;
using System.IO;

public class BuildUab {
    [MenuItem("Build/拷贝lua", false, 1001)]
    static void copyLua() {
        copyDirectory("Assets/LuaScripts", "Assets/Resources/LuaScripts");
    }

    static void copyDirectory(string src, string dst) {
        if (Directory.Exists(dst)) {
            Directory.Delete(dst, true);
        }
        Directory.CreateDirectory(dst);

        string[] files = Directory.GetFiles(src, "*.lua", SearchOption.AllDirectories);
        for (int i = 0; i < files.Length; i++) {
            string srcFile = files[i].Replace('\\', '/');
            string dstFile = Path.ChangeExtension(srcFile.Replace(src, dst), "txt");
            string dir = Path.GetDirectoryName(dstFile);
            if (!Directory.Exists(dir)) {
                Directory.CreateDirectory(dir);
            }
            File.Copy(srcFile, dstFile);
        }

        AssetDatabase.Refresh();
        Debug.Log(string.Format("copy from [ {0} ] to [ {1} ] done...", src, dst));
    }
}
