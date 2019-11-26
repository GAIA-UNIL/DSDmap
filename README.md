# DSDmap

The DSDmap is a Matlab code allowing elaborating a Debris Size Distribution map.
It is the result of the study submitted to Geomorphology Journal:
  "Large scale debris size mapping in alpine environment using UAVs imagery"
  Authors: E. Giaccone, C. Lambiel, G. Mariéthoz

Context: The study of debris size in alpine environments can inform a range of processes such as ground thermal regimes or the mechanisms behind plant colonization. Here we develop a new methodological approach based on optical high-resolution imagery on a large scale, such as acquired by Unmanned Aerial Vehicles (UAVs), to map the debris size distribution (DSD). The orthomosaics acquired by UAVs are processed with algorithms that were initially designed to analyze close-up images of fluvial gravel beds (Basegrain algorithms - Detert and Weitbrecht 2012, 2013). Direct application of these methods to large scale imagery generates artifacts related to the presence of e.g. shadows, vegetation, or snow. For this reason, we propose a processing workflow that addresses these issues and produces maps of DSD that are validated against individual debris measured manually. Our goal is to propose a methodology able to exploit UAVs image covering other landforms where debris are visible, such as talus slopes, rock glaciers or moraine deposits, as well as other environments like deserts or river beds. 

The main folder includes the Matlab code "DSD_map.m" and two folders containing the data from the two focus sites where we trained the methodology ("Martinets" and "Outans") and a folder "UAVs data" with the original orthomosaics and digital surface models employed to develop the methodology.

Because of the file size, the folder "UAVs data" with the original orthomosaics and digital surface models employed to develop the methodology and the two images "Martinets_img.tif" and "Outans_img.tif" are available [here](https://drive.google.com/drive/folders/17XHSAgF0lsa0tEwKcVHydkAI_qjO2_R7?usp=sharing)
Once downloanded, the images have to be moved in the corresponding folder before running the Matlab code. 
