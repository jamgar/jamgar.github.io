---
layout: post
title: Binged Watched (almost) a Rails Upgrade
date: 2023-10-26T01:13:49.219Z
categories: Rails, upgrade
---
I watched Chad Pytel and other developers from thoughtbot [Upgrading a Rails 3.2 app to Rails 7](https://www.youtube.com/watch?v=gQIYXc8y-UM&list=PL8tzorAO7s0huVF53GLeKbqNmMbwJ5JGF&pp=iAQB). Be warned it 17 hours over several videos, but it was well worth the time invested. 🙂 I wanted to share some things that I learned. 

As you will find out from the video this app is part of a book [Ruby Science](https://thoughtbot.com/ruby-science/) that was written over a decade ago. Now Chad is going through the update of the app and book. This video series was like finding a treasure chess full of Ruby's 😉. I have never had to upgrade a Rails app that old so this was great to watch and learn.

### Historical knowledge of the framework is super helpful.

Not sure how long Chad has been a Ruby developer, but it seems from the early days of Rails. His historical knowledge of the framework seemed to allow him to move faster then if someone who did not have the context. I image, if it was me, I would have to spend alot more time researching how the framework or language worked during the time of that version.

### Upgrade options

Since there was such a large gap between the versions of Rails, one option could have been to spin up a new app. Then go through the process of copy and pasting. As Chad explained this may work, but could be risky because after investing the time you could find out that the app doesn't work. The other, and more common, approach is to upgrade incrementally through various versions. This was the approach taken in the videos.

### Be patient and make minimal changes.

Along the lines of upgrading incrementally, be patient. I learned that it could be tempting to do large version jumps but that will be a bad idea. The approach taken was to upgrade the versions of Rail and Ruby independently. For instance, upgrade to a version of Rails fix any errors. Then run the test suite and fix any failures. Commit the changes. Next upgrade the Ruby version, if needed, fix any errors. Then run the test suite and fix any failures. Commit changes. Rinse and repeat. By using this approach you are not scratching your head wondering if this is Rails or Ruby causing the issue.

### Other Tips

* Stay on the recommended Ruby verison for Rails as long as possible. You can see a compatibility table [here](https://www.fastruby.io/blog/ruby/rails/versions/compatibility-table.html). 
* Upgrade to highest patch version because it is likely that bugs have been fixed.
* Create a branch for each version change. 
* Identify if the errors are because of the Rails/Ruby version or the app code
* Some gems or dependencies of gem may be the culprit of errors. You may have to lock down to a working version, until you get to a more modern version. 
* You can use the rubygems.org to compare release dates of a rails version and gem version to know what version in the gem file to set for the offending gem.
* Take note of changes that may need to revert when you get to a newer version. For instance if you have to add and/or lock down a version of a gem you may have to remove it later.
* Take break if you are working through an error/failure and not making progress. Go work on something else, and then come back.
* railsdiff.org is a tool that can compare different Rails versions and their changes.
* Refer to the [upgrade guides](https://guides.rubyonrails.org/upgrading_ruby_on_rails.html) for guidance on some things that have changed.

### Conclusion

I am thankful for the time and effort that Chad and the other thoughboters put into this upgrade. From someone that does not experience in this area it was great to watch and learn. Keep up the awesome content.