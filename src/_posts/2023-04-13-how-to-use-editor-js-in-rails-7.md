---
layout: post
title: How to use Editor.js in Rails 7
date: 2023-04-13T20:05:48.175Z
categories: Rails
---
![editor JS hero](/images/editorjs-hero.png)

In this article I will step through adding [Editor.Js](https://editorjs.io/) to a Rails 7 app. Lets start with creating the Rails app.

```ruby
rails new editor-js-app --javascript=esbuild
```

So we have a resource to work with let's scaffold Articles.

```ruby
rails generate scaffold article title body:json
```

Now open the migration `<timestamp>_create_articles.rb`, and update the body to have a default value of "{}".

```ruby

class CreateArticles < ActiveRecord::Migration[7.0]
  def change
    create_table :articles do |t|
      t.string :title
      t.json :body, default: {} # <= update this line

      t.timestamps
    end
  end
end

```

Save and then run `rails db:migrate` to create the table.

Next we will add the Editor.js and some Block tools. If you only add the Editor.js it will come with a default Text (a.k.a. paragraph) tool. With the extra ones you will have the option for a Header and Text tool with alignment options.

```
yarn add @editorjs/editorjs @editorjs/header editorjs-paragraph-with-alignment@3.x
```








