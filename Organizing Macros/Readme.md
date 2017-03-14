# Organizing Macros
The goal of this project is to create code and macros that make macros easy to deploy in your SAS environment across the different scopes of macro usage in projects.

## Quick Start:

* [`/Macros`](./Macros)
  * [`%include_folder`](./Macros/include_folder.sas)
    * Does a `%include` for all .sas files in the input directory
    * Inputs:
      * `dir` = directory path
      * `SUB=`
        * `N` (default) to include all `*.sas` files in the path specified as `dir`
        * `Y` to include all `*.sas` files in subfolders of `dir` named `/Macros` (any case) - this includes the directory path if it is named `/Macros`
      * `SOURCE2=`
        * `N` (default) log will not print contents of `%included` files
        * `Y` log will print contents of `%include` files
  * [`%combine_macros`](./Macros/combine_macros.sas)
    * Combines all the `*.sas` files in the input directory into a single filed named `allmacros.sas`
      * `dir` = directory path
      * `file=` is the name of the combined file (default=`allmacros`) - you do not need to write `.sas` file extention
      * `SUB=`
        * `N` (default) to include all `*.sas` files in the path specified as `dir`
        * `Y` to include all `*.sas` files in subfolders of `dir` named `/Macros` (any case) - this includes the directory path if it is named `/Macros`
  * [`%define_autocalls`](./Macros/define_autocalls.sas)
    * Adds the input directory to the SASAUTOS definition using `Options SASAUTOS=`
      * `dir` = directory path
      * `SUB=`
        * `N` (default) add the path specified as `dir` only
        * `Y` to include all paths for subfolders of `dir` named `/Macros` (any case) - this includes the directory path if it is named `/Macros`
      * `level=session`
* Examples:
  * Review code in [`example runs.sas`](example runs.sas)

## Background
Good information for using and managing SAS macros is found in the SAS documentation:

