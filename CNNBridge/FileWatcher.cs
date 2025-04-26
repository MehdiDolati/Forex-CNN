using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Security.Permissions;
using System.Text;
using System.Threading;
using System.Threading.Tasks;

namespace CNNBridge
{
    public class CNNFileWatherArgs : EventArgs
    {
        public string FileName { get; set; }
        public DateTime EventTime { get; set; }
    }
    public class CNNFileWatcher
    {
        private string commodity, timeframe;
        public CNNFileWatcher(string _commodity, string _timeframe)
        {
            commodity = _commodity;
            timeframe = _timeframe;
        }

        public event NewPatternFoundEventHandler NewPatternFound;
        public event NewResultFoundEventHandler NewResultFound;
        public delegate void NewPatternFoundEventHandler(object sender, CNNFileWatherArgs e);
        public delegate void NewResultFoundEventHandler(object sender, CNNFileWatherArgs e);

        protected virtual void OnNewPatternFound(object sender, CNNFileWatherArgs e) //protected virtual method
        {
            //if ProcessCompleted is not null then call delegate
            NewPatternFound?.Invoke(sender, e);
        }

        protected virtual void OnNewResultFound(object sender, CNNFileWatherArgs e) //protected virtual method
        {
            //if ProcessCompleted is not null then call delegate
            NewResultFound?.Invoke(sender, e);
        }

        private bool stopToken = false;
        [PermissionSet(SecurityAction.Demand, Name = "FullTrust")]
        public void ListenToFileChange()
        {
            // Create a new FileSystemWatcher and set its properties.
            using (FileSystemWatcher watcher = new FileSystemWatcher())
            {
                watcher.Path = AppDomain.CurrentDomain.BaseDirectory;

                // Watch for changes in LastAccess and LastWrite times, and
                // the renaming of files or directories.
                watcher.NotifyFilter = NotifyFilters.LastAccess
                                     | NotifyFilters.LastWrite
                                     | NotifyFilters.FileName
                                     | NotifyFilters.DirectoryName;

                // Only watch text files.
                watcher.Filter = "*.csv";

                // Add event handlers.
                //watcher.Changed += OnChanged;
                watcher.Created += OnChanged;
                //watcher.Deleted += OnChanged;
                //watcher.Renamed += OnRenamed;

                // Begin watching.
                watcher.EnableRaisingEvents = true;
                while (!stopToken) { };
            }
        }

        private static bool IsFileClosed(string filepath, bool wait)
        {
            bool fileClosed = false;
            int retries = 20;
            const int delay = 500; // Max time spent here = retries*delay milliseconds

            if (!File.Exists(filepath))
                return false;

            do
            {
                try
                {
                    // Attempts to open then close the file in RW mode, denying other users to place any locks.
                    FileStream fs = File.Open(filepath, FileMode.Open, FileAccess.ReadWrite, FileShare.None);
                    fs.Close();
                    fileClosed = true; // success
                }
                catch (IOException) { }

                if (!wait) break;

                retries--;

                if (!fileClosed)
                    Thread.Sleep(delay);
            }
            while (!fileClosed && retries > 0);

            return fileClosed;
        }

        public void Stop()
        {
            stopToken = true;
        }

        // Define the event handlers.
        private void OnChanged(object source, FileSystemEventArgs e)
        {
            if (stopToken)
                return;
            // Specify what is done when a file is changed, created, or deleted.
            //if (e.Name.StartsWith("CNN_" + Commodity + Timeframe))
            if (e.ChangeType == WatcherChangeTypes.Created && e.Name.StartsWith("CNN_" + commodity + timeframe) && IsFileClosed(e.FullPath, true))
                OnNewPatternFound(this, new CNNFileWatherArgs { EventTime = DateTime.Now , FileName = e.FullPath});
            else if (e.ChangeType == WatcherChangeTypes.Created && e.Name.StartsWith("CNNSingle_" + commodity + timeframe) && IsFileClosed(e.FullPath, true))
                OnNewResultFound(this, new CNNFileWatherArgs { EventTime = DateTime.Now, FileName = e.FullPath });
        }
    }
}