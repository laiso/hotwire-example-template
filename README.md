# Hotwire: Action Text-powered mentions

[Action Text][] is one the more powerful frameworks that Rails provides
out-of-the-box. Unfortunately, its ambition seems to outpace its
popularity.

In addition to its rich text editing capabilities, Action Text's most
well-known features is its built-in support file attachments through its
integration with Active Storage.

The framework's immense potential is rooted in its ability to attach
custom entities using the same mechanism as Active Storage files. Once
attached, Action Text uses the server's Action View-powered templating
to transform those entities into HTML.

For the sake of demonstration, let's attach `User` records to Action
Text content whenever their `username` is "@"-mentioned inside an
editor. We'll start with a baseline Rails 7 application scaffolded by
`rails new`, making incremental improvements along the way.

First, our Action View templates will render "@"-prefixed usernames as
`<a>` elements. Next, our Active Record models will transform
"@"-mentions into [Action Text attachments][] prior to writing to the
database. Finally, we'll lean on Action Text to insert "@"-prefixed
attachments _directly_ into the content from within the browser.

Our client-side code will rely on built-in functionality provided by the
browser when possible. Whenever those capabilities aren't enough, we'll
utilize [Trix.js][] for rich text editing, [Turbo][] Frames for loading
content asynchronously, and [Stimulus][] Controllers to fill in any
other gaps.

The code samples contained below omit the majority of the application's
setup. The rest of the source code from this article can be found [on
GitHub][].

[on GitHub]: https://github.com/seanpdoyle/hotwire-example-template/commits/hotwire-example-action-text-mentions
[Action Text]: https://edgeguides.rubyonrails.org/action_text_overview.html
[Action Text attachments]: https://edgeguides.rubyonrails.org/action_text_overview.html#rendering-attachments

Our domain
---

The domain for the application involves two models: `Message` and
`User`.

Our application's initial model, controller, and view code was created
by Rails' `scaffold` generator:

```sh
bin/rails generate scaffold Message
bin/rails generate scaffold User \
  username:citext:index \
  name:citext
```

The only data that `Message` models retain directly are their `id`,
`created_at`, and `updated_at` columns. `Message` records serve as
entities for our application's `ActionText::RichText` records to
reference through a `has_rich_text :content` relationship declared
within the `Message` class.

In addition to their `id` column, `User` records are identified by their
unique `username` values, and also store a `name` value. Our `User` and
`Message` records don't have any direct relationships to one another.

The `messages/form` partial generated by the `bin/rails generate
scaffold Message` command will serve as our starting point. We'll be
spending most of our time and effort making changes to this template:

```erb
<%# app/views/messages/_form.html.erb %>

<%= form_with(model: message) do |form| %>
  <% if message.errors.any? %>
    <div id="error_explanation">
      <h2><%= pluralize(message.errors.count, "error") %> prohibited this message from being saved:</h2>
      <ul>
        <% message.errors.each do |error| %>
          <li><%= error.full_message %></li>
        <% end %>
      </ul>
     </div>
   <% end %>

   <div class="field">
     <%= form.label :content %>
     <%= form.rich_text_area :content %>
   </div>

   <div class="actions">
     <%= form.submit %>
   </div>
<% end %>
```

Render-time mentions
---

To demonstrate the concept of a mention, our initial implementation will
scan a `Message` record's `content.body` and replace all occurrences of
`@`-prefixed usernames with `<a>` elements. The `<a>` elements will link
to the `users#show` route and treat the `@`-prefixed handle as the
`/users/:id` route's `:id` dynamic segment.

To start, we'll perform a search-and-replace at render-time.

Action View has built-in support for searching a corpus of text and
replacing portions that match a regular expression via
[ActionView::Helpers::TextHelper#highlight][]. The search will be
powered by the [following regular expression][at-mention]:

```ruby
/\B\@(\w+)/
```

When a match occurs, replace the content with an `<a>` element generated
with the [link_to][] helper:

```diff
--- a/app/views/messages/_message.html.erb
+++ b/app/views/messages/_message.html.erb
   <p>
     <strong>Content:</strong>
-    <%= message.content %>
+    <%= highlight(message.content.body.to_html, /\B\@(\w+)/) { |handle| link_to handle, user_path(handle) } %>
   </p>
```

Since the mentions are entirely String-based, they won't include any
information related to a `User` record's identifier. We'll need to add
support for resolveing records based on the `params[:id]` path
parameter.

The generated `UsersController#set_user` helper method queries rows by
their `id` column, which we'll continue to support. In addition to
finding records by their `id`, we'll _also_ want to include records
whose `username` matches the `params[:id]` value without any preceding
`@` character:

```diff
--- a/app/controllers/users_controller.rb
+++ b/app/controllers/users_controller.rb
     def set_user
-      @user = User.find(params[:id])
+      users_with_id = User.where id: params[:id]
+      users_with_username_matching_handle = User.where username: params[:id].delete_prefix("@")
+
+      @user = users_with_id.or(users_with_username_matching_handle).first!
     end
```

Chaining [first!][] to the end of the query means that a query without
any results will raise an `ActiveRecord::RecordNotFound` the same way
that [ActiveRecord::FinderMethods#find][] would.

[ActionView::Helpers::TextHelper#highlight]: https://rubular.com/r/k84OJzvLG637yu
[at-mention]: https://rubular.com/r/TsYHIqAAsubDEy
[link_to]: https://edgeapi.rubyonrails.org/classes/ActionView/Helpers/UrlHelper.html#method-i-link_to
[first!]: https://edgeapi.rubyonrails.org/classes/ActiveRecord/FinderMethods.html#method-i-first-21
[ActiveRecord::FinderMethods#find]: https://edgeapi.rubyonrails.org/classes/ActiveRecord/FinderMethods.html#method-i-find
