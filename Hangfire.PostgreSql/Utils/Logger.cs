using Hangfire.Logging;
using System;
using System.Collections.Generic;
using System.IO;
using System.Text;

namespace Hangfire.PostgreSql.Utils
{
    public class Logger : ILog
    {
        public void WarnException(string message, Exception exception)
        {
            Log(LogLevel.Warn, () => message, exception);
        }

        public void DebugFormat(string message)
        {
            Log(LogLevel.Debug, () => message);
        }

        public void InfoFormat(string message)
        {
            Log(LogLevel.Info, () => message);
        }

        public bool Log(LogLevel logLevel, Func<string> messageFunc, Exception exception = null)
        {
            var msg = string.Format("{0:HH:mm:ss} -- [{1}] -- {2}{3}", DateTime.Now, logLevel, messageFunc.Invoke(), Environment.NewLine);

            var _fileName = GetFileName();

            try
            {
                if (!File.Exists(_fileName))
                {
                    File.WriteAllText(_fileName, msg);
                }
                else
                {
                    using (var stream = File.OpenWrite(_fileName))
                        File.AppendAllText(_fileName, msg);
                }
                return true;
            }
            catch (Exception)
            {
                return false;
            }
        }
        private string GetFileName()
        {
            return Path.Combine(AppContext.BaseDirectory + "Log", string.Format("hangfire-log-{0:dd-MM-yyyy}.log", DateTime.Now));
        }
    }
}
