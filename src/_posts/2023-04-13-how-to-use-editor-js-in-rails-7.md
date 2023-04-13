---
layout: post
title: How to use Editor.js in Rails 7
date: 2023-04-13T00:39:49.811Z
categories: Rails
---
![editorjs-hero](/images/editorjs-hero.png)

I﻿n this  article I will go through adding Editor.js to a Rails 7 app. Editor.js is a free block-style editor with a universal JSON output. You can add a Notion-like editor to your app, and have it store as JSON.

I﻿ started off with creating a `rails new` using esbuild.
`﻿``
r﻿ails new editor-app --javascript=esbuild
`﻿``
N﻿ext created a scoffold for `articles`
`﻿``
r﻿ails generate scaffold article title:string body:json
`﻿``
O﻿pen the migration that was created `<timestamp>_create_articles.rb` and update the body field to have a default value. This will be needed later when we configure the editor.
`﻿``
class CreateArticles < ActiveRecord::Migration[7.0]
  def change
    create_table :articles do |t|
      t.string :title
      t.json :body, default: {}

      t.timestamps
    end
  end
end
`﻿``


