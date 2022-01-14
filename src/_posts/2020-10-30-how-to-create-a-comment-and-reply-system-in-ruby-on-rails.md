---
layout: post
title: "How to create a comment and reply system in Ruby on Rails"
subtitle:
date: '2020-10-30T14:12:11.358Z'
categories: rails
---


This is a tutorial about building a simple comment and reply system with Ruby on Rails. I was looking for a way to build this without a gem. Most tutorials use gems such as closure_tree, or ancestry. This seemed more than what I wanted. I was able to get some guidance from Nick Haskins the author of Playbook Thirty-nine and StackOverflow. You can find the completed project [here](https://github.com/jamgar/commentapp).
### **Let's Start**
We start off by creating a standard Ruby on Rails app. Create a folder called "commentapp". Open your terminal and run the following commands.
`mkdir commentapp`
Change into the "commentapp" folder
`cd commentapp`
Create the new rails app run
`rails new .`
Open the your code editor and open the "commentapp" folder. I am using VS Code. Test that the app was created successfully. In the terminal run.
`rails s`
Open the browser and navigate to http://localhost:3000/

![default rail page](https://dev-to-uploads.s3.amazonaws.com/i/w31mc84fhew7hxhiajff.png)

### **Add Bootstrap**
 We are going to add Bootstrap for styling. This is an optional step. In your terminal run.
`yarn add bootstrap`
Open app/javascript folder and create a new folder called "stylesheets". Inside the "stylesheets" folder create a file called "application.scss". Open the "application.scss" file and add.
```scss
// app/javascript/stylesheets/application.scss
@import "bootstrap/scss/bootstrap";
```
Open application.js file and add.
```javascript
// app/javascript/packs/application.js
import "../stylesheets/application.scss";
```
Open application.html.erb and add.
```ruby
# app/views/layouts/application.html.erb
<%= stylesheet_pack_tag 'application' %>
```
### **Add Posts**
Next we will scaffold the Posts. Open terminal and run.
`rails g scaffold post title:string body:text`
This will create several files and update the routes file for Post. We will only be working with a few of these files. The scaffold has created a migration file that will be used to create a table for the Post model. This located in db/migrate folder.
```ruby
# db/migrate/<timestamp>_create_posts.rb
class CreatePosts < ActiveRecord::Migration[6.0]
  def change
    create_table :posts do |t|
      t.string :title
      t.text :body

      t.timestamps
    end
  end
end
```
This will create a Post table with columns for title and body. For the migration to take effect we will need to run.
`rails db:migrate`
If we run the app now we will still get the default "Yay! You’re on Rails!" page. We need to change the root path to be the Posts index page. This can be done by updating the routes file.
```ruby
# config/routes.rb
root to: 'posts#index'
```
Start the rails server, if you stopped it, and then refresh http://localhost:3000/ now the page will show

![post index](https://dev-to-uploads.s3.amazonaws.com/i/f56li08ybjbjq5xyshv6.png)

Click on "New Post" and create a new post to give the app some content. At this point, if you click Create Post button without entering a Title or Body it will create an empty post. To not allow this to happen we need to add validation to the Post model.
```ruby
# app/models/post.rb
class Post < ApplicationRecord
  validates :title, :body, presence: true
end
```
I will add some styling with Bootstrap to some of the Post views. Before we can add styles we should delete the stylesheet that was generated when we created the scaffold. Unfortunately this stylesheet will be recreated each time we generate a scaffold. So if styles do not look correct when using Bootstrap it could be that the scaffolds.scss needs to be removed. Navigate to app/assets/stylesheets and delete scaffolds.scss file. We will start to add styles to the application.html.erb page.
```ruby
# app/views/layouts/application.html.erb
  <body>
    <div class="container">
      <%= yield %>
    </div>
  </body>
```
Post index page.
```ruby
# app/views/posts/index.html.erb
<p id="notice"><%= notice %></p>

<h1>Posts</h1>

<%= link_to 'New Post', new_post_path, class: 'btn btn-primary' %>
<hr>
<% @posts.each do |post| %>
  <div class="card">
    <div class="card-body">
      <h5 class="card-title"><%= link_to post.title, post_path(post) %></h5> # changed title to a link to show the post
      <p class="card-text"><%= truncate(post.body, length: 60) %></p>
      <%= link_to 'Edit', edit_post_path(post), class: 'card-link' %>
    </div>
  </div>
<% end %>
```

![new post index](https://dev-to-uploads.s3.amazonaws.com/i/63xhx786jv88mkorwudk.png)

Post form partial
```ruby
# app/views/posts/_form.html.erb
<%= form_with(model: post, local: true) do |form| %>
  <% if post.errors.any? %>
    <div id="error_explanation">
      <h4 class="text-danger"><%= pluralize(post.errors.count, "error") %> prohibited this post from being saved:</h4>

      <ul class="list-group">
        <% post.errors.full_messages.each do |message| %>
          <li class="list-group-item list-group-item-danger"><%= message %></li>
        <% end %>
      </ul>
    </div>
  <% end %>

  <div class="form-group">
    <%= form.label :title %>
    <%= form.text_field :title, class: 'form-control' %>
  </div>

  <div class="form-group">
    <%= form.label :body %>
    <%= form.text_area :body, class: 'form-control' %>
  </div>

  <%= form.submit "Save Post", class: 'btn btn-primary' %>
<% end %>
```
New post form
```ruby
# app/views/posts/new.html.erb
<div class="card my-5">
  <div class="card-body">
    <h1>New Post</h1>

    <%= render 'form', post: @post %>

    <%= link_to 'Back', posts_path, class: 'btn btn-light mt-2' %>
  </div>
</div>
```
![new post form](https://dev-to-uploads.s3.amazonaws.com/i/q8gt0qz43jqbfpqqrwil.png)

Post edit form
```ruby
# app/views/posts/edit.html.erb
<div class="card my-5">
  <div class="card-body">
    <h1>Edit Post</h1>

    <%= render 'form', post: @post %>

    <div class="mt-2">
      <%= link_to 'Show', @post, class: 'btn btn-info mr-2' %>
      <%= link_to 'Destroy', @post, method: :delete, data: { confirm: 'Are you sure?' }, class: 'btn btn-danger mr-2' %> # moved the destroy button from index to here (optional)
      <%= link_to 'Back', posts_path, class: 'btn btn-light' %>
    </div>
  </div>
</div>
```
Post show
```ruby
# app/views/posts/show.html.erb
<div class="card my-5">
  <div class="card-body">
    <p id="notice"><%= notice %></p>

    <h1 class="text-center"><%= @post.title %></h1>
    <hr >
    <div class="my-4">
      <%= simple_format(@post.body) %>
    </div>

    <%= link_to 'Back', posts_path, class: 'btn btn-light' %>
  </div>
</div>
```
### **Comments**
Next we will scaffold the Comments. Open terminal and run.
`rails g scaffold comment body:text post_id:integer parent_id:integer`
Again this will create several files, but we will only be working with a few. One thing to note is to delete the scaffolds.scss if you are using Bootstrap or some other CSS library.
For the migration to take effect we will need to run.
`rails db:migrate`
We will need to update the routes to nest the Comment within Post. Open the routes.rb file and make the following changes. This will cause the comments route to become similar to ../posts/1/comments/1.
```ruby
# config/routes/rb
Rails.application.routes.draw do
  resources :posts do
    resources :comments
  end
  ...
end
```
Changes will need to be made to the Comment and Post models. With this change Comments belong to a Post and Post can have many Comments. Add the following to the Post model.
```ruby
# app/models/post.rb
has_many :comments
```
Add the following to the Comments model.
```ruby
# app/models/comments.rb
belongs_to :post
validates :body, presence: true
```
If you try going to any of the Comments routes they will not work as expected because of us nesting Comment within Post. To get this back to a working app we will first add a new comments form to the Post show.html.erb page.
```ruby
# app/views/posts/show.html.erb
...
<div class="card my-1"> # place this card blow the post body.
  <div class="card-body">
    <p class="font-weight-bold">Comments</p>
    <%= form_with(model: [@post, @post.comments.build]) do |f| %>
      <div class="form-group">
        <%= f.label 'New comment' %>
        <%= f.text_area :body, class: 'form-control' %>
      </div>
      <%= f.submit 'Submit', class: 'btn btn-primary' %>
    <% end %>
  </div>
</div>
```

![comment form](https://dev-to-uploads.s3.amazonaws.com/i/g94qsb8frn1q3h4nyhs5.png)

Now we need to update the Comments controller Create action.
```ruby
# app/controllers/comments_controller.rb
def create
    @post = Post.find(params[:post_id])
    @comment = @post.comments.new(comment_params)

    respond_to do |format|
      if @comment.save
        format.html { redirect_to @post, notice: 'Comment was successfully created.' } # changed the redirect to @post
...
```
First we find the post by using the post_id that is sent with the params. Next update the @comment variable to create a new comment that will belong to the post. If you try to create a comment it will be created, but you will not know unless you check the database. To fix this we need to update the post show.html.erb. Below the Comments card add the following.
```ruby
# app/show.html.erb
...
<%= render @post.comments %>
```
The above line will iterate over each comment using a comment partial. We will need to create the comment partial. Open app/views/comments and create a _comment.html.erb file. Add the following to the partial.
```ruby
# app/views/comments/_comment.html.erb
<div class="card">
  <div class="card-body">
    <%= comment.body %>
  </div>
</div>
```
Add a comment and it will be added to the bottom of the post. You will notice that an empty card will appear below the new comment. For some reason a new comment is automatically built, but not created.

![new comment](https://dev-to-uploads.s3.amazonaws.com/i/zd9f6mleug5oqg3ot8t2.png)

We need to wrap the comment partial within an `unless` condition only to show saved comments.
```ruby
# app/views/comments/_comment.html.erb
<% unless !comment.persisted? %>
  <div class="card">
    ...
  </div>
<% end %>
```
### **Replies**
We are now able to create post and comments so the next item to cover is replies. With my approach we will not be scaffolding replies. Replies are basically comments so we will reuse comments and make some additions. First let's make changes to the Comment model.
```ruby
# app/models/comment.rb
class Comment < ApplicationRecord
  belongs_to  :post
  belongs_to  :parent, class_name: 'Comment', optional: true
  has_many    :replies, class_name: 'Comment', foreign_key: :parent_id, dependent: :destroy

  validates :body, presence: :true
end
```
We are creating a self-joining association with the Comment model. You can read more about it [here](https://guides.rubyonrails.org/association_basics.html#self-joins) in the Rails Guides. This will allow us to store replies in the comments table and will use the parent id column to store the comment id that the reply is associated with.
Next, we will update the comment partial to add a reply link and a loop to render the replies.
```ruby
# app/views/comments/_comment.html.erb
      <%= comment.body %>
      <%= link_to 'reply', new_post_comment_path(@post, parent_id: comment.id), remote: true, class: 'd-block' %>
      </div>
  </div>
  <% if comment.replies.any? %>
    <% comment.replies.each do |reply| %>
      <%= render partial: 'comments/reply', locals: { reply: reply } %>
    <% end %>
  <% end %>
```
We add the reply link with `remote: true` to let rails know this an Ajax call and we want to respond with JavaScript. The JavaScript will be used to insert a reply form on the Show page without refreshing the page. In the link we are passing params for post id and the parent id. Next we check the comment has any replies and if so loop through them using the reply partial. We will have to create the reply partial. Add the _reply.html.erb file in app/views/comments folder.
```ruby
# app/views/comments/_reply.html.erb
<div class="card ml-5">
  <div class="card-body">
    <%= reply.body %>
  </div>
</div>
```
This will create another card below the comment and will have a left margin to push it over and looks like it belongs to the comment. We will not be able to see that until we can add a reply, which we can work on next. We will add a form partial for the replies. Add _reply_form.html.erb file in app/views/comments folder.
```ruby
# app/views/comments/_reply_form.html.erb
<div class="card ml-5">
  <div class="card-body">
    <%= form_with(model: [@post, @comment]) do |f| %>
      <%= f.hidden_field :parent_id %>
      <div class="form-group">
        <%= f.label 'Reply' %>
        <%= f.text_area :body, class: 'form-control' %>
      </div>
      <%= f.submit 'Submit', class: 'btn btn-primary' %>
      <%= link_to 'Cancel', post_path(@post), class: 'btn btn-secondary' %>
    <% end %>
  </div>
</div>
```
We add a hidden field for the parent id, which will be filled from our New action in the Comments controller. The rest is pretty standard.
Now that we have the form created we need to update the New action in the Comments controller.
```ruby
# app/controllers/comments_controller.rb
  def new
    @post = Post.find(params[:post_id])
    @comment = @post.comments.new(parent_id: params[:parent_id])
  end
```
This will build a new reply, which is really a new comment to pass to the reply form. Since we are passing the parent id it will fill the hidden field in the reply form. Because this comment has a parent id we know that it is a reply. Let's move on before I start confusing myself.
Since the reply link is an Ajax call the New action, we just updated, knows to respond to a JavaScript file with the same name as the action. Add a new.js.erb file to app/views/comments folder.
```ruby
# app/views/comments/new.js.erb
document.querySelector("#reply-form-<%= @comment.parent_id %>").innerHTML = ("<%= j render 'reply_form', comment: @comment %>")
```
This will find the div with the ID of `reply-form-<parent_id>` and insert the reply form into the div. We need to create the div in the _comment.html.erb partial. Add the following to the _comment.html.erb just below the reply loop.
```ruby
# app/views/comments/_comment.html.erb
  <div id="reply-form-<%= comment.id %>"></div>
```
This will be a placeholder for the reply form to be inserted. We dynamically build the id using the comment id, which will be the parent id for the reply. That is why in the new.js.erb we are using the @comment.parent_id. If you click on the reply link a reply form should appear below the comment. Once you have replies it will place the form below the last reply for the comment. Add a reply to a comment.

![reply form](https://dev-to-uploads.s3.amazonaws.com/i/udgbhnbsh3kj4dmh8bdd.png)

After creating a reply it will be added below the comment that it is associated with, but will also appear as a comment. That is because a reply is stored in the Comment database. To fix this we will need to update the _comment.html.erb partial to include another condition.
```ruby
# app/views/comments/_comment.html.erb
<% unless comment.parent_id || !comment.persisted? %>
```
So now if a comment has a parent_id (meaning it is a reply) or it is not a saved comment then it will not show in the list of Comments only in the replies of the of the comment.

I hope this was helpful.

Credits
[Playbook Thirty-nine](https://playbookthirtynine.com/p/home) by Nick Haskins
[StackOverflow](https://stackoverflow.com/questions/34888921/nested-comments-and-replies-in-ruby-on-rails)
