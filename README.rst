github-collab documents one possible way for efficient decentralized collaboration over github.

Branching model
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

* feature branches are started from develop,
  and merged (``--no-ff``, i.e. non-fast-forward) into develop
* release branches are started from develop,
  and merged (``--no-ff``, i.e. non-fast-forward) into master;
  right after, master is tagged, and merged into develop (can be fast-forward)

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

.. todo::

   Describe rebase and forced push.

Feature review and merge
------------------------

After work for a while on her feature, several commits onwards, she
decides that the feature branch is useful and stable enough to be
merged into "develop". As it turns out, Charlie is willing to lend a
helping hand, and review her code for any obvious typos or errors.

Publish feature
~~~~~~~~~~~~~~~

First, she pushes her feature branch to her remote github repository::

    git push origin feature/name_of_feature

Option 1: Pull request against Charlie's repository
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Now, before she can do a pull request on github, she must ensure that
Charlie's develop branch is up to date with hers (or
further). Otherwise, any commits that weren't part of the feature, but
committed after Charlie's develop branch, would also turn up on the
pull request, which is usually not what you want as it makes the
review diff longer than necessary.
So, in case Charlie's develop is not up-to-date,
Alice asks Charlie to run the following commands::

    git remote update --prune
    git checkout develop
    git merge alice/develop
    git merge bob/develop
    git merge daisy/develop
    git push origin develop

where it is assumed that Charlie has set up the remotes alice, bob, and
daisy, as described earlier.
If Charlie's develop branch is not up-to-date,
and Charlie is not available to run the above commands, see Option 2.

Now, Alice visits her helloworld github page, and sets up a pull
request, with:

* base repo: charlie/helloworld
* base branch: develop
* head repo: alice/helloworld
* head branch: feature/name_of_feature

Alice summarizes the feature in one sentence in the title (this will be
part of the merge commit message if approved), and any necessary
comments in the description.

Option 2: Pull request against Alice's own repository
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

If Charlie's develop branch on github is not up-to-date,
and Charlie is not immediately available to run the above commands,
then it is also possible for Alice to set up the pull request
against her own github repository:

* base repo: alice/helloworld
* base branch: develop
* head repo: alice/helloworld
* head branch: feature/name_of_feature

Again,
Alice summarizes the feature in one sentence in the title (this will be
part of the merge commit message if approved), and any necessary
comments in the description.

To make sure that Charlie gets notified of the pull request, she CCs Charlie
by mentioning ``@charlie`` in the description of the pull request
(assuming that ``charlie`` is Charlie's github login name;
see https://github.com/blog/821).

Review
~~~~~~

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

Merge
~~~~~

When Charlie is happy with the feature branch,
in case of Option 1,
she clicks **Merge pull request** on the github pull request page.
In case of Option 2, Charlie simply comments `@alice Ok to merge.'
on the pull request, and Alice clicks **Merge pull request**.

Note: if the feature branch cannot be merged automatically,
this option may be disabled. In that case, either Charlie can deal
with the merge conflicts locally, or Alice can rebase her feature
branch onto the latest develop branch.

.. todo::

   Document merge conflict strategies in separate section.

Synchronize and cleanup
~~~~~~~~~~~~~~~~~~~~~~~

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

Release review and merge
------------------------

Basically, everything is as with a feature branch, with a few differences:

#. Convention for naming the branch::

       git checkout develop -b release/x.x.x

   where ``x.x.x`` is the full version
   (can also include alpha, beta, or candidate tags, e.g. ``1.0.6b2``).

#. A release branch is merged into master instead of develop:

   * base repo: charlie/helloworld
   * base branch: master
   * head repo: alice/helloworld
   * head branch: release/x.x.x

#. The master branch is tagged after merge::

       git fetch origin
       git checkout master
       git merge origin/master
       git tag -a -m "Tagging version x.x.x." x.x.x
       git push origin --tags

#. The master branch is merged into develop after merge::

       git fetch origin
       git checkout develop
       git merge origin/develop
       git merge origin/master
       git push origin develop

#. Everyone has to sync master and develop branches.

.. todo::

   Add details of git commands.
