// Ribcage suppression by statistical elimination of rough Radon's laplacians in CPU.
macro "RibCage" { // begin of the macro 

  // -- checkoops
  requires( "1.53k" ); // refer "https://imagej.nih.gov/ij/download.html", "Windows"
  list = getList( "image.titles" ); if (list.length<1)
    exit( "It applies to active (16bit preferably) image.\nBut no one." );
  nam_cur = getInfo( "image.filename" );
  if (startsWith( nam_cur, "$" ))
    exit( "It applies once.\nBut "+nam_cur+" seemingly is processed." );
  bdh = bitDepth(); if (bdh!=16 && bdh!=8) 
    exit( "It requires 16bit (8bit at least).\nBut "+nam_cur+" is "+bitDepth()+"bit" );
  W=getWidth(); H=getHeight();
  if (W<1999 || W>4999 || H<1999 || H>4999)
    exit( "It requires frame ~43x43cm, pix_pitch~0.12mm, sizes 1999..4999.\nBut "+nam_cur+" is "+W+"x"+H );
  nam_exe = File.getDirectory( getInfo("macro.filepath") )+"RibCage.exe";
  if (!File.exists ( nam_exe )) nam_exe = "C:\\ImageJRibCage\\RibCage.exe";
  if (!File.exists( nam_exe )) nam_exe = File.openDialog( "Locate RibCage.exe" );

  //-- dialog
  Dialog.create( "RibCage for "+ nam_cur );
  if (bdh!=16)
    Dialog.addMessage( "Diagnostic industry-standard is 16bit. "+bdh+"bit voids output." );
  getStatistics( stt_n, stt_av, stt_mn, stt_mx ); 
  Dialog.addMessage( "inp Image "+W+"x"+H+"  "+stt_mn+" < "+stt_av+" < "+stt_mx
    +"\nCalc rough (by 8 dirs) descending Radon's laplapsians"
    +"\n(preserving checked ~intercostals). Multiply the laps"
    +"\nby 'Strength+const. Then subtract from original." );
  Dialog.addCheckbox( "~arc (posteriors)", true );
  Dialog.addCheckbox( "~concaves (clavicle, anteriors)", true );
  Dialog.addSlider( "Strength", 0,15, 8 );
  Dialog.addString( "Out's suffix (empty default):", "" );
  Dialog.show();  adj = 0;
  if (Dialog.getCheckbox()) adj = adj|16;
  if (Dialog.getCheckbox()) adj = adj|32;
  adj = adj|Dialog.getNumber();
  nam = "$"+W+"x"+H+Dialog.getString(); 
  nam_inp = nam+".raw"; 
  nam_out = nam+"_00.raw";

  //-- execution
  setBatchMode( true );
    print( "\\Clear" );  print( "- checked options code #"+adj+" // for "+nam_cur );
    print( "- "+nam_inp+" // duplicate current image" );
  run( "Duplicate...", "title="+nam_inp ); selectWindow( nam_inp );
    print( "- IntelByteOrder // in Edit>Options>InputOutput>Save" );
  if (bdh==8) run("16-bit"); // -- aux convesion 8bit=>16
  saveSettings(); run( "Input/Output...", "save" );
  save( nam_inp ); restoreSettings(); close();
    print( "- waiting for "+nam_out+"... // it takes 5..30s" );
  exec( nam_exe, W, H, nam_inp, "00", "10"+toHex(adj), "204" );
  setBatchMode( false );

  //-- open the output<s>
  getMinAndMax( dsp_min, dsp_max ); 
    print( "- open "+nam_out+" // "+dsp_min+".."+dsp_max );
  run( "Raw...", "open="+nam_out+" image=[16-bit Unsigned] width="+W+" height="+H+" little-endian" );
    print( "- delete //"+nam_inp+","+nam_out ); 
  setMinAndMax( dsp_min, dsp_max );
  //File.delete( nam_inp ); File.delete( nam_out );
  if (bdh==8) run("8-bit"); // -- aux convesion 16bit=>8
  if (isOpen( "Log" )) { selectWindow( "Log" ); run( "Close" );   }

} // end of macro "RibCage"
