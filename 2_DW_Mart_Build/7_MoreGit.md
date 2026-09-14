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

## Git Merging
 
 Taking changes finalized on one branch (hotfixes or new features for example) and merging them/transfering them over to another branch, perhaps the main branch.

 1. Fast Forward Merge
    - when you have no new commits on the main branch. 
    - Since main branch has no new commits, you can quickly go ahead and merge any and all commits on your side branch straight to main with no fuss. In other words in the screenshot below, our feature branch is "ahead of" our main branch, and we need to sync them up. 
    ![alt text](<../Images/Git Branch3.png>)
    - To perform merge you have to switch to the branch that is playing catchup, in this case main. 

    ## Lol this got confusing and ran into some issues. 
    - Obiously git cannot distinguish between changes on non text files if you upload two versions of the same image file for example! 
    - Here are the notes from what I learned. Combination of following along with Luke and troubleshooting myself before eventually being able to perform the fast forward merge, and then wrapping up with deleting the secondary branch we created. 
    ### Notes: 
This means “out of sync with remote repo”, need to perform push
     ![alt text](<../Images/Git Branch4.png>)


Merge performed successfully! At this stage local repo branches are merged and all file contents match, but we haven’t pushed to remote repo so it says “your branch is ahead of origin/main by 6 commits.”
![alt text](<../Images/Git Branch5.png>)


Now git push – everything matches, all branches and both local and remote repos:
![alt text](<../Images/Git Branch6.png>)
 

If you delete branch in vscode it only deletes the local branch, even if you run git push after. You have to run this second delete branch line of code to delete it on local repo as well:
 ![alt text](<../Images/Git Branch7.png>)


 2. Three Way Merge 
- Involves github for a real world scenario when you are working on changes that you want to commit on your feature branch for example, but then you see that your teammates have already pushed changes to main brand on remote repo. 
- Perform "3 way merge" to get commit C from the feature branch and the commit E from the main branch into one final merge, see screenshot below 
![alt text](<../Images/Git Branch_3way_1.png>)

- Ran git fetch to pull down changes (simulated by us but in real world example would be from a teammate pushing their own changes) into local repo environment vscode. Teammate changes highlighted in screenshot below, popped up on screen following git fetch. 

![alt text](<../Images/Git Branch_3way_2.png>)

- Now we’re tracking the changes, and we’ll run git pull (remember git pull = fetch + merge in one fell swoop) to pull them down into local repo. This means our main branch is up to date with origin/main, but it has NOT yet been merged with our new feature branch. This is when the 3 way merge comes in, which will merge the branches locally. 

![alt text](<../Images/Git Branch_3way_3.png>)

- Then a git push to remote repo gets us all synced up. From there we can also delete the secondary branch we created for this. 

![alt text](<../Images/Git Branch_3way_4.png>)

- Delete the secondary feature branch:

![alt text](<../Images/Git Branch_3way_5.png>)

# Pull Requests (PR)

- Request to take changes that have been finalized on a branch and merge them to the main branch

![alt text](<../Images/Git Pull_1.png>)
![alt text](<../Images/Git Pull_2.png>)

- Change No.1 and 2 from the screenshot are the result of discussion and feedback from the stakeholder who is tasked with approving the PR and merging with main branch

- Up above in 3 way merge practice we did a git pull but in two separate steps, git fetch and then git merge

## Git Ignore

- this file tells git which file(s) to ignore, and NOT to bother tracking. 

![alt text](<../Images/git ignore.png>)

- best practice is to create git ignore file set up early on in the project, because any commits that exist before the creation of the .gitignore file will keep right on committing even after the .gitignore file is set up. 
- there is a workaround "git rm -r" to retroactively remove the files from the tracking, but its kind of a pain. 

- specify files:
![alt text](<../Images/git ignore_2.png>)
- wildcards/folders: 
![alt text](<../Images/git ignore_3.png>)

## what should you add to .gitignore?

- git hub offers a repository of recommended gitignore files for various programming languages. There's not one for sql, but luke hooked us up: 
- lukeb.co/sql-de-github