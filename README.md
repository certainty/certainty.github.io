# README

## Building content

### Where to put the content
All the *real* content is placed in the `content` subfolder. 
Remember that any path above a `_posts` folder is automatically registered as a category.
So let’s say you want to create posts about mental health you could create a new hierarchy like so:

	mkdir -p content/mental-health/_{posts,drafts}` 

This creates a posts and drafts folder which you can then use for the actual content.


### Workflow

#### Write / Edit
The workflow is easy. Just put the content you’re about to write into the *_drafts* folder at the appropriate level, write your way through and save it. At any time you can see the changes locally if you run `make local`.  

#### Promote drafts
If you’re satisfied with your work you can promote the draft to an actual post, which is a matter of moving the draft over to the  `_posts` folder. *Hint: this might be a good opportunity to adjust the date of the post*.

At this point you safely commit and push to the master branch. 

#### Publish 
Once you’re ready to bring the changes live you can run `make publish`, which will take care of pushing the changes to the correct branch.

### Setup

	bundle install

### Rebuild while writing

	make dev

### Test with local server

	make local

### Publish
The following builds and publishes the content.

	make publish


## More information
[https://docs.github.com/en/github/working-with-github-pages/setting-up-a-github-pages-site-with-jekyll][1]

[1]:	https://docs.github.com/en/github/working-with-github-pages/setting-up-a-github-pages-site-with-jekyll