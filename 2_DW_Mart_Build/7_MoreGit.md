# Git Recap

![alt text](<../Images/Screenshot 2026-08-16 173236.png>)
![alt text](<../Images/Screenshot 2026-08-16 172637.png>)

#  Git Branching

![alt text](<../Images/Git Branch1.png>)

![alt text](<../Images/Git Branch2.png>)

### Delete a branch (can't be the branch you're currently on, see asterisk in screenshot)
--$ git branch -d feature/project2-readme

Deleted branch feature/project2-readme (was a7d6737).
### Create and switch to branch in one fell swoop
-- $ git switch -c feature/project2-readme

Switched to a new branch 'feature/project2-readme'

### When you go to git push to a new branch you will get an error like below. You need to run a unique git push line of code to first establish the "upstream branch", upstream meaning create a connection between new branch on local repo and new/same branch but on remote repo. Establishing the linkage for all future pushes to this new branch.

-- $ git push
fatal: The current branch feature/project2-readme has no upstream branch.
To push the current branch and set the remote as upstream, use

    git push --set-upstream origin feature/project2-readme

## Making changes on a branch

