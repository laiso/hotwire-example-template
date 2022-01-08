# Hotwire Example Template

We'll cover:

1. `<input type="radio">` change hides/shows management phone number
2. `<select>` change hides/shows management phone number and explanation
3. `<select>` change to fetch contents within a `<turbo-frame>`

## Our starting point

Collect a Building's address, along with whether or not it's owned or leased.
When it's leased, the form also requires that the management phone number is
provided.

## Radio buttons + Rendered + Disabled + Hidden

Introduce `fields` controller, route `input` events to `fields#expand`, render
`<fieldset disabled>` and use `disabled:hidden`

## "Other" Radio button option + Rendered + Disabled + Hidden

* Add third "other" value for `building_type`
* Add the `buildings.building_type_description` column and mark it required for
  "other" records

## Select + Rendered + Disabled + Hidden

* Replace `<input type"radio">` elements with a `<select>`

## Select + Fetched data

Rendering all possible combinations of Country and State would be far too
expensive:

```ruby
irb(main):001:0> country_codes = CS.countries.keys
=>
[:AD,
...
irb(main):002:0> country_codes.flat_map { |code| CS.states(code).keys }.count
=> 3391
```

When it suits your use-case, treat a change to a `<select>` as a `GET
/buildings/new` submission, encoding all current values into the URL, forwarding
those query parameter encoded values to the `Building` instance, then
re-rendering the page
