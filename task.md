A colleague has started a new ML project at /root/code/fraud-detection/, but the layout does not match the xFusionCorp Industries standard. Bring the project in line with the team's conventions.


Inspect the existing project at /root/code/fraud-detection/.

The final layout must match the tree below exactly:

fraud-detection/
├── data/
│   ├── raw/
│   └── processed/
├── models/
├── notebooks/
├── src/
│   ├── data/
│   ├── features/
│   ├── models/
│   └── utils/
├── tests/
├── configs/
├── requirements.txt
└── README.md

Every subdirectory under src/ must contain an __init__.py file so that Python recognises it as a package.

requirements.txt must list the following dependencies, one per line: scikit-learn, pandas, numpy, and mlflow. The canonical PyPI name for the scikit-learn package is scikit-learn.

README.md must begin with the heading # fraud-detection.

Review the existing project and correct everything that does not match the requirements above.
