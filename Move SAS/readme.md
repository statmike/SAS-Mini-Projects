# Outline of the project

The goal of this project is to automate the process of updating .sas files when the location of data sources changes.   This could happen when a folder where data is stored gets moved or when the location that SAS is installed get moved.

* **Inventory**
  * create a table of know Data location moves: OLD PATH | NEW PATH.  This can be read as when you see `OLD PATH` as the start of path then update that portion of the path to `NEW PATH`.
  * examine and find common prefixes and their matches from the two columns

* **Folder Survey**
  * find .sas files in folder and sub-folders
  * read .sas files
  * subset to paths: libname, filename, macro variables, etc.
  * make list: folder + file + line number + path
  * make distinct list of paths
  * Find common prefixes

* **Update**
  * replace paths
  * save .sas file
  * rename original .sas file as *.sas_oldpaths

* **Further Considerations**
  * Data Views
  * Relative Paths
  * Repairing
  * Creating