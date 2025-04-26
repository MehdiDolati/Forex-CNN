using System;
using System.Collections.Generic;

#nullable disable

namespace CNNBridge.Models
{
    public partial class PredictedValue
    {
        public int Id { get; set; }
        public int PredictionId { get; set; }
        public string ClassLabel { get; set; }
        public double PredictedValue1 { get; set; }

        public virtual Prediction Prediction { get; set; }
    }
}
