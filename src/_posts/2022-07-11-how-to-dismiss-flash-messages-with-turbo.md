---
layout: post
title:  "How to dismiss flash messages with turbo"
subtitle:
date:   2022-07-11
categories: rails
---

In the past I have added JavaScript or CSS to dismiss or hide Flash messages. I wanted to do the same using the new Rails Turbo. So this is what I came up with. I created a gist which can be found [here](https://gist.github.com/jamgar/a4f1378fce74e9fd85029550730030e1)

My setup:
- Ruby 3.1.2
- Rails 7.0.3
- Tailwind for CSS

I am assuming that you know how to create a new Rails app. I then scaffolded Notes with title and body to have a resource to work with. 

In the application.html.erb before `yield` I added the div with the id of "flash-messages" which will be used to target on the dismiss.

```ruby
# app/views/layouts/application.html.erb
  <body>
    <main class="container mx-auto mt-28 px-5">
      <!-- ADD THESE LINES -->
      <div id="flash-messages">
        <%= render "shared/flash_messages" %>
      </div>
       <!-- END OF LINES -->
      <%= yield %>
    </main>
  </body>
```

Next we create the partial. This will contain the Dismiss button. The button_to makes a post request to flash_path, which will create later. You may be wondering why a `post` request that is because the button_to creates a form, which is the default method on a form. Trying to change that to a get or delete will cause you some headaches. 

```ruby
# app/views/shared/_flash_messages.html.erb

<% flash.each do |name, msg| %>
  <div class="flex justify-between p-4 mb-4 bg-blue-100 border-t-4 border-blue-500 dark:bg-blue-200" role="alert">
    <div class="flex">
      <svg class="flex-shrink-0 w-5 h-5 text-blue-700" fill="currentColor" viewBox="0 0 20 20" xmlns="http://www.w3.org/2000/svg"><path fill-rule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7-4a1 1 0 11-2 0 1 1 0 012 0zM9 9a1 1 0 000 2v3a1 1 0 001 1h1a1 1 0 100-2v-3a1 1 0 00-1-1H9z" clip-rule="evenodd"></path></svg>
      <div class="ml-3 text-sm font-medium text-blue-700">
        <%= msg %>
      </div>
    </div>
# This is the Dismiss button
    <%= button_to flash_path, class: " -mx-1.5 -my-1.5 bg-blue-100 dark:bg-blue-200 text-blue-500 rounded-lg focus:ring-2 focus:ring-blue-400 p-1.5 hover:bg-blue-200 dark:hover:bg-blue-300 inline-flex h-8 w-8" do %>
      <span class="sr-only">Dismiss</span>
      <svg class="w-5 h-5" fill="currentColor" viewBox="0 0 20 20" xmlns="http://www.w3.org/2000/svg"><path fill-rule="evenodd" d="M4.293 4.293a1 1 0 011.414 0L10 8.586l4.293-4.293a1 1 0 111.414 1.414L11.414 10l4.293 4.293a1 1 0 01-1.414 1.414L10 11.414l-4.293 4.293a1 1 0 01-1.414-1.414L8.586 10 4.293 5.707a1 1 0 010-1.414z" clip-rule="evenodd"></path></svg>
    <% end %>
# End of button
  </div>
<% end %>
```

Create the Flash controller with a Dismiss action. The `flash.clear` will clear any flash messages so that there will not be any to display or loop through.

```ruby
# app/controllers/flash_controller.rb

class FlashController < ApplicationController
  def dismiss
    flash.clear
  end
end
```

Next create the turbo_stream view for the dismiss. When we submit the form that the button_to created it will send in the format of TURBO_STREAM, which will cause the dismiss action to respond_to a turbo_stream view. The view is updating the partial flash_message, and since we cleared the flash it will display an empty div.

```ruby
# app/views/flash/dismiss.turbo_stream.erb

<%= turbo_stream.update "flash-messages", partial: "shared/flash_messages" %>
```

Finally we will create the route for the dismiss button.

```ruby
# config/routes.rb

Rails.application.routes.draw do

  post 'flash', to: 'flash#dismiss'

end
```

This may or may not be less code, but it was something I wanted to see how to accomplish. I hope this was helpful if you are trying to use as much of Rails as possible. Happy coding.
