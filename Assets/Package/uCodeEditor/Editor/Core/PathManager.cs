//  Copyright (c) 2018-present amlovey
//  
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using System.IO;
using System;

namespace uCodeEditor
{
    public class PathManager
    {
        /// <summary>
        /// Get code editor index page
        /// </summary>
        public static string GetIndexHTMLPath()
        {
            var guids = AssetDatabase.FindAssets("index");
            string checkMark = "<!--uCodeEditor:d9c4-dcfc-ca98-kklo-->";
            string htmlPath = string.Format(@"file://{0}/uCodeEditor/Editor/index.html", Application.dataPath);
            foreach (var guid in guids)
            {
                string path = AssetDatabase.GUIDToAssetPath(guid);
                if (path.ToLower().EndsWith("index.html"))
                {
                    var obj = AssetDatabase.LoadAssetAtPath<TextAsset>(path);
                    if (obj != null && !string.IsNullOrEmpty(obj.text) && obj.text.Contains(checkMark))
                    {
                        htmlPath = string.Format("file://{0}", System.IO.Path.Combine(Application.dataPath, path.Substring("Assets/".Length)));
                    }
                }
            }

            return htmlPath;
        }

        /// <summary>
        /// Get override shortcut mapping config path
        /// </summary>
        public static string GetKeyMappingConfigPath()
        {
            string folder = OmniSharpManager.GetGlobalInstallLocation();
            string configFilePath = Utility.PathCombine(folder, Constants.KEYBINDING_CONFIG_FILE);
            configFilePath = Path.GetFullPath(configFilePath);
            return configFilePath;
        }

        /// <summary>
        /// Get code editor config file path
        /// </summary>
        public static string GetEditorConfigPath()
        {
            string folder = OmniSharpManager.GetGlobalInstallLocation();
            return Path.GetFullPath(Path.Combine(folder, "settings.json"));
        }

        /// <summary>
        /// Get cache file path of Go To file feature
        /// </summary>
        public static string GetGoToFileCachePath()
        {
            return Utility.PathCombine("Temp", "fileCache");
        }

        /// <summary>
        /// Get last opened files cache file
        /// </summary>
        public static string GetLastOpenedFilePath()
        {
            return Utility.PathCombine(LocalSettings.GetOrCreateLocalSettingsFolder(), "LastOpened.txt");
        }

        /// <summary>
        /// Get Global folder
        /// </summary>
        public static string GetUCEFolder()
        {
            var folder = Utility.PathCombine(Environment.GetFolderPath(Environment.SpecialFolder.Personal), ".uce");
            Directory.CreateDirectory(folder);
            return folder;
        }

        public static string GetUnityPackagesFolder()
        {
#if UNITY_EDITOR_WIN
            var localAppData = Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData);
            return Utility.PathCombine(localAppData, "Unity", "cache", "packages");
#else  
            var userFolder = Environment.GetFolderPath(Environment.SpecialFolder.Personal);
            return Utility.PathCombine(userFolder, "Library", "Unity", "cache", "packages");
#endif
        }

        public static string OmnisharpRestartLockFile()
        {
            return Utility.PathCombine(Application.temporaryCachePath, "omnisharp_restart.lock");
        }

        public static string GetUserSnippetsFilePath(string language)
        {
            var folder = OmniSharpManager.GetGlobalInstallLocation();
            return Utility.PathCombine(folder, string.Format("{0}.json", language));
        }

        public static string GetStdioBridgeVersionFilePath()
        {
            var folder = Utility.PathCombine(OmniSharpManager.GetGlobalInstallLocation(), "Versions");
            Directory.CreateDirectory(folder);
            return Utility.PathCombine(folder, "sb");
        }

        public static string GetModelTempCacheOverviewFilePath(string modelPath)
        {
            var md5 = Utility.MD5(modelPath);
            var folder = Utility.PathCombine(Application.dataPath, "..", "Temp", "modelCache");
            Directory.CreateDirectory(folder);
            var path = Path.Combine(folder, md5 + ".ov");
            return Path.GetFullPath(path);
        }

        public static string GetModelStatesStorePath()
        {
            var path = Utility.PathCombine(Application.dataPath, "..", "Temp", "modelStateStore");
            return Path.GetFullPath(path);
        }
    }
}
