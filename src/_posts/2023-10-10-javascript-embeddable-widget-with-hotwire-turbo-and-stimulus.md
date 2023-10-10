---
layout: post
title: Javascript embeddable widget with Hotwire Turbo and Stimulus
date: 2023-10-10T23:42:59.443Z
categories: Rails
---
There are many articles on how to create an embeddable widget with Javascript, but I wanted to see if I could do the same with just Hotwire Turbo and Stimulus. "Why?" you might ask. Easy, because I like the struggle 😵‍💫. Seriously, I like Rails and really enjoy using Turbo (Turbo Streams / Turbo Frames) so I wanted to see how this experiment would go.

The objective was to create a Javascript widget that I could embed in an external website that uses Turbo Frame and Turbo Stream instead of a JavaScript framework/library like Vue or React. The following is what I came up with.

I created a new rails project, and used esbuild. I would need to still use JavaScript for some of it as you will see shortly.

```
# ruby 3.2.2
# rails 7.0.8
rails new turbo_widget --javascript=esbuild
```

The widget is an "email catcher". For example if someone wanted to start collecting emails for a new product or newletter interest they could embed this widget on there website and the emails would be saved to the rails app for later use.

First we will create the model first by running the following in the terminal.

```bash
rails generate model email_catcher email:string
```

Open the `email_catcher.rb` and add the validation for email. You can others like checking if a valid email format or uniqueness. For this example we will just confirm that they submitted an email.

```ruby
validates :email, presence: true
```

Next run the migration.

```bash
rails db:migrate
```

We will create an controler called `email_catchers_controller.rb` in the `app/controllers/` folders. Then add the index action. This way we can see the list of emails in the rails app.

```ruby
# app/controllers/email_catchers_controller.rb
class EmailCatchersController < ApplicationController
  def index
    @emails = EmailCatcher.all
  end
end
```

Now we can create the index view for the email. In the `app/views/email_catchers` create a file called `index.html.erb`. Add the following mark up.

```html
<!-- apps/views/email_catchers/index.html.erb -->
<div>
  <h1>Emails</h1>
  <ul>
    <% @emails.each do |email| %>
      <li><%= email.email %></li>
    <% end %>
  </ul>
</div>
```

Add the route to the `routes.rb` file.

```ruby
root "email_catchers#index"
```

If you start the server `bin/dev` then go to `localhost:3000` it will show the email catcher index page. Tada! :smile: Nothing new here to see.

We will need to create a JS file to initialize the widget. Create a file called `widget.js` in the `app/javascript/` folder. Then we add:

```javascript
// app/javascript/widget.js
console.log('Widget Loaded');
```

Now add the javascript tag at the bottom of `apps/views/email_catchers/index.html.erb`. After you add the tag you will want to restart the server.

```html
<!-- apps/views/email_catchers/index.html.erb -->
...
<%= javascript_include_tag "widget" %>
```

Open the Developer tools in the browser and refresh the page. You should see 'Widget Loaded'. You may have to restart the rails server.

Here comes the fun part "Turbo". :smile: We will add a turbo frame to the index.html.erb page to use as test for now. This will be where the email catcher input will be shown.

```html
<!-- apps/views/email_catchers/index.html.erb -->
<div>
  <h1>Emails</h1>
  <%= turbo_frame_tag "widget" %>
  ...
</div>
```

To get the input to appear we need to add some javascript to call new action from the controller and then return the turbo_stream. While I think this can be done with Javascript's built in `fetch` I am going to use Rails [request.js](https://github.com/rails/request.js) for the call. Open the terminal run:

```bash
yarn add @rails/request.js
```

In the `widget.js` file import the library, and while here we will add the call to the new action.

```javascript
// app/javascript/widget.js
import { get } from "@rails/request.js"

async function getEmailForm () {
  const response = await get('api/v1/email_catchers/new', { 
    responseKind: "turbo-stream"
  })
  if (response.ok) {
    console.log('All Good')
  } else {
    console.log('Not Good')
  }
}
getEmailForm()
```

What we are doing here is creating an async function to get the email form. We are using the request.js `get` to make the call for the new email form. As you will notice the `responseKind` is set to "turbo-stream" which lets the backend (Rails) to respond with a turbo_stream :smile:. For now we will check that request responded with an OK. For the endpoint you will see that we have it namespaced with `api/v1/` this is something we need to put in place now. 

Start by creating the `api` folder in the `controllers` folder and then inside the `api` folder create the `v1` folder.

