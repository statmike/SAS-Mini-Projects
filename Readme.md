#SAS-Mini-Projects
A library of SAS Examples.  

##Contribute
Have something to add?  Just fork it, change it, and create a pull request!

Comments, questions, suggestion? Just use the issues feature here in github

##How to use this repository
Each subfolder contains a project.  Each project has its own readme file and folder structure.  Some project will reference other projects for components.

##Layout
The folder structure for this repository is:
* Repository
	* Project
		* Readme file
		* Example.sas file
		* Macros Folder

##Considerations
I built these projects using my local PC based install of SAS.  For this reason the file references are windows format.  To replicate my setup on your machine you can store this repository in

> C:\PROJECTS

To move this project to another operating environment you need to change any paths used in libnames and filerefs.  I store any hardcoded paths at the top of .sas files.  I never hardcode paths inside of macros.

##Using Macros

##Projects
* [Disproportionality Measures](https://github.com/statmike/SAS-Mini-Projects/tree/master/Disproportionality%20Measures): PRR, RR, IC, EBGM (MGPS) and more
* [Organizing Macros](https://github.com/statmike/SAS-Mini-Projects/tree/master/Organizing%20Macros): workflow and macros for macros
