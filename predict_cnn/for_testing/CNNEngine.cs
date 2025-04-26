/*
* MATLAB Compiler: 8.1 (R2020b)
* Date: Fri Oct 15 19:33:19 2021
* Arguments:
* "-B""macro_default""-W""dotnet:predict_cnn,CNNEngine,4.0,private,version=1.0""-T""link:l
* ib""-d""D:\Dropbox\Forex
* Projects\CNN\predict_cnn\for_testing""-v""class{CNNEngine:D:\Dropbox\Forex
* Projects\CNN\predict_cnn.mlx}"
*/
using System;
using System.Reflection;
using System.IO;
using MathWorks.MATLAB.NET.Arrays;
using MathWorks.MATLAB.NET.Utility;

#if SHARED
[assembly: System.Reflection.AssemblyKeyFile(@"")]
#endif

namespace predict_cnn
{

  /// <summary>
  /// The CNNEngine class provides a CLS compliant, MWArray interface to the MATLAB
  /// functions contained in the files:
  /// <newpara></newpara>
  /// D:\Dropbox\Forex Projects\CNN\predict_cnn.mlx
  /// </summary>
  /// <remarks>
  /// @Version 1.0
  /// </remarks>
  public class CNNEngine : IDisposable
  {
    #region Constructors

    /// <summary internal= "true">
    /// The static constructor instantiates and initializes the MATLAB Runtime instance.
    /// </summary>
    static CNNEngine()
    {
      if (MWMCR.MCRAppInitialized)
      {
        try
        {
          Assembly assembly= Assembly.GetExecutingAssembly();

          string ctfFilePath= assembly.Location;

		  int lastDelimiter = ctfFilePath.LastIndexOf(@"/");

	      if (lastDelimiter == -1)
		  {
		    lastDelimiter = ctfFilePath.LastIndexOf(@"\");
		  }

          ctfFilePath= ctfFilePath.Remove(lastDelimiter, (ctfFilePath.Length - lastDelimiter));

          string ctfFileName = "predict_cnn.ctf";

          Stream embeddedCtfStream = null;

          String[] resourceStrings = assembly.GetManifestResourceNames();

          foreach (String name in resourceStrings)
          {
            if (name.Contains(ctfFileName))
            {
              embeddedCtfStream = assembly.GetManifestResourceStream(name);
              break;
            }
          }
          mcr= new MWMCR("",
                         ctfFilePath, embeddedCtfStream, true);
        }
        catch(Exception ex)
        {
          ex_ = new Exception("MWArray assembly failed to be initialized", ex);
        }
      }
      else
      {
        ex_ = new ApplicationException("MWArray assembly could not be initialized");
      }
    }


    /// <summary>
    /// Constructs a new instance of the CNNEngine class.
    /// </summary>
    public CNNEngine()
    {
      if(ex_ != null)
      {
        throw ex_;
      }
    }


    #endregion Constructors

    #region Finalize

    /// <summary internal= "true">
    /// Class destructor called by the CLR garbage collector.
    /// </summary>
    ~CNNEngine()
    {
      Dispose(false);
    }


    /// <summary>
    /// Frees the native resources associated with this object
    /// </summary>
    public void Dispose()
    {
      Dispose(true);

      GC.SuppressFinalize(this);
    }


    /// <summary internal= "true">
    /// Internal dispose function
    /// </summary>
    protected virtual void Dispose(bool disposing)
    {
      if (!disposed)
      {
        disposed= true;

        if (disposing)
        {
          // Free managed resources;
        }

        // Free native resources
      }
    }


    #endregion Finalize

    #region Methods

    /// <summary>
    /// Provides a single output, 0-input MWArrayinterface to the predict_cnn MATLAB
    /// function.
    /// </summary>
    /// <remarks>
    /// </remarks>
    /// <returns>An MWArray containing the first output argument.</returns>
    ///
    public MWArray predict_cnn()
    {
      return mcr.EvaluateFunction("predict_cnn", new MWArray[]{});
    }


    /// <summary>
    /// Provides a single output, 1-input MWArrayinterface to the predict_cnn MATLAB
    /// function.
    /// </summary>
    /// <remarks>
    /// </remarks>
    /// <param name="filename">Input argument #1</param>
    /// <returns>An MWArray containing the first output argument.</returns>
    ///
    public MWArray predict_cnn(MWArray filename)
    {
      return mcr.EvaluateFunction("predict_cnn", filename);
    }


    /// <summary>
    /// Provides the standard 0-input MWArray interface to the predict_cnn MATLAB
    /// function.
    /// </summary>
    /// <remarks>
    /// </remarks>
    /// <param name="numArgsOut">The number of output arguments to return.</param>
    /// <returns>An Array of length "numArgsOut" containing the output
    /// arguments.</returns>
    ///
    public MWArray[] predict_cnn(int numArgsOut)
    {
      return mcr.EvaluateFunction(numArgsOut, "predict_cnn", new MWArray[]{});
    }


    /// <summary>
    /// Provides the standard 1-input MWArray interface to the predict_cnn MATLAB
    /// function.
    /// </summary>
    /// <remarks>
    /// </remarks>
    /// <param name="numArgsOut">The number of output arguments to return.</param>
    /// <param name="filename">Input argument #1</param>
    /// <returns>An Array of length "numArgsOut" containing the output
    /// arguments.</returns>
    ///
    public MWArray[] predict_cnn(int numArgsOut, MWArray filename)
    {
      return mcr.EvaluateFunction(numArgsOut, "predict_cnn", filename);
    }


    /// <summary>
    /// Provides an interface for the predict_cnn function in which the input and output
    /// arguments are specified as an array of MWArrays.
    /// </summary>
    /// <remarks>
    /// This method will allocate and return by reference the output argument
    /// array.<newpara></newpara>
    /// </remarks>
    /// <param name="numArgsOut">The number of output arguments to return</param>
    /// <param name= "argsOut">Array of MWArray output arguments</param>
    /// <param name= "argsIn">Array of MWArray input arguments</param>
    ///
    public void predict_cnn(int numArgsOut, ref MWArray[] argsOut, MWArray[] argsIn)
    {
      mcr.EvaluateFunction("predict_cnn", numArgsOut, ref argsOut, argsIn);
    }



    /// <summary>
    /// This method will cause a MATLAB figure window to behave as a modal dialog box.
    /// The method will not return until all the figure windows associated with this
    /// component have been closed.
    /// </summary>
    /// <remarks>
    /// An application should only call this method when required to keep the
    /// MATLAB figure window from disappearing.  Other techniques, such as calling
    /// Console.ReadLine() from the application should be considered where
    /// possible.</remarks>
    ///
    public void WaitForFiguresToDie()
    {
      mcr.WaitForFiguresToDie();
    }



    #endregion Methods

    #region Class Members

    private static MWMCR mcr= null;

    private static Exception ex_= null;

    private bool disposed= false;

    #endregion Class Members
  }
}