```
controllers/
  |-- api/
    |-- v1/
```

Next create the `email_catchers_controller.rb` inside `v1` folder and add the following action.

```ruby
# app/controllers/api/v1/email_catchers_controller.rb
class Api::V1::EmailCatchersController < ApplicationController
  def new
    @email_catcher = EmailCatcher.new
    respond_to do |format|
      format.turbo_stream
    end
  end
end
```

You will now need to create the view. So following the same namespacing as the controller you will need to create the `api` and `v1` folder under the `view` folder. Then create an `email_catchers` folder inside the `v1`.

```
views/
  |-- api/
    |-- v1/
      |-- email_catchers/
```

Inside the `email_catchers` folder create the `new.turbo_stream.erb` file. We will leave it empty for now. The last thing to do before we test this in the browser is the routes. Add the following to the `routes.rb` file.

```ruby
# config/routes.rb
namespace :api do
  namespace :v1 do
    resources :email_catchers, only: %i[ new create ]
  end
end
...
```

This should allow us to test the getEmailForm function. Open the developer tools and refresh page. If everything works you should see the the 'All Good' console.log. 

One thing to note if you look at the rails logs you will see that the `new` action processing as TURBO_STREAM

![rails log turbo stream](/src/images/rails-log-turbo-stream.png)

Now lets get the form to show up. First we need to add the following to the `new.turbo_stream.erb`.

```ruby
# app/views/api/v1/email_catchers/new.turbo_stream.erb
<%= turbo_stream.update "widget" do %>
  <%= render "form", email_catcher: @email_catcher %>
<% end %>
```

With this we will update the 'widget' turbo_frame_tag that is on the page and insert the  email form. Next we can create the email form. In the same folder as the `new.turbo_stream.erb` create a `_form.html.erb` partial. Add the following to the form page

```html
# app/views/api/v1/email_catchers/_form.html.erb
<%= form_with(model: email_catcher, url: api_v1_email_catchers_path) do |form| %>
  <% if email_catcher.errors.any? %>
    <div style="color: red">
      <h2><%= pluralize(email_catcher.errors.count, "error") %> prohibited this email from being saved:</h2>
      <ul>
        <% email_catcher.errors.each do |error| %>
          <li><%= error.full_message %></li>
        <% end %>
      </ul>
    </div>
  <% end %>
  <div>
    <%= form.label :email %>
    <%= form.text_field :email %>
  </div>
  <div>
    <%= form.submit %>
  </div>
<% end %>
```

Now if you refresh the page you should see the form, and in the console 'All Good'. Note if you click the submit button it will show **Content missing**. This is to be expected because we still need to create the create action. Let's do that now. Open the `email_catchers_controller.rb` and add the following.

```ruby
# app/controllers/api/v1/email_catchers_controller.rb
...

def create
  @email_catcher = EmailCatcher.new(email_catcher_params)

  respond_to do |format|
    if @email_catcher.save
      format.turbo_stream
    else
      format.turbo_stream { render :new }
    end
  end
end

private

def email_catcher_params
  params.require(:email_catcher).permit(:email)
end
```

Almost standard stuff here. It will try to save the email, and respond with a turbo_stream. Create an `create.turbo_stream.erb`.

```ruby
# app/views/api/v1/email_catchers/create.turbo_stream.erb
<%= turbo_stream.update "widget" do %>
  <%= render "form", email_catcher: EmailCatcher.new %>
<% end %>
```

If you submit an without an email you should get an error message. If you submit an email then a new blank form is shown. There is one change I would like to make and that is to control the form submission by using Stimulus. The reason is that if we leave it, as is, when we use the widget on an external website and click submit it will try to navigate away to the main rails app. 

Rails has a generator for creating Stimulus controllers so we will use that.

```
rails generate stimulus widget_form
```

This will create a `widget_form_controller.js` in the `app/javascript/controllers/` folder and update the `index.js` file in the same folder to register the controller. Open the `widget_form_controller.js`, and add the following to the connect function.

```javascript
// app/javascript/controllers/widget_form_controller.js
connect() {
  console.log('connect')
}
```

Next add the following to the email catcher form to connect the controller to the form.

```html
# app/views/api/v1/email_catchers/_form.html.erb
<%= form_with(model: email_catcher, 
                url: api_v1_email_catchers_path,
                data: { controller: "widget-form" }) do |form| %>
...
```

If you refresh the page you should see 'connect' in the console. Next we need to take care of the form submit. We will make one last update to the email catcher form.

