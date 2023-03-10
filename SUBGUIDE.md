# Submission Guideline for the IEEE MVC 2023 

## If you don't have your work on github.com yet

The following could work (tested for *git version 2.39.1.windows.1*;):
1. Create a new repository on github.com first (see also step-by-step guide below in [Create a new repository: step-by-step visually](#create-a-new-repository-step-by-step-visually)):
   1. Name it IEEE-MVC-2023-<team_name> (**MVC_team: we can suggest to add a suffix reflecting name of competitor/team**, if this simplify the automatic evaluation).
   2. Make it **private**.
   3. Do **not** add readme, gitignore, license.
   4. When created, a path like follows shall be shown in your web browser address: `https://github.com/<git_organization>/IEEE-MVC-2023-<team_name>.git`
2. Connect your local working copy to the created github repository - this depends on how your local work looks like. Go into your local project directory first and perform the following using [CLI](https://www.w3schools.com/whatis/whatis_cli.asp):
   1. If you **downloaded** the https://github.com/DLR-VSDC/IEEE-MVC-2023 at the beginning:
      ```
      git init
      git add -A
      git commit -m "Add current status of project"
      git branch -M main
      git remote add origin https://github.com/<git_organization>/IEEE-MVC-2023-<team_name>.git
      git push -u origin main
      ```
   2. If you **git-cloned** the https://github.com/DLR-VSDC/IEEE-MVC-2023 at the beginning:
      ```
      git remote add mvcevaluation https://github.com/<git_organization>/IEEE-MVC-2023-<team_name>.git
      git branch -M main
      git push -u mvcevaluation main
      ```
 3. Add the evaluators (MVC_team GIT accounts: @tobolar @imeb @rpintodecastro @JBRDLR) to the collaborators on github.com: Settings / Collaborators / Manage access - button "Add people"
 4. Let us know the URL of your repository by filling out the following [MVC Submission Google Form](https://docs.google.com/forms/d/e/1FAIpQLSf0y_SD_n7wPls6xExOJOcU9CL_4K4JdZt13a3Mx1kzHPUOpw/viewform?usp=sf_link)

## License
Copyright © 2023 DLR & UCM. The code is released under the [CC BY-NC 4.0 license](https://creativecommons.org/licenses/by-nc/4.0/legalcode). Link to [short summary of CC BY-NC 4.0 license](https://creativecommons.org/licenses/by-nc/4.0/). For attribution see also [license file](LICENSE.md).

