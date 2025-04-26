using System;
using System.Collections.Generic;

#nullable disable

namespace CNNBridge.Models
{
    public partial class Model
    {
        public Model()
        {
            Predictions = new HashSet<Prediction>();
        }

        public int Id { get; set; }
        public string Name { get; set; }

        public virtual ICollection<Prediction> Predictions { get; set; }
    }
}