```html
<%= form_with(model: email_catcher, 
                url: api_v1_email_catchers_path,
                data: { 
                  controller: "widget-form",
                  action: "submit->widget-form#submitForm:prevent",
                  widget_form_target: "form" }) do |form| %>
...
```

We added the action and target. The action is stating that when the form is submitted use the submitForm function instead. Also the "prevent" at the end is the same using element.preventDefault(). Now update the `widget_form_controller.js`.

```javascript
// app/javascript/controllers/widget_form_controller.js
import { post } from "@rails/request.js"
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form"]

  async submitForm() {
    const data = new FormData(this.formTarget)
    const response = await post("http://localhost:3000/api/v1/email_catchers/", {
      responseKind: "turbo_stream",
      body: data
    })

    if (response.ok) {
      console.log('OK')
    } else {
      console.log('ERROR')
    }
  }
}
```

If you test out the email submission it will send, save the email, and replace with a new empty email form should appear. It behaves just like before but this time the form submission is going through the stimulus controller.

Since we are using Turbo and Stimulus we need to make a change to our `widget.js` file. The reason is that external websites may or may not be using these libraries and they will need to be loaded in if not. The other change is the request URL. We need to change to include the backends domain. In this case `http://localhost:3000/...`

```javascript
// app/javascript/widget.js
import { get } from "@rails/request.js"
import "@hotwired/turbo-rails"
import { Application } from "@hotwired/stimulus"
import WidgetFormController from "./controllers/widget_form_controller"

// Load Stimulus
const application = Application.start()
window.Stimulus = application
application.register("widget-form", WidgetFormController)

// Load Turbo
window.Turbo = Turbo

async function getEmailForm () {
  const response = await get('http://localhost:3000/api/v1/email_catchers/new', { 
    responseKind: "turbo-stream"
  })
  ...
}
...
```

Now it is time to test outside of the current rails app that it lives in. In order to test outside of the rails you can create a new rails app or do as I did and create a simple Vite website. I also used [ngrok](https://ngrok.com/). Not going to cover how to set this up in this article.

At this point I will assume that you have an external site setup to test with. On the main `index.html` file add the following lines within the `<body>` tags.

```html
<turbo-frame id="widget"></turbo-frame>
<script type=application/javascript src="http://localhost:3000/widget.js"></script> 
```

At this point if you refresh the index page it you will not see a 404 error because it cannot find the `widget.js` file. That is because rails adds on a hash to the widget name. There is a ways to take care of this by adding a route and controller, but I am just going to copy the `widget.js` from `app/assets/builds/widget.js` and paste it in `/public/` folder. The downside is that everytime we make a change to the file you will need to re-copy and paste. At this point we have made all the the changes to the `widget.js` files so it will be fine to do it this way.

If you refresh now the 404 error should be fixed, but you are getting a different error 😵‍💫. This time it is a CORS error. To fix this we will need to add the [rack-cors gem](https://github.com/cyu/rack-cors). Stop the server and then run the following in the terminal.

```
bundle add rack-cors
```

Next in the `config/initializers/` folder create a `cors.rb` file and add the following.

```ruby
# config/initializers/cors.rb

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins '*'
    resource '/api/*', headers: :any, methods: [:get, :post, :patch, :put]
  end
end
```

This will allow Origin from any website to access our API. If you restared the sever before adding/changing the `cors.rb` file you will need to restart the rails server again to load the initializer. Refresh the external website and the input and submit button will appear.🎉

Now try to submit an email. You get a "http://localhost:3000/api/v1/email_catchers/ 422 (Unprocessable Entity)" in the console. 😵 If you look at the sever logs it will show a InvalidAuthenticityToken error. We need to skip this check. Open the the `api/v1/email_catchers_controller.rb` and add the following.

```ruby
# app/controllers/api/v1/email_catchers_controller.rb
skip_before_action :verify_authenticity_token, only: %i[ create ]

...
```

Refresh the external website, and then try to submit an email. Horay! 🎉 You now see a blank form. If you check the rails app there should be the email from the external website. 👏 One last test. We setup an email validation to check if an email is present. Try submitting without an email, and you get the error.

> 1 error prohibited this email from being saved:
>
> * Email can't be blank

If you made it all the way through, great job! 

### Conclusion

This was more of a Proof of concept. To see if/how it could be done using the Turbo and Stimulus. I would like to explore even using this in production, but want to do somemore testing.