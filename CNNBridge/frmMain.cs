using CNNBridge.Models;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Security.Permissions;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace CNNBridge
{
    public enum Signal
    {
        Buy = 1,
        Hold = 2,
        Sell = 3
    }
    public enum TradeResult
    {
        Unknown = 1,
        TP = 2,
        Stop = 3
    }
    public partial class frmMain : Form
    {
        CancellationTokenSource cts = new CancellationTokenSource();
        private bool isListening = false;
        Thread newCandleListener;
        predict_cnn.CNNEngine engine = new predict_cnn.CNNEngine();
        string Commodity;
        string Timeframe;
        CNNFileWatcher fileWatcher;
        public frmMain()
        {
            InitializeComponent();
            loadComboBoxes();
        }

        // event handler
        private void OnNewPatternFound(object sender, CNNFileWatherArgs e)
        {
            try
            {
                var result = engine.predict_cnn("CNN_" + Commodity + Timeframe + ".csv");
                var buy = (float)result.ToArray().GetValue(0, 0);
                var hold = (float)result.ToArray().GetValue(0, 1);
                var sell = (float)result.ToArray().GetValue(0, 2);
                var margin = (float)result.ToArray().GetValue(0, 3);
                var tp = (float)result.ToArray().GetValue(0, 4);
                var stop = (float)result.ToArray().GetValue(0, 5);
                var signalTime = DateTime.Now;
                Signal signal = Signal.Hold;
                lblLastPredictionTime.Invoke(new Action(() => lblLastPredictionTime.Text = signalTime.ToString()));
                if (buy > hold)
                    if (buy > sell)
                        signal = Signal.Buy;
                    else
                        signal = Signal.Sell;
                else if (hold > sell)
                    signal = Signal.Hold;
                else
                    signal = Signal.Sell;
                switch (signal)
                {
                    case Signal.Buy:
                        lblPrediction.Invoke(new Action(() => lblPrediction.Text = "Buy"));
                        break;
                    case Signal.Hold:
                        lblPrediction.Invoke(new Action(() => lblPrediction.Text = "Hold"));
                        break;
                    case Signal.Sell:
                        lblPrediction.Invoke(new Action(() => lblPrediction.Text = "Sell"));
                        break;
                    default:
                        break;
                }
                lblPrediction.Invoke(new Action(() => lblPrediction.Text += " Level: " + margin + " TP: " + tp + " Stop: " + stop));
                lblValues.Invoke(new Action(() => lblValues.Text = "Buy => " + buy + " Hold => " + hold + " Sell => " + sell));
                File.Delete(e.FileName);
                string output = DateTime.Now.ToString(("yyyy.MM.dd HH:mm")) + ',' + buy + ',' + hold + ',' + sell + ',' + margin + ',' + tp + ',' + stop;
                string outputFileName = "CNNPrediction_" + Commodity + Timeframe + ".csv";
                //File.Create(outputFileName);
                using (var w = new StreamWriter(outputFileName))
                {
                    w.WriteLine(output);
                    w.Flush();
                }
                using (var context = new DBContext())
                {
                    var model = context.Models.FirstOrDefault(m => m.Id == 1);
                    List<PredictedValue> predictedValues = new List<PredictedValue>();
                    predictedValues.Add(new PredictedValue { ClassLabel = "Buy", PredictedValue1 = buy });
                    predictedValues.Add(new PredictedValue { ClassLabel = "Hold", PredictedValue1 = hold });
                    predictedValues.Add(new PredictedValue { ClassLabel = "Sell", PredictedValue1 = sell });
                    var prediction = new Prediction()
                    {
                        Model = model,
                        PredictedValues = predictedValues,
                        SignalTime = signalTime,
                        Tp = tp,
                        Stop = stop,
                        Signal = (byte)signal,
                    };
                    if (signal == Signal.Hold)
                        prediction.UpdateDate = DateTime.Now;
                    context.Predictions.Add(prediction);
                    context.SaveChanges();
                }
            }
            catch (Exception ex)
            {
                lblPrediction.Invoke(new Action(() => lblPrediction.Text = "Error Occured"));
                lblValues.Invoke(new Action(() => lblValues.Text = ex.Message));
            }
        }

        private void OnNewResultFound(object sender, CNNFileWatherArgs e)
        {
            updateIssuedSignals(e.FileName);
        }

        private void loadComboBoxes()
        {
            cmbCommodity.SelectedIndex = 0;
            cmbTimeframe.SelectedIndex = 4;
        }

        private void btnStartStop_Click(object sender, EventArgs e)
        {
            if (isListening)
            {
                this.btnStartStop.Text = "Start Listening";
                this.cmbCommodity.Enabled = true;
                this.cmbTimeframe.Enabled = true;
                isListening = false;
                lblStatus.Text = "Not Listening";
                Commodity = "";
                Timeframe = "";
            }
            else
            {
                this.btnStartStop.Text = "Stop Listening";
                this.cmbCommodity.Enabled = false;
                this.cmbTimeframe.Enabled = false;
                isListening = true;
                lblStatus.Text = "Listening Started at " + DateTime.Now;
                Commodity = this.cmbCommodity.Text;
                Timeframe = this.cmbTimeframe.Text;
                File.Delete("CNN_" + Commodity + Timeframe + ".csv");
                File.Delete("CNNSingle_" + Commodity + Timeframe + ".csv");
                fileWatcher = new CNNFileWatcher(Commodity, Timeframe);
                fileWatcher.NewPatternFound += OnNewPatternFound;
                fileWatcher.NewResultFound += OnNewResultFound;
                newCandleListener = new Thread(fileWatcher.ListenToFileChange);
                newCandleListener.Start();
            }
        }

        private void updateIssuedSignals(string fileName)
        {
            double Open = 0;
            double High = 0;
            double Low = 0;
            double Close = 0;
            DateTime Time;
            using (StreamReader sr = new StreamReader(fileName))
            {
                while (!sr.EndOfStream)
                {
                    string line = sr.ReadLine();
                    string[] values = line.Split(',');
                    Time = DateTime.ParseExact(values[0], "yyyy.MM.dd HH:mm", CultureInfo.InvariantCulture);
                    Open = double.Parse(values[1]);
                    High = double.Parse(values[2]);
                    Low = double.Parse(values[3]);
                    Close = double.Parse(values[4]);
                }
                sr.Close();
                sr.Dispose();
                File.Delete(fileName);
            }
            using (var context = new DBContext())
            {
                var query = from p in context.Predictions
                            where p.Result == null && p.UpdateDate == null
                            select p;
                foreach (var item in query)
                {
                    if (DateTime.Now.Subtract(item.SignalTime).Minutes > (60 * 24 - 1))
                        item.UpdateDate = DateTime.Now; //missed track
                    else if (item.Signal == (byte)Signal.Buy)
                    {
                        if (Low < item.Stop)
                        {
                            item.Result = (byte)TradeResult.Stop;
                            item.UpdateDate = DateTime.Now;
                        }
                        else if (High > item.Tp)
                        {
                            item.Result = (byte)TradeResult.TP;
                            item.UpdateDate = DateTime.Now;
                        }
                    }
                    else if (item.Signal == (byte)Signal.Sell)
                    {
                        if (High > item.Stop)
                        {
                            item.Result = (byte)TradeResult.Stop;
                            item.UpdateDate = DateTime.Now;
                        }
                        else if (Low < item.Tp)
                        {
                            item.Result = (byte)TradeResult.TP;
                            item.UpdateDate = DateTime.Now;
                        }
                    }
                    else
                    {
                        item.UpdateDate = DateTime.Now;
                        item.Result = (byte)TradeResult.Unknown;
                    }
                }
                context.SaveChanges();
            }
        }


        private void frmMain_FormClosed(object sender, FormClosedEventArgs e)
        {
            if (fileWatcher != null)
                fileWatcher.Stop();
        }
    }
}