github-collab documents one possible way for efficient decentralized collaboration over github.

Branching Model
===============

The git flow branching model (or some variant thereof) is assumed; see
http://nvie.com/posts/a-successful-git-branching-model/

In that model, the integration branch is assumed to be called
"develop", and the stable branch is called "master". Any other
branches "feature/...", "hotfix/...", "release/...", "test/...", and
so on, are considered temporary, to be merged in "develop" (for
"feature/..."), in "master" (for "release/..."), in both (for
"hotfix/..."), or in neither (for anything else, such as "test/...").

A reminder of git flow principles:

* feature branches are started from develop, and merged into develop
* release branches are started from develop, and merged into master;
  right after, master is tagged, and merged into develop

Walkthrough
===========

A few basic principles:

* all actual coding, i.e. commits, is done in feature branches
* all code is reviewed, and merged into develop, by someone else than
  the coder, via a github pull request

Of course, all rules have exceptions. For example, after a feature
branch was merged, it may seem reasonable for the version string to be
increased directly on the develop branch (assuming you wish to do so,
i.e. python suggests a .devXXX suffix for this purpose), as such
trivial change will likely not require review.

Initial setup
-------------

Alice decides to join a project called helloworld. First, she forks it
on github, and creates a local clone of here remote github
repository::

    git clone git@github.com:alice/helloworld.git

Next, set up the remotes for all other people who also work on
helloworld::

    git remote add bob git://github.com/bob/helloworld.git
    git remote add charlie git://github.com/charlie/helloworld.git
    git remote add daisy git://github.com/daisy123/helloworld.git

Starting a feature
------------------

Features are branched from "develop". First, Alice makes sure her
"develop" branch is up to date with all her peers::

    git remote update --prune
    git checkout develop
    git merge bob/develop
    git merge charlie/develop
    git merge daisy/develop
    git push origin develop

The ``--prune`` option ensures that any remote temporary branches that
have been deleted remotely, are also deleted locally.

Now, she can start her feature branch with::

    git checkout develop -b feature/name_of_feature

Use descriptive feature names; long feature names are fine. Clarity
prevails.

TODO rebase and forced push

Feature review and merge
------------------------

After work for a while on her feature, several commits onwards, she
decides that the feature branch is useful and stable enough to be
merged into "develop". As it turns out, Charlie is willing to lend a
helping hand, and review her code for any obvious typos or errors.

First, she pushes her feature branch to her remote github repository::

    git push origin feature/name_of_feature

Now, before she can do a pull request on github, she must ensure that
Charlie's develop branch is up to date with hers (or
further). Otherwise, any commits that weren't part of the feature, but
committed after Charlie's develop branch, would also turn up on the
pull request, which is usually not what you want as it makes the
review diff longer than necessary. So, she asks Charlie to run the
following command::

    git remote update --prune
    git checkout develop
    git merge alice/develop
    git merge bob/develop
    git merge daisy/develop
    git push origin develop

where it is assumed that Charlie set up the remotes alice, bob, and
daisy, as described earlier.

Now, Alice visits her helloworld github page, and sets up a pull
request, with:

* base repo: charlie/helloworld
* base branch: develop
* head repo: alice/helloworld
* head branch: feature/name_of_feature

Alice summarizes the feature in one sentence in the title (this will be
part of the merge commit message if approved), and any necessary
comments in the description.

Next, Charlie visits her helloworld github page, inspects the commits
and the diff. If everything looks ok, she can check out Alice's
feature locally via::

    git fetch alice
    git checkout alice/feature/name_of_feature

Now Charlie can compile and run the application, run regression tests,
and so on. If something seems wrong, Charlie posts a message on the
github pull request page. Alice can then make further commits to
address those issues, and push her feature branch, until Charlie is
happy with everything.

When Charlie is happy with the feature branch, she clicks
**Merge pull request** on the github pull request page.

Note: if the feature branch cannot be merged automatically,
this option may be disabled. In that case, either Charlie can deal
with the merge conflicts locally, or Alice can rebase her feature
branch onto the latest develop branch.
TODO document this scenario in separate section

Now, everyone, including Alice and Charlie, will want to update their
develop branches, locally and remotely, to point latest newest hottest
code which now resides in Charlie's remote github branch. So, everyone,
except Charlie, would do::

    git remote update --prune
    git checkout develop
    git merge charlie/develop
    git push origin develop

Charlie would do::

    git remote update --prune
    git checkout develop
    git merge origin/develop
    git push origin develop

In addition, Alice would now remove her feature branch::

    git branch -d feature/name_of_feature
    git push origin :feature/name_of_feature

In the above, the colon (``:``) in front of the branch name means that
the branch will be deleted remotely. Alice would not run the command
unless she is sure that it contains nothing that is not merged
elsewhere yet.

Rinse and repeat!
