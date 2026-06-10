MedIm2025_Code_Binh_Bryan/
│
├── virtual_ct_gui.m % Main GUI (run this file)
├── run_virtual_ct_demo.m % Script to run full demo without GUI
│
├── ProjectFunctions/ % All helper functions
│ ├── apply_ramp_filter.m
│ ├── ct_forward_project.m
│ ├── ct_reconstruct.m
│ ├── generate_head_phantom.m
│ ├── image_difference.m
│ ├── investigate_ct_parameters.m
│ ├── make_circle_phantom.m
│ ├── make_rectangle_phantom.m
│ ├── profile_along_line.m
│ └── si_contrast.m
│
└── README.md

- How to Run the GUI (Recommended)

To run the interactive CT scanner GUI:
In the MATLAB Command Window, type:

```
virtual_ct_gui
```

The GUI window will open and allow:

Phantom selection
CT acquisition parameter control
Sinogram visualization
Reconstruction visualization
Profile and difference image analysis

- How to Generate Results in the Report

To reproduce the figures and experiments in the report:

Launch the GUI:

virtual_ct_gui

Select the phantom type:
Circular
Rectangular
Head (Shepp–Logan style)

Adjust acquisition parameters:

Angle step (e.g., 1°, 2°, 5°, 10°)
Number of detectors (e.g., 100, 200, 400)
Filter type (Ram-Lak, Hann, Hamming, None)

Run acquisition and reconstruction.

Observe:
Sinograms
Reconstructed images
Intensity profiles
Difference images

All results shown in the report were generated using this process.
