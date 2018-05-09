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
* [Disproportionality Measures](./Disproportionality%20Measures): PRR, RR, IC, EBGM (MGPS) and more
* [Organizing Macros](./Organizing%20Macros): workflow and macros for macros
* [PROC MCMC Notes](./PROC%20MCMC%20Notes): Key links and notes for all versions of PROC MCMC
* [Update .sas files when data moves](./Move%20SAS): Automatically update all of your .sas files so they work when you move your data source(s) 
* Coming Soon:
	* [Log Parsing](./Log%20Parsing): Coming Soon! How to examine logs for code efficiency opportunities
	* [Proc FCMP](./Proc%20FCMP): Coming Soon! The power to build your own functions
	* [Parallel Computing and Threading in SAS](./Parallelism): Coming Soon! How to create parallelism and trigger threading in your code
		* [SAS Connect & SAS Grid Manager](./Connect): Coming Soon! Running Jobs and steps in parallel with just a few coding skills
		* [Threading in SAS Procs](./Threading): Coming Soon! Unlocking the power of threading in SAS Procedures
		* [Proc DS2](./Proc%20DS2): Coming Soon! Add threading to your data step
		* [SAS Viya Data Step](./Viya%20Data%20Step): Coming Soon! Automatic threading of SAS Data Steps!!
	* [ODS Notes and Default SAS Output Across Versions and Interfaces](./ODS%20notes): Coming Soon!
	* [Using GitHub with SAS - My Workflow(s)](./GitHub%20and%20SAS): Coming Soon!
