# Video Capture & Stream Synchronizer

This repository provides two modules. One for extracting motion vector fields from H.264 encoded video streams and a second one for synchronization of multiple RTSP video streams. The synchronization module depends on the timestamps generated by the video capture module. The modules are implemented in C++ and Python bindings are provided.

## Video Capture Module with H.264 Motion Vector Extraction

##### Purpose

This modules provides a `VideoCap` class for reading frames, motion vectors and frame types (I, P, B, etc.) from H.264 encoded video streams. Both video files and RTSP streams (e.g. from an IP camera) are supported. Under the hood [FFMPEG](https://github.com/FFmpeg/FFmpeg) is used and the interface and functionality are similar to the OpenCV [VideoCapture](https://docs.opencv.org/4.1.0/d8/dfe/classcv_1_1VideoCapture.html) class.

![motion_vector_demo_image](mvs.png)

What follows is a short explanation of the data returned by the `VideoCap` class. Apart from this less obvious data the current video frame is returned.

##### Motion Vectors

H.264 uses different techniques to reduce the size of a raw video frame prior to sending it over a network or storing it into a file. One of those techniques is motion estimation and prediction of future frames based on previous or future frames. Each frame is split into 16 pixel x 16 pixel large macroblocks. During encoding motion estimation matches every macroblock to a similar looking macroblock in a previously encoded frame (note that this frame can also be a future frame since encoding and playout order might differ). This allows to transmit only those motion vectors and the reference macroblock instead of all macroblocks, effectively reducing the amount of transmitted or stored data. <br>
Motion vectors correlate strong with motion in the video scene and are useful for various computer vision tasks, such as optical tracking.

##### Frame Types

The frame type is either "P", "B" or "I" and refers to the H.264 encoding mode of the current frame.  Each frame

Note that for "I" frames

##### Timestamps

In addition to extracting motion vectors and frame types, the video capture class also outputs a UNIX timestamp representing UTC wall time for each frame. If the stream originates from a video, this timestamp is simply derived from the current system time. However, when an RTSP stream is used as input, the timestamp calculation is more intricate as the timestamps represents not the time when the frame was received, but the time when the frame was send by the sender. Thus, this timestamp can later be used for accurate synchronization of multiple video streams.









## Synchronization Module


## Debug

gdb -ex r --args python3 stream_sync_test.py


## Installation


This library provides methods to extract motion vectors and frame types (I, P, B, etc.) from H.264 encoded video streams. It is based on the [FFMPEG library](https://github.com/FFmpeg/FFmpeg) for management of the stream and frame decoding. The library consists of a single classed called `VideoCap` with an interface similar to the OpenCV [VideoCapture](https://docs.opencv.org/4.1.0/d8/dfe/classcv_1_1VideoCapture.html) class.

Implementations for both C++ and Python are provided.

![motion_vector_demo_image](mvs.png)


## Quickstart

To run the code you need Ubuntu 18.04 with Python, Docker and `docker-compose` installed. To install Python run
```
$ sudo apt-get update && apt-get -y upgrade && apt-get install -y python3-dev python3-pip
```
Afterwards, follow [these steps](https://docs.docker.com/install/linux/docker-ce/ubuntu/) to setup Docker and [these](https://docs.docker.com/compose/install/) to install `docker-compose`.


### Get the Files

Either download the files as `zip` archive and extract them to the desired location or open a terminal and clone the repo with
```
$ git clone https://github.com/LukasBommes/Motion-Vector-Extractor-H264.git
```


### Build the Docker Container

In the project's root directory run
```
$ sudo docker-compose build
```
This will build the container image containing all the dependencies (Python, OpenCV, FFMPEG) needed to run the code.


### Start the Docker Container

After the build is complete run
```
$ xhost +
```
to allow GUI output on the host machine and
```
$ sudo docker-compose up
```
to start the container. This will first compile all the binaries and then start a jupyter lab session.


### Access the Jupyter Lab Example

The docker container runs a jupyter lab server which can be used for experiments with the library. It also contains an example of how to use the library. After starting the container, you should see an url similar to this one (the token will differ)
```
http://127.0.0.1:8888/?token=fca10ac86ee28896f3accbfe5eefbfe79236dad4d1b51238
```
in the terminal. Copy the url from into a browser to access jupyter lab. In jupyter lab open the `example.ipynb` to see an example of how to use the library.


## Running the Other Examples

The project folder comes with two other example files showing how to use the library in a stand-alone Python script and a C++ program. To run these examples you need to open a new terminal in the project's root and start an interactive shell session in the docker container by typing
```
$ sudo docker exec -it h264extract bash
```
Now, you can run the Python demo script in `main.py` with
```
$ python3 main.py
```
or the C++ example in `main.cpp` with
```
$ ./main
```
If you make changes to the source of the example you need to rebuild the binary with the following command (inside the container)
```
$ g++ -I ~/boost -I /usr/include/python3.6m/ -fpic main.cpp video_cap.cpp -o main -L ~/boost/stage/lib -lboost_python36 -lboost_numpy36 -lpython3.6m `pkg-config --cflags --libs libavformat libswscale opencv4` -Wl,-Bsymbolic
```


## Files

This list briefly explains the files in this project directory.

###### Docker related files
- *Dockerfile*: The Docker image. It starts from the Ubuntu 18.04 base image and installs OpenCV, FFMPEG and Boost.Python
- *docker-compose.yml*: The container orchestration script. It defines the startup command and host volumes mounted into the container.
- *docker-entrypoint.sh*: The entrypoint script which is run every time the docker container is started. Here, the binaries are compiled.
- *requirements.txt*: List of Python packages which are installed inside of the container. If you change this list you need to rebuild the container image.

###### Library Files
- *video_cap.hpp*: The C++ header file of the `VideoCap` class. Refer to the this file for the API documentation.
- *video_cap.cpp*: The C++ source code of the `VideoCap` class.
- *h264extract.cpp*: A Boost.Python wrapper around the `VideoCap` class. This enables to call the class from Python.

###### Usage Examples
- *lab/example.ipynb*: IPython script showing how to use the library.
- *main.cpp*: C++ source showing how to use this library.
- *main.py*: Python script showing how to use this library.
- *vid.mp4*: A H.264 encoded example video clip.


## Python API

#### Class :: VideoCap()

| Methods | Description |
| --- | --- |
| VideoCap() | Constructor |
| open() | Open a video file or url |
| read() | Get the next frame and motion vectors from the stream |
| release() | Close a video file or url and release all ressources |

##### Method :: VideoCap()

Constructor. Takes no input arguments.

##### Method :: open()

Open a video file or url. The stream must be H264 encoded. Otherwise, undesired behaviour is
likely.

| Parameter | Type | Description |
| --- | --- | --- |
| url | string | Relative or fully specified file path or an url specifying the location of the video stream. Example "vid.flv" for a video file located in the same directory as the source files. Or "rtsp://xxx.xxx.xxx.xxx:554" for an IP camera streaming via RTSP. |

| Returns | Type | Description |
| --- | --- | --- |
| success | bool | True if video file or url could be opened sucessfully, false otherwise. |


##### Method :: read()

Get the next frame and motion vectors from the stream. Requires the media file to be open. This function should be called in a loop and break the loop once the end of the stream is reached.

Takes no input arguments and returns a boost::python::tuple with four elements as in the table below.

| Index | Name | Type | Description |
| --- | --- | --- | --- |
| 0 | success | bool | False in case the read did not succeed or the end of stream is reached, true if a frame could be decoded successfully. When false, the other tuple elements are set to 0. |
| 1 | frame | boost::python::ndarray | Array of dtype uint8_t shape (w, h, 3) containing the decoded video frame. w and h are the width and height of this frame in pixels. If no frame could be decoded an empty numpy ndarray of shape (0, 0, 3) and dtype uint8_t is returned. |
| 2 | motion vectors | boost::python::ndarray | Array of dtype int64 and shape (N, 11) containing the N motion vectors of the frame returned in ret[1]. Each row in the array is a single motion vector. The columns contain the following data: <br>- 0: source: Where the current macroblock comes from. Negative value when it comes from the past, positive value when it comes from the future.<br>- 1: w: Width and height of the vector's macroblock.<br>- 2: h: Height of the vector's macroblock.<br>- 3: src_x: x-location of the vector's origin in source frame (in pixels).<br>- 4: src_y: y-location of the vector's origin in source frame (in pixels).<br>- 5: dst_x: x-location of the vector's destination in the current frame (in pixels).<br>- 6: dst_y: y-location of the vector's destination in the current frame (in pixels).<br>- 7: motion_x: src_x = dst_x + motion_x / motion_scale<br>- 8: motion_y: src_y = dst_y + motion_y / motion_scale<br>- 9: motion_scale: see definiton of columns 7 and 8<br>- 10: flags: currently unused<br>This data is equivalent to FFMPEG's [AVMotionVector](https://ffmpeg.org/doxygen/4.1/structAVMotionVector.html) class. If no motion vectors are present in a frame, e.g. if the frame is an `I` frame an empty numpy array of shape (0, 11) and dtype int64 is returned. |
| 3 | frame_type | char | single character representing the type of frame. Can be `I` for a keyframe, `P` for a frame with references to only past frames and `B` for a frame with references to both past and future frames. A value of `?` indicates an unknown frame type. |


##### Method :: release()

Close a video file or url and release all ressources. Takes no input arguments and returns nothing.


## C++ API

The C++ API differs from the Python API in what parameters the methods expect and what values they return. Refer to the demo in `main.cpp` for examples how to use the API.


## What are Frame Types and Motion Vectors in H264?

Refer to this [excellent book](http://last.hit.bme.hu/download/vidtech/k%C3%B6nyvek/Iain%20E.%20Richardson%20-%20H264%20%282nd%20edition%29.pdf) by Iain E. Richardson.


## About

This software is written by **Lukas Bommes, M.Sc.** - [A*Star SIMTech, Singapore](https://www.a-star.edu.sg/simtech)<br>
It is based on the MV-Tractus tool which can be found in this [Github repository](https://github.com/jishnujayakumar/MV-Tractus/tree/master/include).


#### License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
