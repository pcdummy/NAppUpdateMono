using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Diagnostics;
using System.IO;
using System.Runtime.Serialization.Formatters.Binary;
using System.Threading;
using NAppUpdate.Framework.Common;
using NAppUpdate.Framework.Tasks;

namespace NAppUpdate.Framework.Utils
{
    /// <summary>
    ///     Starts the cold update process by extracting the updater app from the library's resources,
    ///     passing it all the data it needs and terminating the current application
    /// </summary>
    internal static class NauIpc
    {
        [Serializable]
        internal class NauDto
        {
            public NauConfigurations Configs { get; set; }
            public IList<IUpdateTask> Tasks { get; set; }
            public List<Logger.LogItem> LogItems { get; set; }
            public string AppPath { get; set; }
            public string WorkingDirectory { get; set; }
            public bool RelaunchApplication { get; set; }
        }

        private static string GetAdditionalParamsFileName(string syncProcessName)
        {
            return Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData), syncProcessName);
        }

        internal static void WriteDtoToFile(NauDto dto, string fileName)
        {
            using (var fileStream = new FileStream(fileName, FileMode.Create))
            {
                new BinaryFormatter().Serialize(fileStream, dto);
                fileStream.Flush();
            }
        }

        public static Process LaunchProcessAndSendDto(NauDto dto, ProcessStartInfo processStartInfo,
            string syncProcessName)
        {
            Process p;
            var paramsFileName = GetAdditionalParamsFileName(syncProcessName);

            try
            {
                WriteDtoToFile(dto, paramsFileName);
            }
            catch (Exception e)
            {
                Console.WriteLine("Writing params to temporary path failed: '{0}'", e);
                if (File.Exists(paramsFileName))
                    File.Delete(paramsFileName);
                return null;
            }

            if (!File.Exists(paramsFileName))
            {
                Console.WriteLine("Writing params to temporary path failed");
                return null;
            }

            try
            {
                p = ExtendendStartProcess.Start(processStartInfo);
            }
            catch (Win32Exception e)
            {
                // Person denied UAC escallation
                Console.WriteLine("User denied UAC escallation? Error while launching process: {0}.", e);
                return null;
            }

            for (int i = 0; i < 15; i++)
            {
                if (!File.Exists(paramsFileName))
                    return p;
                Thread.Sleep(1000);
            }

            File.Delete(paramsFileName);
            return null;
        }


        internal static object ReadDto(string syncProcessName)
        {
            var paramsFileName = GetAdditionalParamsFileName (syncProcessName);
            if (!File.Exists (paramsFileName))
                return null;

            object result;
            using (var fileStream = new FileStream (paramsFileName, FileMode.Open))
            {
                var formatter = new BinaryFormatter {
                    Binder = new CarelessAssemblyDeserializationBinder ()
                };
                result = formatter.Deserialize (fileStream);
            }

            File.Delete (paramsFileName);

            return result;
        }
    }
}