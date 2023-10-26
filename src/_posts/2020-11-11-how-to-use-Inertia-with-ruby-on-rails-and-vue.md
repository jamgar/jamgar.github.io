---
layout: post
title: "How to use Inertia with Ruby on Rails and Vue"
subtitle:
date: 2020-11-11T14:13:39.910Z
categories: rails
---

### **What is Inertia**
It is a JavaScript library that allows you to use modern JavaScript frameworks (React, Vue, and Svelte) with fullstack frameworks (Laravel, Rails, and Django) without needing to build out an API. You can build a monolith and use Vue for the view layer. You can also think of it as a replacement for Redux or Vuex, which are well-known routers for the React and Vue. You can read more about Inertia [here](https://inertiajs.com/) I appreciate [Jonathan Reinink](https://twitter.com/reinink), the ceator, for all the hard work he has put into this project. I also want to mention there is a helpful community in the [discord](https://discord.gg/gwgxN8Y).

### **What we will build**
We are going to build a simple note taking app. A user will be able to create, read, update, and delete (CRUD) notes. At the end will implement authentication with Devise, and then make it where a user can only perform CRUD on their own notes. You can find the code for the completed sample project [here](https://github.com/jamgar/inertiaapp)

### **Let's start**
The first thing we will do is create a new folder for our app. Open the terminal. Make a new folder by running.
`mkdir inertiaapp`
Change into the new folder.
`cd inertiaapp`
Create a new rails app and add the flag to not include Turbolinks.
`rails new . --skip-turbolinks`
Why are we not including Turbolinks? It is because Turbolinks is not compatible with Inertia so you don't need it. However, with Turbolinks being integrated with Rails hope is not lost. So, if you have an app that you want to migrate over to Inertia, and you have Turbolinks, you can disable Turbolinks for any responses sent to Inertia. I can give an example of how to do this during the Devise section. Test that the app was created successfully. In the terminal run.
`rails s`
Open the browser and navigate to
http://localhost:3000/

![new_rails image](https://dev-to-uploads.s3.amazonaws.com/i/u0f7dnjtz25eecbayx4y.png)


### **Add Vue**
We could have added Vue when we created the app by including the flag --webpacker=vue, but I wanted to show you the following way for anyone that has an existing project. In your terminal run.
`rails webpacker:install:vue`
Open the your code editor and open the "inertiaapp" folder. I am using VS Code. The above command created a few files and inserted some code in some files. As you can see in the terminal output.

![add_vue_output image](https://dev-to-uploads.s3.amazonaws.com/i/ve6xgnbf73fp3c93t0pu.png)

We need to delete app.vue and hello_vue.js files that were created because we will not be using them. These were created in app/javascript and app/javascript/packs folders respectively. We still need to initialize Vue and this will be done app/javascript/packs/application.js. Add the following code below the require statements.
```javascript
// app/javascript/packs/application.js
...
import { App, plugin } from '@inertiajs/inertia-vue'
import Vue from 'vue'

Vue.use(plugin)

const el = document.getElementById('app')

new Vue({
  render: h => h(App, {
    props: {
      initialPage: JSON.parse(el.dataset.page),
      resolveComponent: name => require(`../Pages/${name}`).default,
    },
  }),
}).$mount(el)
```
This will initialize Vue. It will look for a root element with the ID of "app" to render the views. This is the same as a regular Vue app, but instead of using App.vue page Inertia will use Rails application.html.erb layout page. The Inertia rails adapter will handle creating and adding the ID "app". The initialPage is looking for a data attribute called page on the root element. Basically this will be where the response from the controller is stored. The next item to point out is the resolveComponent, it will look at the Pages directory for the views. Create the Pages folder in the app/javascript folder. You can change the location of the folder just be sure update the resolveComponent require path. We will be adding the Notes views later.

### **Add Inertia**
Time for some Inertia. At this point our app is broken because we are trying to Import Inertia on the client side, which we have not added. We can start with adding Inertia the client-side. In your terminal run.
`yarn add @inertiajs/inertia @inertiajs/inertia-vue @inertiajs/progress`
This will add Inertia, Inertia-vue, and progress bar libraries to our package.json. Inertia has an optional progress bar library that will show as a loading indicator. We need to add the following to application.js under the other imports. This will initialize the progress bar.
```javascript
// app/javascript/packs/application.js
...
import { InertiaProgress } from '@inertiajs/progress'
InertiaProgress.init()
```
Next up is setting up the server side. Add the Inertia gem by running the command in the terminal.
`bundle add 'inertia_rails'`
This will add the latest version of the gem to the Gemfile and install. We have to change the application.html.erb and update the javascript_pack_tag to add defer: true.
`<%= javascript_pack_tag 'application', defer: true %>`
This will cause the script to be executed after the page has been parsed. If this is not added then it may will show a blank page with error an Error in render: "TypeError: Cannot read property 'dataset' of null". Not fun to debug. Note, the following this is optional, but you can make some configuration changes to Inertia by using an initializer. Create a inertia_rails.rb file and add the following code.
```ruby
# config/initializers/inertia_rails.rb
InertiaRails.configure do | config |
  config.version = '1.0' # used for asset verioning
  # config.layout = 'some_other_file' # use this to change the default layout file that inertia will use. Default it uses application.html.erb.
end
```
If you do add/update this initializer remember to restart the rails server.

### **Add Tailwindcss**
This step is optional, but I will be adding Tailwindcss to my project to for styling. Open your terminal run the commands.
`yarn add tailwindcss`
`npx tailwindcss init --full`
The first will add tailwind to the project and the second will scaffold a tailwind.config.js file. The tailwind.config.js file is used to customize your style theme. With the flag --full it will add all of Tailwind defaults, but you can make any changes you want to the theme. Next we need to add Tailwind to the postcss.config.js file.
```javascript
// postcss.config.js
module.exports = {
  plugins: [
    ...
    require('tailwindcss'),
    require('autoprefixer'),
    ...
  ]
}
```
Create a stylesheets folder under app/javascript folder. Then create an application.scss file in the app/javascript/stylesheets folder. Open application.scss and add the following lines.
```scss
// app/javascript/stylesheets/application.scss
@import "tailwindcss/base";
@import "tailwindcss/components";
@import "tailwindcss/utilities";
```
Open application.js and add the following line.
```javascript
// app/javascript/packs/application.js
...
import "stylesheets/application"
```
One last update, open application.html.erb and change the following lines so that the views can use the stylesheets in the app/javascript/stylesheets folder. I also added some Tailwind classes to the body. Note, moving forward all classes will be Tailwind unless otherwise specified.
```erb
# app/views/layouts/application.html.erb
<head>
...
<%#= stylesheet_link_tag 'application', media: 'all' %> # delete or comment out this link as we will not use the asset pipeline for styles.
  <%= stylesheet_pack_tag 'application' %>
...
</head>
  <body class="container bg-gray-200 mx-auto">
    <%= yield %>
  </body
```
### **Add Home**
We are going to add a home page to test the inertia render and styles. Add a pages_controller.rb in our app/controllers folder. Open the pages_controller.rb and add the following action.
```ruby
# app/controllers/pages_controller.rb
def home
  render inertia: 'Home', props: {}
end
```
Open routes and add the root path.
```ruby
# config/routes.rb
root 'pages#home
```
Add the Home.vue page to app/javascript/packs/Pages.
```html
// app/javascript/packs/Pages/Home.vue
<template>
  <div>
    <h1 class="text-2xl text-center">Home Page</h1>
  </div>
</template>
```
Restart the rails server and test by going to the localhost:3000 and you should see the text "Home Page".

![home_page image](https://dev-to-uploads.s3.amazonaws.com/i/blv4h6jovnop49nwqqgu.png)

### **Add Notes**
Now that we have Inertia wired up and working we can move on to adding notes. To speed up the tutorial I will use rails scaffolding. We can run the following command in the terminal to scaffold notes.
`rails g scaffold note title:string content:text`
Run the migrate to create the Note table
`rails db:migrate`
Restart your server and navigate to localhost:3000/notes and test that you get the new note index page.

![note_index image](https://dev-to-uploads.s3.amazonaws.com/i/hpbdxacjpyx6135dhjzf.png)

You can test by creating a note, and all should work as you would expect. This is nice because rails views and Inertia views are coexisting. So if you have an existing app this allows you to migrate in phases.

### **Note Index**
We will now migrate over the Note Index to show the vue page. Open notes_controller.rb, and update the index method.
```ruby
# app/controllers/notes_controller.rb
def index
  notes = Note.all
  render inertia: 'Notes/Index', props: {
    notes: notes.as_json(only: [:id, :title, :content])
  }
end
```
The above will retrieve all notes. Next we create Inertia's render function and pass the location of the Vue page, and props. Props is data that will be passed to our Vue page in json format. The as_json parameter (only: [:id ...]) is optional, but recommended because all data passed and is visible to the client-side. Also the more data you pass it could impact performance. Now add a Notes folder to javascript/Pages folder and then add Index.vue to the javascript/Pages/Notes folder. Open the Index.vue file and add the following.
```javascript
// app/javascript/Pages/Notes/Index.vue
<template>
  <div class="mt-6">
    <h2 class="text-2xl text-center">Notes</h2>
    <a href="/notes/new" class="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded">New Note</a>
    <table class="table-auto bg-white mx-auto w-full mt-4 shadow">
      <thead>
        <tr>
          <th class="border px-4 py-2">Title</th>
          <th class="border px-4 py-2">Content</th>
          <th class="border px-4 py-2">Action</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="note in notes" :key="note.id">
          <td class="border px-4 py-2">{{ note.title }}</td>
          <td class="border px-4 py-2">{{ note.content}}</td>
          <td class="border px-4 py-2">Show</td>
        </tr>
      </tbody>
    </table>
  </div>
</template>

<script>
  export default {
    props: {
      notes: {
        type: Array,
        required: true,
      }
    }  
  }
</script>
```
I did not add a link to show the note yet. I will cover it later with Inertia links. Test going to localhost:3000/notes. If you get an error of "uninitialized constant NotesController" you may have to restart server.

### **Note New**
Next we will migrate the Note new. Open notes_controller.rb, and update both the new and create actions.
```ruby
# app/controllers/notes_controller.rb
...
  def new
    note = Note.new
    render inertia: 'Notes/New', props: {
      note: note.as_json
    }
  end

  def create
    @note = Note.new(note_params)
    if @note.save
      redirect_to notes_path, notice: 'Note was successfully created.'
    else
      redirect_to new_note_path, notice: 'Note was not created.'
    end
  end
...
```
Add New.vue and Form.vue files to the javascript/Pages/Notes folder. Open the New.vue file and add the following.
```javascript
// javascript/Pages/Notes/New.vue
<template>
  <div class="mt-5">
    <h2 class="text-2xl text-center">New Notes</h2>
    <NoteForm v-model="form" @submit="submit" />
  </div>
</template>

<script>
import NoteForm from './Form'
  export default {
    components: {
      NoteForm
    },
    props: {
      note: {
        type: Object,
        required: true
      }
    },
    data() {
      return {
        form: this.note
      }
    },
    methods: {
      submit() {
        // This is in a meta tag located within the head tags
        var token = document.querySelector('meta[name="csrf-token"]').content
        this.$inertia.post('/notes', this.form,
         {
          headers: { 'X-CSRF-Token': token }
         })
      }
    }
  }
</script>
```
This is a standard Vue page. The one thing I wanted to point out is the submit function. You will notice that we are using this.$inertia.post to send data to the controller. This is Inertia's implementation of an ajax request. You will need to get the csrf-token from the head tag of the html page and pass it in the header with request. If you do not pass the the token you will receive an "ActionController::InvalidAuthenticityToken" error. Next open Form.vue and add the following.
```javascript
// javascript/Pages/Notes/Form.vue
<template>
  <form @submit.prevent="$emit('submit')" class="rounded-sm bg-white shadow px-8 py-6">
    <label for="title" class="block text-gray-700 text-sm font-bold mb-2">Title</label>
    <input type="text" id="title" v-model="form.title" class="appearance-none border rounded w-full py-2 px-3 text-gray-700 leading-tight focus:outline-none focus:shadow-outline" />
    <label for="content" class="block text-gray-700 text-sm font-bold mb-2">Content:</label>
    <textarea name="content" id="content" cols="30" rows="10" v-model="form.content" class="appearance-none border rounded w-full py-2 px-3 text-gray-700 leading-tight focus:outline-none focus:shadow-outline"></textarea>
    <button type="submit" class="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded focus:outline-none focus:shadow-outline">Submit</button>
    <a href="/notes" role="button" class="inline-block align-baseline font-bold ml-2 text-sm text-gray-500 hover:text-gray-800">Cancel</a>
  </form>
</template>

<script>
  export default {
    props: {
      value: {
        type: Object,
        required: true
      }
    },
    computed: {
      form: {
        get() {
          return this.value
        },
        set(val) {
          this.$emit('input', val)
        }
      }
    }
  }
</script>
```
You can test creating a new note. If you get any errors, remember to restart the server. I have found that some errors will only clear up after a restart. One thing to bring up now is Form validation and errors. If you submit an empty title or content it will create a note with empty values. I want my note to require both fields. Open note.rb and add the following.
```ruby
# app/models/note.rb
class Note < ApplicationRecord
  validates :title, presence: true
  validates :content, presence: true
end
```
Now if you create a note without a title or content, nothing will happen. You stay on the New Note form, and no message appears from the validation errors. We can work on that next. Inertia has a way to share data which we can use to report errors and later flash messages. We will put this code in a concern. Create a file called Inertiable.rb in app/controllers/concerns folder and add the following.
```ruby
# app/controllers/concerns/Inertiable.rb
require 'active_support/concern'

module Inertiable
  extend ActiveSupport::Concern

  included do
    inertia_share errors: -> {
      session.delete(:errors) || []
    }
  end

  def redirect_to(options = {}, response_options = {})
    if (errors = response_options.delete(:errors))
      session[:errors] = errors
    end

    super(options, response_options)
  end
end
```
We create shared data errors that can be accessed in the Vue page. We override the default redirect_to that is used in the controller to store the errors in a session. So that all controllers have access to the new Inertiable.rb add it to the Application controller.
```ruby
# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  include Inertiable
end
```
Next change the note create method to include the error in the redirect_to.
```ruby
#app/controllers/notes_controller.rb
  def create
    note = Note.new(note_params)
    if note.save
      redirect_to notes_path, notice: 'Note was successfully created.'
    else
      redirect_to new_note_path, errors: note.errors
    end
  end
```
Next create the FlashMessages.vue in app/javascript/Shared folder.
```javascript
// app/javascript/Shared/FlashMessages.vue
<template>
  <div v-if="show">
    <div v-if="Object.keys($page.props.errors).length > 0" class="bg-red-100 border-t-4 border-red-500 rounded-b text-red-900 px-4 py-3 shadow-md" role="alert">
      <div class="flex relative">
        <div class="py-1"><svg class="fill-current h-6 w-6 text-red-500 mr-4" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20"><path d="M2.93 17.07A10 10 0 1 1 17.07 2.93 10 10 0 0 1 2.93 17.07zm12.73-1.41A8 8 0 1 0 4.34 4.34a8 8 0 0 0 11.32 11.32zM9 11V9h2v6H9v-4zm0-6h2v2H9V5z"/></svg></div>
        <div>
          <p v-for="(value, propertyName) in $page.props.errors" :key="propertyName" class="font-bold">{{ capitalize(propertyName) }}: {{ value[0] }}</p>
        </div>
        <button @click="show = false" class="inline absolute top-0 right-0 px-4 py-3 ">
          <svg class="fill-current h-6 w-6 text-red-500" role="button" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20"><title>Close</title><path d="M14.348 14.849a1.2 1.2 0 0 1-1.697 0L10 11.819l-2.651 3.029a1.2 1.2 0 1 1-1.697-1.697l2.758-3.15-2.759-3.152a1.2 1.2 0 1 1 1.697-1.697L10 8.183l2.651-3.031a1.2 1.2 0 1 1 1.697 1.697l-2.758 3.152 2.758 3.15a1.2 1.2 0 0 1 0 1.698z"/></svg>
        </button>
      </div>
    </div>
  </div>
</template>

<script>
  export default {
    data() {
      return {
        show: true
      }
    },
    methods: {
      capitalize(word) {
        return word.charAt(0).toUpperCase() + word.slice(1)
      },
    }
  }
</script>
```
The only thing to note here is that I had to add a method to capitalize the first letter of the Key of the message object. Now we can add the FlashMessages component to the New note page.
```javascript
// app/javascript/Pages/Notes/New.vue
<template>
  <div class="mt-5">
    <FlashMessages />
    <h2 class="text-2xl text-center">New Notes</h2>
    <NoteForm v-model="form" @submit="submit" />
  </div>
</template>

<script>
import FlashMessages from '@/Shared/FlashMessages'
import NoteForm from './Form'
  export default {
    components: {
      FlashMessages,
      NoteForm
    },
...
</script>
```
You may notice that we are using an alias "@" for the path when we import the FlashMessages. We need to make a change to the environment.js file, add the following.
```javascript
// config/webpack/environment.js
...
const path = require('path')

environment.config.merge({
  resolve: {
    alias: {
      '@': path.resolve('app/javascript'),
      vue$: 'vue/dist/vue.runtime.esm.js',
    }
  }
})
...
```
Now that we have the errors shared data set up, let's include the regular flash messages. Open the Inertiable.rb file and add the following shared data inside the include do section.
```ruby
# app/controllers/concerns/Inertiable.rb
  included do
    ...
    inertia_share flash: -> {
      {
        notice: flash.notice,
        alert: flash.alert
      }
    }
  end
```
Update the FlashMessage.vue file to show the success and alert messages.
```javascript
// app/javascript/Shared/FlashMessages.vue
<template>
  <div v-if="show">
    <div v-if="$page.props.flash.success" class="bg-teal-100 border-t-4 border-teal-500 rounded-b text-teal-900 px-4 py-3 shadow-md" role="alert">
      <div class="flex relative">
        <div class="py-1"><svg class="fill-current h-6 w-6 text-teal-500 mr-4" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20"><path d="M2.93 17.07A10 10 0 1 1 17.07 2.93 10 10 0 0 1 2.93 17.07zm12.73-1.41A8 8 0 1 0 4.34 4.34a8 8 0 0 0 11.32 11.32zM9 11V9h2v6H9v-4zm0-6h2v2H9V5z"/></svg></div>
        <div>
          <p>{{ $page.props.flash.success }}</p>
        </div>
        <button @click="show = false" class="inline absolute top-0 right-0 px-4 py-3 ">
          <svg class="fill-current h-6 w-6 text-teal-500" role="button" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20"><title>Close</title><path d="M14.348 14.849a1.2 1.2 0 0 1-1.697 0L10 11.819l-2.651 3.029a1.2 1.2 0 1 1-1.697-1.697l2.758-3.15-2.759-3.152a1.2 1.2 0 1 1 1.697-1.697L10 8.183l2.651-3.031a1.2 1.2 0 1 1 1.697 1.697l-2.758 3.152 2.758 3.15a1.2 1.2 0 0 1 0 1.698z"/></svg>
        </button>
      </div>
    </div>
    <div v-if="$page.props.flash.alert" class="bg-orange-100 border-t-4 border-orange-500 rounded-b text-orange-900 px-4 py-3 shadow-md" role="alert">
      <div class="flex relative">
        <div class="py-1"><svg class="fill-current h-6 w-6 text-orange-500 mr-4" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20"><path d="M2.93 17.07A10 10 0 1 1 17.07 2.93 10 10 0 0 1 2.93 17.07zm12.73-1.41A8 8 0 1 0 4.34 4.34a8 8 0 0 0 11.32 11.32zM9 11V9h2v6H9v-4zm0-6h2v2H9V5z"/></svg></div>
        <div>
          <p>{{ $page.props.flash.alert}}</p>
        </div>
        <button @click="show = false" class="inline absolute top-0 right-0 px-4 py-3 ">
          <svg class="fill-current h-6 w-6 text-orange-500" role="button" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20"><title>Close</title><path d="M14.348 14.849a1.2 1.2 0 0 1-1.697 0L10 11.819l-2.651 3.029a1.2 1.2 0 1 1-1.697-1.697l2.758-3.15-2.759-3.152a1.2 1.2 0 1 1 1.697-1.697L10 8.183l2.651-3.031a1.2 1.2 0 1 1 1.697 1.697l-2.758 3.152 2.758 3.15a1.2 1.2 0 0 1 0 1.698z"/></svg>
        </button>
      </div>
    </div>
...
```
Then add the FlashMessages.vue component to the Note Index file.
```javascript
// app/javascript/Pages/Notes/Index.vue
<template>
  <div class="mt-6">
    <FlashMessages />
    <h2 class="text-2xl text-center">Notes</h2>
...
<script>
import FlashMessages from '@/Shared/FlashMessages'
  export default {
    components: {
      FlashMessages
    },
...
```
### **Add Menu and Layout**
Before we move onto the Note Edit I want to work on the navigation and layout for the client-side. The layout is to the client-side what application.html.erb is to the Rails views. It can be used to wrap the Vue page. Create a Layouts folder in the app/javascript folder. Next create a ApplicationLayout.vue file in the Layouts folder. Add the following to the ApplicationLayout.vue.
```javascript
// app/javascript/Layouts/ApplicationLayout.vue
<template>
  <main>
    <Navigation />
    <FlashMessages />
    <section class="container mx-auto">
      <slot />
    </section>
  </main>
</template>

<script>
import FlashMessages from '@/Shared/FlashMessages'
import Navigation from '@/Shared/Navigation'
  export default {
    components: {
      FlashMessages,
      Navigation
    }
  }
</script>
```
We are going to use a slot which is similar to the <%= yield %> in the application.html.erb. We are importing the FlashMessages, and Navigation components. I removed the FlashMessages component from the pages that I had previously  imported to. Next I will create the Navigation component. Note, remove the classes "container mx-auto" from the body tag of the application.html.erb since we are adding it here. Create a Navigation.vue inapp/javascript/Shared folder. Add the following.
```javascript
// app/javascript/Shared/Navigation.vue
<template>
  <nav class="w-full flex justify-between bg-white py-4 px-8">
    <div>
      <span class="text-teal-500 font-bold">InertiaApp</span>
    </div>
    <div class="font-medium">
      <inertia-link href="/" class="text-gray-600 hover:text-gray-800 mr-2">Home</inertia-link>
      <inertia-link href="/notes" class="text-gray-600 hover:text-gray-800">Notes</inertia-link>
    </div>
  </nav>
</template>
```
Now we can test out wrapping our Pages with the ApplicationLayout. Open Home.vue and add the following to your script section.
```javascript
// app/javascript/Pages/Home.vue
<script>
import Layout from '@/Layouts/ApplicationLayout' // add this line
  export default {
    layout: Layout // add this line
  }
</script>
```
Add these two layout lines to the Notes Index.vue and New.vue page.

### **Inertia Links**
I want to take another detour to go over links and routes. Inertia has its own links that are called inertia-link. It is a wrapper around an anchor tag that prevents full page reloads. What I want to discuss is the href. You can use basic string path such as href="/notes" which will navigate to the Notes Index. What if we want to use named routes like we do on the sever-side, or edit a certain note by passing in the id such as :href="$route.edit_note(note.id)". Well, we can, by using gem called JsRoutes. We will use this gem to read the routes.rb file and generate a routes.js file that we can use on the client-side. Open your terminal and run.
`bundle add "js-routes" --group "development"`
This will install the js-routes gem. Next we need to create jsroutes.rb in the config/initializers folder. Add the following to the file.
```ruby
# config/initializers/jsroutes.rb
JsRoutes.setup do |config|
  config.exclude = [/rails_/] # excludes rails generated routes
  config.compact = true       # removes the _path from the route name
  path = "app/javascript/packs"
  JsRoutes.generate!("#{path}/routes.js")
end
```
The will help to automatically generate the routes.js file when we start the server. Now when you add a new route to the routes.rb file and you restart the server the route will be added to the new routes.js file. The next thing is to add the routes to the top level of our client-side application so we can have access across the application. Open the application.js file and add the following.
```javascript
// app/javascript/packs/application.js
...
import Routes from "./routes.js" // add this line
Vue.prototype.$routes = Routes // add this line

const el = document.getElementById('app')
...
```
Now we can test this out by updating the Note Index.vue page to add the inertia-link to each note. Open the Index.vue page in app/javascript/Pages/Notes folder and make the following change.
```javascript
// app/javascript/Pages/Notes/Index.vue
...
<td class="border px-4 py-2">
  <inertia-link :href="$routes.note(note.id)">Show</inertia-link>
</td>
...
```
After you refresh the index page you can hover over the notes Show link and see that in the lower left corner the URL. Example you should see something like `localhost:3000/notes/2` where the 2 is the id of the note. If you click on the Show link you will get this odd looking modal window that has the note show page. This is really an Inertia error window. It is happening because we are sending an Inertia request to the server-side, but we don't have an Inertia view for the show page. Which we can easily fix now and then move on to the Note Edit. Open the notes_controller.rb and update the Show action with the following.
```ruby
# app/controllers/notes_controller.rb
  def show
    render inertia: 'Notes/Show', props: {
      note: @note.as_json(only: [:id, :title, :content])
    }
  end
```
Next add a Show.vue file to app/javascript/Pages/Notes folder. Add the following.
```javascript
// app/javascript/Pages/Notes/Show.vue
<template>
  <div class="mt-6">
    <h2 class="text-2xl text-center">{{ note.title }}</h2>
    <article class="rounded-sm bg-white shadow px-8 py-6 my-4">
      {{ note.content}}
    </article>
  </div>
</template>

<script>
import Layout from '@/Layouts/ApplicationLayout'
  export default {
    props: {
      note: {
        type: Object,
        required: true
      }
    },
    layout: Layout,
  }
</script>
```
Now when you click on the Show link it will navigate to the Note Show.vue page.

### **Note Edit**
On to the Note Edit. Open the notes_controller.rb and update the Edit and Update actions with the following.
```ruby
# app/controllers/notes_controller.rb
  def edit
    render inertia: 'Notes/Edit', props: {
      note: @note.as_json(only: [:id, :title, :content])
    }
  end
  ...
  def update
    if @note.update(note_params)
      redirect_to notes_path, notice: 'Note was successfully update.'
    else
      redirect_to edit_note_path(@note), errors: @note.errors
    end
  end
```
Now we need to create the Edit.vue. Add the Edit.vue page in the app/javascript/Pages/Notes folder. Add the following.
```javascript
// app/javascript/Pages/Notes/Edit.vue
<template>
  <div class="mt-5">
    <h2 class="text-2xl text-center">Edit Note</h2>
    <NoteForm v-model="form" @submit="submit" />
  </div>
</template>

<script>
import NoteForm from './Form'
import Layout from '@/Layouts/ApplicationLayout'
  export default {
    components: {
      NoteForm
    },
    props: {
      note: {
        type: Object,
        required: true
      }
    },
    layout: Layout,
    data() {
      return {
        form: this.note
      }
    },
    methods: {
      submit() {
        this.$inertia.put(this.$routes.note(this.note.id), this.form)
      }
    }
  }
</script>
```
You will notice this is basically the same as the New.vue with the exception of the submit function. I am using this.$inertia.put instead of post. I removed the headers CSRF token. You can also remove the CSRF token code from the New.vue submit. Since this will be needed on each request we can make a couple of changes so that it is. Open application.js and add the following.
```javascript
// app/javascript/packs/application.js
import axios from 'axios'
axios.defaults.xsrfHeaderName = "X-CSRF-Token"
```
Next open the Inertiable.rb and add the following.
```ruby
# app/controllers/concerns/Inertiable.rb
  included do
    before_action :set_csrf_cookies
    ...
  end
  ...
  private

  def set_csrf_cookies
    cookies['XSRF-TOKEN'] = {
      value: form_authenticity_token,
      same_site: 'Strict'
    }
  end
```
I made an update the Notes Index.vue page to include an edit link for the note. Add the following under the Show link.
```javascript
// app/javascript/Pages/Notes/Index.vue
...
<inertia-link :href="$routes.edit_note(note.id)">Edit</inertia-link>
...
```

### **Note Delete**
The last CRUD action to work on is the delete. Open notes_controller.rb and update the delete action with the following.
```ruby
# app/controllers/notes_controller.rb
  def destroy
    @note.destroy
    redirect_to notes_path, notice: 'Note was successfully destroyed.'
  end
```
Next add a link to the Notes Index.vue page to delete the note. Open the Index page and add the following.
```javascript
// app/javascript/Pages/Notes/Index.vue
...
          <td class="border px-4 py-2">
            <inertia-link :href="$routes.note(note.id)" class="text-blue-700 mr-2">Show</inertia-link>
            <inertia-link :href="$routes.edit_note(note.id)" class="text-green-700 mr-2">Edit</inertia-link>
            <a href="#" @click="onDelete(note.id)" class="text-red-700">Delete</a> <!-- add this link -->
          </td>
...
<script>
...
    methods: {
      onDelete(id) {
        this.$inertia.delete(this.$routes.note(id), {
          onBefore: () => confirm('Are you sure you want to delete this note?'),
        })
      }
    }
</script>
```
![updated_index image](https://dev-to-uploads.s3.amazonaws.com/i/50d93189vngyrddhnhe2.png)

### **Add Devise**
Using devise in this app will be pretty standard setup and configuration. I am adding as an extra, but also to point out a couple of items that may help you when using it with Inertia. I will run through the basics setup. Open terminal and run the following commands.
`bundle add 'devise'`
`rails generate devise:install`
`rails g devise:views`
`rails generate devise User`
`rails db:migrate`
`rails g migration add_user_id_to_notes user_id:integer`
`rails db:migrate`
Add the associations to the Note and User models.
```ruby
# app/models/user.rb
class User < ApplicationRecord
  ...
  has_many :notes, dependent: :destroy
end
```
```ruby
# app/models/note.rb
class Note < ApplicationRecord
  belongs_to :user
  ...
end
```
Update the notes_controller.rb to only allow the current user to manage their notes.
```ruby
# app/controllers/notes_controller.rb
class NotesController < ApplicationController
  before_action :authenticate_user!
  ...

  def index
    notes = current_user.notes.all
    render inertia: 'Notes/Index', props: {
      notes: notes.as_json(only: [:id, :title, :content])
    }
  end
  ...
  def create
    note = current_user.notes.new(note_params)
    if note.save
      redirect_to notes_path, notice: 'Note was successfully created.'
    else
      redirect_to new_note_path, errors: note.errors
    end
  end
  ...
  private

    def set_note
      @note = current_user.notes.find(params[:id])
    end
    ...
end
```
Note, I updated the devise views with the Tailwind css, but not going to add the changes here. Please see the repo for the changes. Next we will want to share the current users information with the client-side so we will update the Inertiable.rb file with the following.
```ruby
# app/controllers/concerns/Inertiable.rb
  included do
    ...
    inertia_share auth: -> {
      {
        user: current_user.as_json(only: [:id, :email])
      }
    }
  end
```
This will share the current users id and email. Next we can update the Navigation.vue file with the following.
```javascript
// app/javascript/Shared/Navigation.vue
...
    <div class="font-medium flex">
      <inertia-link href="/" class="text-gray-600 hover:text-gray-800 px-2 mr-2">Home</inertia-link>
      <span v-if="!$page.props.auth.user">
        <a :href="$routes.new_user_session()" class="text-gray-600 hover:text-gray-800 px-2">Sign In</a>
        <a :href="$routes.new_user_registration()" class="text-gray-600 hover:text-gray-800 px-2">Sign Up</a>
      </span>
      <span v-else>
        <inertia-link href="/notes" class="text-gray-600 hover:text-gray-800 px-2">Notes</inertia-link>
        <inertia-link :href="$routes.destroy_user_session()" method="delete" class="text-gray-600 hover:text-gray-800 px-2">Sign Out</inertia-link>
      </span>
    </div>
...
```
I am showing the different links based on if there is a current user stored in the "auth.user" shared data that we added in Inertiable.rb. We use anchor tags for both Sign in and Sign up because we are using rails views. We can use the inertia-link for the Sign out because there is no associated rails view.

I will not be migrating the devise views to client-side just show how you can have both client-side views and rails views. If you decide to migrate to the client-side, you will need to make your own sessions and registrations controllers to override the actions such as create, destroy and edit for registration with an Inertia render. One more note on devise if you use turbolinks you will run into an issue after submitting the sign up or sign in. The only way I have found to make it work is to override the sessions and registrations controllers and disable the turbolinks on the redirect_to. For example the sign in, I created the sessions controller and then added the following to the create action.
```ruby
  def create
   self.resource = warden.authenticate!(auth_options)
   set_flash_message!(:notice, :signed_in)
   sign_in(resource_name, resource)
   redirect_to root_path, turbolinks: false
  end
```
The first three lines I copied from the device code, and then updated the redirect_to to add "turbolinks: false". Not ideal, but it worked.

### **Closing Thoughts/Summary**
Inertia is a great project, and I covered the basics. I would encourage you to look over the Inertia documentation for more advance topics. Give it a try and let me know what you think. I want to thank [Georg Ledermann](https://twitter.com/ledermann) for porting over the Inertia [demo app to Rails](https://github.com/ledermann/pingcrm), and so being helpful in answering my questions. If you have any questions please leave a comment and I will do my best to answer.
