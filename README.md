# Gradient Based Stylized Shader

Shading model which remaps light values to gradient values. Perfect for art styles that are hard to describe with math.
<p align="center">
  <img src="https://github.com/MPrzekop/Gradient-based-stylized-shader/blob/images/Images/models.png" height="400" title="Image with guitar and can">
</p>
 

## Features
* Shader model based on [Blinn-Phong reflection model](https://en.wikipedia.org/wiki/Blinn%E2%80%93Phong_reflection_model) with added fresnel based smoothness, ambient lighting and fresnel highlights
* Selectable shader features (specular highlights, emission, ambient, fresnel)
* Normal/smoothness/emission map support
* Support for forward shading only
* All light types are supported with shadows
* Demo scene
 
## Instalation
### Package Manager

Go to `Window -> Package Manager` and add from git [URL](https://docs.unity3d.com/Manual/upm-ui-giturl.html) using this URL:
`https://github.com/MPrzekop/Gradient-based-stylized-shader.git`

### Demo resources

In the Samples folder there is a demo package containing 2 scenes, 14 materials and 6 sample gradients.

## How To Use

<p align="center">
  <img src="https://github.com/MPrzekop/Gradient-based-stylized-shader/blob/images/Images/Editor.png" width="400" title="Material inspector">
</p>

### New Material
Create material using `Przekop/Custom Lighting/Gradient Shading` shader, it will be set up with basic gradients.

### Or just duplicate demo materials
Demo materials represent some usecases, from standard shaders to toon, or reverse toon.


## Notes
* Shader was developed with Amplify Shader Editor and can be opened and edited with ASE.
* Very useful plugin when working with this shader: [mitay-walle / GradientTexture](https://github.com/mitay-walle/GradientTexture)
* Models in 'Models Demo Scene' are from [The Base Mesh](https://thebasemesh.com/model-library)

## Screenshots
<p align="center">
  <img src="https://github.com/MPrzekop/Gradient-based-stylized-shader/blob/images/Images/Point.gif" width="400" title="point lights demo">
  <img src="https://github.com/MPrzekop/Gradient-based-stylized-shader/blob/images/Images/Cover.gif" width="400" title="Spheres with different materials on them">
</p>
