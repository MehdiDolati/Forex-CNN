using System;
using System.Collections.Generic;

#nullable disable

namespace CNNBridge.Models
{
    public partial class Prediction
    {
        public Prediction()
        {
            PredictedValues = new HashSet<PredictedValue>();
        }

        public int Id { get; set; }
        public int ModelId { get; set; }
        public DateTime Time { get; set; }
        public DateTime SignalTime { get; set; }
        public byte Signal { get; set; }
        public double? Tp { get; set; }
        public double? Stop { get; set; }
        public string Description { get; set; }
        public DateTime? UpdateDate { get; set; }
        public byte? Result { get; set; }

        public virtual Model Model { get; set; }
        public virtual ICollection<PredictedValue> PredictedValues { get; set; }
    }
}
