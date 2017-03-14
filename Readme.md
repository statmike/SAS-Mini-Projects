# SAS-Mini-Projects
A library of SAS Examples.  

## Contribute
Have something to add?  Just fork it, change it, and create a pull request!

Have comments, questions, suggestions? Just use the issues feature here in github

## How to use this repository
Each subfolder contains a project.  Each project has its own readme file and folder structure.  Some projects will reference other projects for components.

## Layout
The folder structure for this repository is:
* Repository
	* Project
		* Readme file
		* `Example.sas` file
		* `/Macros` Folder

## Considerations
I built these projects using my local PC based install of SAS.  For this reason the file references are windows format.  To replicate my setup on your machine you can store this repository in:

```
C:\PROJECTS
```

To move this project to another operating environment or path you need to change any paths defined by `libname` and `filename` statements.  I store any hardcoded paths at the top of `.sas` files.  I never hardcode paths inside of macros.

## Using Macros
As shown in the *Layout* section, macros are stored in subfolders named `/Macros`. To make these available to a SAS session these folders can be setup as autocall locations.  In the [Organizing Macros](./Organizing Macros) project there is a macro, `%define_autocalls`, that makes this easy.  To use this macro, manually add the location of the `/Macros` folder for *Organizing Macros* so that it can be called for the entire `C:\PROJECTS` folder structure.

Add these lines to the users autoexec.sas file:
```sas
options sasautos=("C:\PROJECTS\SAS-Mini-Projects\Organizing Macros\Macros" SASAUTOS);
%define_autocalls(C:\PROJECTS,SUB=Y);
```

## Projects
* [Disproportionality Measures](./Disproportionality Measures/): PRR, RR, IC, EBGM (MGPS) and more
* [Organizing Macros](./Organizing Macros/): workflow and macros for macros
* [PROC MCMC Notes](./PROC MCMC Notes/): Key links and notes for all versions of PROC MCMC