* [Overall Link](https://support.sas.com/documentation/cdl/en/mcrolref/67912/HTML/default/viewer.htm#bookinfo.htm)
  * [Storing and Reusing Macros](https://support.sas.com/documentation/cdl/en/mcrolref/67912/HTML/default/viewer.htm#n01bfugbyvoyvmn1s2xghj1q1r2s.htm)
  * [Efficiency and Portability](https://support.sas.com/documentation/cdl/en/mcrolref/67912/HTML/default/viewer.htm#p04s69a9d2x7cnn1iukqe9zn4bo5.htm)
  * [How macros processing works](https://support.sas.com/documentation/cdl/en/mcrolref/67912/HTML/default/viewer.htm#p0znr2zp0ubdzjn10wmhw0y2ef1q.htm)
	
## Overview of Macro Usage
My view of using macros is that they have different scopes depending on purpose.  Macros are used in several modes and need different levels of flexibility depending on the use:

1. [Ad-hoc coding](#ad-hoc-coding)
2. [Project development](#project-development)
3. [Project deployment](#project-deployment)
4. [Project hardening](#project-hardening)

	
### Ad-hoc coding
With ad-hoc coding, macros have a short span of use.  The typical practice is to start by putting macros within the code file.  A best practice is keeping macro definitions near the top of the code file.
	
As the number of macros and the length of macros grow it can be a good next step to move macros to a secondary file and then `%include('path here')` the macros file within the main code file.  This will include all the macro code during each execution of the main code.  This method allows the macros to easily be edited and tested.  The macros will recompile at each job submission and catch any changes from edits.
	
### Project development
During project development you need the flexibility of ad-hoc coding in (1) but with an end goal of deploying the final macros.  In this case, my goal is to eventually deploy macros in an autocall library.

Sidebar on autocall library usage:
>To use an autocall library you store macros in `name.sas` files where the name matches the name of the contained macro.  At job execution, SAS will look through autocall folders in the order they are defined until it finds the first `name.sas` file that matches the current macro call.
>
>SAS will only do this during the first call to a macro during a session.  After that, the compiled macro will be reused at subsequent calls.  This is very efficient and desired behavior as long as you are not editing the macro.  Note: if you adding a macro to an autocall library it will only be found if it has not been previously called.  I call this out because if you have a local version that has been used in your session it will continue to be the one SAS uses for the rest of that session.  Also, if you try calling a macro and realize it is not available and then add it to an autocall location (or edit the autocall locations) it will not be found until you start a new session.

During this phase I do not setup the autocall location.  Instead, I create a folder within my project called "Macros" and store each individual macro file within it.  I then open the `name.sas` files for each macro I am editing within my session editor and edit similar to ad-hoc mode but with more organization. 

If I am using a session editior like *SAS Display Manager (PC SAS)* or *SAS Studio* then I usually just submit each macro separately prior to running the main `code.sas` file.  This makes the macros available for the `code.sas` file run.  If I need to edit a macro I can just resubmit the individual macro and then the new version is available when I rerun my `code.sas` file.  

When the number of macros increases, it can be handy to submit all the contents of the Macros folder for a project and then just open/edit the macros you are currently working on.  For this reason I have created a few macros for macros.

[`%include_folder`](./Macros/include_folder.sas)
* Includes all the files in the input directory.  Has option, `sub=` (Y or N),  for evaluating sub-directories and finding folders named `/Macros`.

[`%combine_macros`](./Macros/combine_macros.sas)
* Combines all the `*.sas` files in the input directory into a single file called `allmacros.sas` (name is configurable with `file=` option).  Has an option for evaluating sub-directories (`sub=` with Y or N) and finding folders named `/Macros`.  The output file will be placed the directory given as an input.

These macros can also be helpful for creating test versions of your overall project that you want to share with others to test.
	
### Project deployment
At this point in a project the code editing of macros is complete.  The next step is defining and setting up the macros for autocall.  To do this you either store the macros in an existing autocall folder or you setup the location of the macros within the project as an autocall location.  I prefer the later method as it is easier to organize macros and track them.  

To make setting up autocall locations easy across all of my projects I have a macro that takes advantage how I organize my SAS projects.  My production projects are all in a folder called "SAS Projects".  Sub-folders within this are named for each individual project.  Within these project folders I create my `/Macros` folder.  

You can set sasautos for your *system* by editing the 'sasv9.cfg' file found in `!sasroot\nls\en\sasv9.cfg`.

You can set sasautos for a *user* by editing the `autoexec.sas` file to include a line like this:

```sas
options sasautos=("newdir" "newdir2" "newdir3" SASAUTOS);
```

Before doing this you may want to just define the sasautos for your session.  The following macro makes it easy to add all the folders with the name `/Macros` (any case) to your SASAUTOS:

* [`%define_autocalls`](./Macros/define_autocalls.sas)
  * This adds the input directory to the SASAUTOS definition using `Options SASAUTOS=`.  With the option `SUB=Y` it will find all subfolders (including the provided folder) named `/Macros` (any case) and add these to SASAUTOS.  Check the log when execution is done and you will find the new value of SASAUTOS listed.

Sidebar on `autoexec.sas` edits for including all macros in your projects directory:
> If you store all code for your finished (or mature) projects in a folder like `C:\PROJECTS` then you can use the `%define_autocalls` macro along with `options sasautos=` in your `autoexec.exe` to make sure all folders named `/Macros` (any case) are included in every SAS session.
> Add these lines to the users `autoexec.sas` file:
>
```sas
options sasautos=("C:\PROJECTS\SAS-Mini-Projects\Organizing Macros\Macros" SASAUTOS);
%define_autocalls(C:\PROJECTS,SUB=Y);
```
> The first step adds the folder containing the `%define_autocalls` macro and the second line uses that macro on the full folder structure.
	
### Project hardening
Hardening is going the next step in the process of deploying reusable code.  In this case I am referring to precompiling macros and securing the contents of macros.  Precompiling allows faster execution as each session does not need to read and compile the macro code.  Securing protects the contents of the macro and keeps them from being edited.  You can also prevent macro code from showing up in logs, even when `Options MPRINT;` is used.  This can be very useful when you do not want users going around a macro by creating a local version with edits to override the production version.  It is also a good strategy when you want to protect potential intellectual property while distributing a macro.

* [Storing Compiled Macros](http://support.sas.com/documentation/cdl/en/mcrolref/67912/HTML/default/viewer.htm#n0sjezyl65z1cpn1b6mqfo8115h2.htm)
* [Securing Macros](http://support.sas.com/documentation/cdl/en/mcrolref/67912/HTML/default/viewer.htm#p1nypovnwon4uyn159rst8pgzqrl.htm)
