//
// Global GL variables
//

GLTexture bloomMask, destTex;
GLTexture tex0, tex2, tex4, tex8, tex16;
GLTexture tmp2, tmp4, tmp8, tmp16;
GLTextureFilter extractBloom, blur, blend4, toneMap;

// glow texture params
float fx = 0.03;
float fy = 0.67;



//
// Set up the GL glow textures and shaders
// Should be in setup()
//

void setupGLGlow()
{
  // Loading required filters.
  extractBloom = new GLTextureFilter(this, "ExtractBloom.xml");
  blur = new GLTextureFilter(this, "Blur.xml");
  blend4 = new GLTextureFilter(this, "Blend4.xml");  
  toneMap = new GLTextureFilter(this, "ToneMap.xml");

  destTex = new GLTexture(this, width, height);

  // Initializing bloom mask and blur textures.
  bloomMask = new GLTexture(this, width, height, GLTexture.FLOAT);
  tex0 = new GLTexture(this, width, height, GLTexture.FLOAT);
  tex2 = new GLTexture(this, width / 2, height / 2, GLTexture.FLOAT);
  tmp2 = new GLTexture(this, width / 2, height / 2, GLTexture.FLOAT); 
  tex4 = new GLTexture(this, width / 4, height / 4, GLTexture.FLOAT);
  tmp4 = new GLTexture(this, width / 4, height / 4, GLTexture.FLOAT);
  tex8 = new GLTexture(this, width / 8, height / 8, GLTexture.FLOAT);
  tmp8 = new GLTexture(this, width / 8, height / 8, GLTexture.FLOAT); 
  tex16 = new GLTexture(this, width / 16, height / 16, GLTexture.FLOAT);
  tmp16 = new GLTexture(this, width / 16, height / 16, GLTexture.FLOAT);
}


//
// Apply the glow using textures and filters (GL shaders)
// Needs to be called after drawing to the offscreen graphics
//

void doGLGlow(GLGraphicsOffScreen offscreen)
{
  
  GLTexture srcTex = offscreen.getTexture();

// Extracting the bright regions from input texture.
  extractBloom.setParameterValue("bright_threshold", fx);
  extractBloom.apply(srcTex, tex0);

  // Downsampling with blur
  tex0.filter(blur, tex2);
  tex2.filter(blur, tmp2);        
  tmp2.filter(blur, tex2);

  tex2.filter(blur, tex4);        
  tex4.filter(blur, tmp4);
  tmp4.filter(blur, tex4);            
  tex4.filter(blur, tmp4);
  tmp4.filter(blur, tex4);            

  tex4.filter(blur, tex8);        
  tex8.filter(blur, tmp8);
  tmp8.filter(blur, tex8);        
  tex8.filter(blur, tmp8);
  tmp8.filter(blur, tex8);        
  tex8.filter(blur, tmp8);
  tmp8.filter(blur, tex8);

  tex8.filter(blur, tex16);     
  tex16.filter(blur, tmp16);
  tmp16.filter(blur, tex16);        
  tex16.filter(blur, tmp16);
  tmp16.filter(blur, tex16);        
  tex16.filter(blur, tmp16);
  tmp16.filter(blur, tex16);
  tex16.filter(blur, tmp16);
  tmp16.filter(blur, tex16);  

  // Blending downsampled textures.
  blend4.apply(new GLTexture[] {
    tex2, tex4, tex8, tex16
  }
  , new GLTexture[] {
    bloomMask
  }
  );

  // Final tone mapping into destination texture.
  toneMap.setParameterValue("exposure", fy);
  toneMap.setParameterValue("bright", fx);
  toneMap.apply(new GLTexture[] {
    srcTex, bloomMask
  }
  , new GLTexture[] {
    destTex
  }
  );
  }
