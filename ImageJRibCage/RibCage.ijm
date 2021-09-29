// Ribcage suppression by statistical elimination of rough Radon's laplacians in CPU.
// --This package (consisting of script<s> & binary<ies>"): 
//  - primarily targets developer's cognitive interest;
//  - assumes BSD-license (free usage,distribution; without warranties);
// -- The binaries aren't an open source. 

macro "RibCage" { // begin of the macro 

  // -- checkoops
  requires( "1.53k" ); // refer "https://imagej.nih.gov/ij/download.html", "Windows"
  list = getList( "image.titles" ); if (list.length<1)
    exit( "applies to active16-bit image // but no opened image" );
  nam_cur = getInfo( "image.filename" );
  if (startsWith( nam_cur, "$" ))
    exit( "applies once // but "+nam_cur+" seemingly is processed" );
  if (bitDepth()!=16) 
    exit( "requires 16-bit // but "+nam_cur+" is "+bitDepth()+"-bit" );
  W=getWidth(); H=getHeight();
  if (W<1999 || W>4999 || H<1999 || H>4999)
    exit( "frame ~43x43cm, pix_pitch~0.12mm, sizes 1999..4999 // but "+nam_cur+" is "+W+"x"+H );
  nam_exe = File.getDirectory( getInfo("macro.filepath") )+"RibCage.exe";
  if (!File.exists ( nam_exe )) nam_exe = "C:\\ImageJRibCage\\RibCage.exe";
  if (!File.exists( nam_exe )) nam_exe = File.openDialog( "Locate RibCage.exe" );

  //-- dialog
  Dialog.create( "RibCage for "+ nam_cur );
  getStatistics( stt_n, stt_av, stt_mn, stt_mx ); 
  Dialog.addMessage( "Image "+W+"x"+H+"  "+stt_mn+" < "+stt_av+" < "+stt_mx
    +"\nSelect categories of rough Radon's laplacians to"
    +"\neliminate. That will take 5..30s." );
  Dialog.addCheckbox( "#1 Descend periph_to_cen // clavicle, prominent ribs", true );
  Dialog.addCheckbox( "#2 Arc-shapes '~^' // posteriors", true );
  Dialog.addCheckbox( "#4 Concave-shapes '~v' // clavicle, anteriors", true );
  Dialog.addString( "Suffix // default empty:", "" );
  Dialog.show(); adj = 0;
  if (Dialog.getCheckbox()) adj = adj|1;
  if (Dialog.getCheckbox()) adj = adj|2;
  if (Dialog.getCheckbox()) adj = adj|4;
  nam = "$"+W+"x"+H+Dialog.getString(); 
  nam_inp = nam+".raw"; 
  nam_out = nam+"_00.raw";

  //-- execution
  setBatchMode( true );
    print( "\\Clear" );  print( "- checked options code #"+adj+" // for "+nam_cur );
    print( "- "+nam_inp+" // duplicate current image" );
  run( "Duplicate...", "title="+nam_inp ); selectWindow( nam_inp );
    print( "- IntelByteOrder // in Edit>Options>InputOutput>Save" );
  saveSettings(); run( "Input/Output...", "save" );
  save( nam_inp ); restoreSettings(); close();
    print( "- waiting for "+nam_out+"... // it takes 5..30s" );
  exec( nam_exe, W, H, nam_inp, "0", "100"+adj, "204" );
  setBatchMode( false );

  //-- open the output<s>
  getMinAndMax( dsp_min, dsp_max ); 
    print( "- open "+nam_out+" // "+dsp_min+".."+dsp_max );
  run( "Raw...", "open="+nam_out+" image=[16-bit Unsigned] width="+W+" height="+H+" little-endian" );
    print( "- delete //"+nam_inp+","+nam_out ); 
  setMinAndMax( dsp_min, dsp_max ); File.delete( nam_inp ); File.delete( nam_out );
    if (isOpen( "Log" )) { selectWindow( "Log" ); run( "Close" );   }

} // end of macro "RibCage"
