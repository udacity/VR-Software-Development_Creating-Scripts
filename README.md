# Creating Scripts
Course asset for the Udacity [VR Developer Nanodegree](http://udacity.com/vr) program.

- Course: VR Software Development
- Lesson: Creating Scripts


### Versions Used
- [Unity LTS Release 2017.4.15](https://unity3d.com/unity/qa/lts-releases?version=2017.4)
- [GVR SDK for Unity v1.170.0](https://github.com/googlevr/gvr-unity-sdk/releases/tag/v1.170.0)


### Directory Structure
- The Unity project is the child directory of the repository and named according to the associated lesson.
- The Unity project is 'cleaned' and includes the `Assets` folder, the `ProjectSettings` folder, and the `UnityPackageManager` folder.

>**Note:** Contrary to best practice, the Unity project also includes two files from the project's Library folder. The reason for this is explained in the [Included Unity Library Folder Items](#included-unity-library-folder-items) section below.


### Unity Project Settings
- The project's `Player Settings` and `Quality Settings` are set to default values for the Unity version used.

>**Important!** When deploying to device, make sure you configure the `Player Settings` for the target platform according to what you learned in the previous courses.

>**Note:** When deploying to device, it is recommended to update the `Quality Settings` according to what you learned in the previous courses.


### Unity Lighting Settings
- The scene's `Lighting Settings` are set to default values for the Unity version used.

>**Note:** When deploying to device, it is recommended to update the `Lighting Settings` as well as optimize the scene according to what you learned in the previous courses.


### GVR SDK for Unity
- `GoogleVR` > `Demos` is not included.
- `GoogleVR` > `GVRVideoPlayer.unitypackage` is included.
- The `Max Reticle Distance` value for the `GvrReticlePointer` used in the scene is set to `20` instead of the default `10`.
- Scripts applicable to the course have been updated to reflect Unity's API change from `UnityEngine.VR` to `UnityEngine.XR`.

>**Note:** If for any reason you remove and re-import GVR SDK for Unity v1.170.0, make sure you accept any API update pop-up prompts triggered by Unity. Alternatively, you can manually run the API updater (Unity menu `Assets` > `Run API Updater...`) after the import has completed.


### Included Unity Library Folder Items
- The Unity generated file `Library` > `LastSceneManagerSetup.txt` is included to force the default scene to load when opening the Unity project for the first time.
- The Unity generated file `Library` > `CurrentLayout.dwlt` is included to force the Unity workspace layout and scene view orientation to be similar to the what's shown during the lesson when opening the Unity project for the first time.

>**Note:** After loading the Unity project for the first time, the included Unity workspace layout and scene view orientation, which is stored in the `CurrentLayout.dwlt` file, will be lost if you change the workspace layout or scene view orientation.

> **Tip:** You can save the Unity workspace layout and restore it any time by expanding the `Layout` drop-down (found at the top right of the Toolbar) and choose `Save Layout…`, then name your new layout and save it. To restore the layout, choose it from the `Layout` drop-down.


### Related Repositories
- VR Software Development - Creating Scripts
- [VR Software Development - Controlling Objects Using Code](https://github.com/udacity/VR-Software-Development_Controlling-Objects-Using-Code/releases)
- [VR Software Development - VR Interaction](https://github.com/udacity/VR-Software-Development_VR-Interaction/releases)
- [VR Software Development - Programming Animations](https://github.com/udacity/VR-Software-Development_Programming-Animations/releases)
- [VR Software Development - Physics and Audio](https://github.com/udacity/VR-Software-Development_Physics-and-Audio/releases)
- [VR Software Development - Advanced VR Scripting](https://github.com/udacity/VR-Software-Development_Advanced-VR-Scripting/releases)
- [VR Software Development - A Maze](https://github.com/udacity/VR-Software-Development_A-Maze/releases)
