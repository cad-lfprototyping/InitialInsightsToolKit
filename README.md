# InitialInsights
InitialInsights is a tabletop toolkit  for synchronous collaboration in rapid prototyping.
## Necessary Hardware
 
For the development of InitialInsights the following hardware has been used:
- Desktop Computer
  - Specifications: Windows 64-bit, 8 GB RAM, Intel i7 3.61 GHz
- HD Projector
  - Resolution: 1920 x 1200 pixels
- Kinect for XBox One
  - RGB-depth camera: 1080p, 30Hz (15 Hz in low light)
- Simple wooden table as projecting surface
 
*Note: To run InitialInsights the aforementioned hardware specs are recommended, but not required.*
## Tabletop Setup

The  projector and the Kinect device need to be positioned in a relative height and perpendicular to the table, for the table to be used as a projecting surface. The Kinect and projector also have a relative distance amongst them. Both devices (projector & Kinect )  need to be connected to the same computer. A sample setup is shown in the figure below.


![Alt text](cad.png?raw=true "Tabletop setup")

## Running InitialInsights

To run the toolkit, Processing version 3 or higher should be installed on your computer (currently our toolkit has been tested only on Windows 10). You can download Processing from https://processing.org/download/.
Having downloaded and installed processing, the libraries used by InitialInsights need to also be installed:
- OpenCV (download from: http://ubaa.net/shared/processing/opencv/)
- FingerTracker (download from: http://makematics.com/code/FingerTracker/)
- PixelFlow (download from: http://thomasdiewald.com/processing/libraries/pixelflow/)
- KinectPV2 (download from: http://codigogenerativo.com/code/kinectpv2-k4w2-processing-library/)

After downloading and installing the libraries, to run the toolkit simply put all the InitialInsights files under a single directory and run Main.pde file.

### Config.json

Default values with respect to our configuration of tabletop, are set in the Config.json file. For instance, the *x* and *y* coordinates of projector's viewport, which is correlated with the distance of projector from the table, can be modified respectively for any configuration in this file.
Button sizes are determined here, thus can be altered from this file.
Other constants, such as the size of the circles, which represent the pedestrians in the example, can be modified from Config.json, as well.

## Software
 
For software implementation of the application, the following setup has been used:
- Language: Processing 3
- Libraries
  - OpenCV
  - FingerTracker [1]
  - PixelFlow [2]
  - KinectPV2 [3]
 
Basically, the application takes the user input through Kinect and sends the output to the projector. To do this, the modules described below are needed.

*Note: The files have been split into subdirectories for ease of understanding. In order to run, when downloaded they should all be put into a single directory.*
  
### Input & Object Detection
A thread in InitialInsights continuously scans and processes the infrared and depth maps provided by Kinect in order to locate and track the changes that happen in the viewport for a determined time interval. To do this the delta of the depth and the infrared images is computed for each time interval. The fused (under bitwise OR operation) image of the two delta images (infrared and depth) is then fed to the FingerTracker module. With the help of this module, the nearby pixels of the index finger are considered as target of the user.
 
In a similar fashion, the physical objects are detected based on the difference of the depth and infrared maps.
 
### Buttons 
 
In InitialInsights, buttons are represented as geometrical objects. Each of the buttons is associated with a corresponding listener, which is activated when the user touches the respective region. Since each of the buttons has a separate listener, InitialInsights makes a multiple user interaction possible.  
 
 
### Example: *Residential Area Design Prototype*
 
To demonstrate an application of InitialInsights toolkit, we have chosen an example of residential area design. Additional modules, thus have been implemented specifically for this example, namely Pedestrian Movements & Windflow and Exposure Prediction.
 
### Pedestrian Movements
 
Pedestrians are represented as two dimensional objects (i.e. circles) moving from source to destination locations. The locations are the physical objects on the table. Pedestrians are ‘aware’ of the objects and they find the shortest path to the destination location, by avoiding the obstacles on the way. To do this, the map is considered as a maze where each square grid is 1 pixel.  Then, A* algorithm is run for each pedestrian where the goal is the destination location, whereas the starting point is source location. 
 
### Windflow and Exposure Prediction
 
Wind flow model has been implemented using PixelFlow library. The library manages thousands of wind force vectors uniformly distributed on the viewport. For our residential area prototyping setup, we utilized those vectors in order to calculate accumulated wind exposure levels for different parts of the viewport. The wind exposure levels are then visualized via a heatmap ranging from black to red colors in order to represent the range from low and high level of exposure.
 
### Demo

https://www.dropbox.com/s/gsx8bok9h4tk168/Submission_18.mp4
 
 
## References:
- [1] FingerTracker library for processing. http://makematics.com/code/FingerTracker/ ; 2017. Accessed: 2017-04-23.
- [2] Pixelflow: A processing library for high performance gpu-computing (glsl). http://thomasdiewald.com/processing/libraries/pixelflow/ ; 2017. Accessed: 2017-04-23.
- [3] KinectPV2. http://codigogenerativo.com/code/kinectpv2-k4w2-processing-library/ ;2017. Accessed: 2017-06-13.


