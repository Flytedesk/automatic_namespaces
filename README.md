# AutomaticNamespaces

This gem eases some pain related to strong namespaces in a modular monolith. 

By default, Rails 7 autoloader (Zeitwerk) requires a separate "namespace" directory above a namespaced class. For example:

```
app
├── models
│   ├── component1
│   │   ├── class1.rb       # contains Component1::Class1
```

When building a modular monolith using packages ([packwerk](https://github.com/Shopify/packwerk) + [packs-rails](https://github.com/rubyatscale/packs-rails)), 
this pattern creates a lot of extra noise in the directory structure:

```
packs
├── component1
│   ├── app
│   │   ├── controllers
│   │   │   ├── component1
│   │   │   │   ├── model1_controller.rb  # contains Component1::Model1Controller
│   │   │   │   ├── model2_controller.rb  # contains Component1::Model2Controller
│   │   ├── models
│   │   │   ├── component1
│   │   │   │   ├── model1.rb             # contains Component1::Model1
│   │   │   │   ├── model2.rb             # contains Component1::Model2
│   │   ├── public
│   │   │   ├── component1
│   │   │   │   ├── public_type1.rb       # contains Component1::PublicType1
│   │   │   │   ├── public_type2.rb       # contains Component1::PublicType2
│   │   ├── services
│   │   │   ├── component1
│   │   │   │   ├── service1.rb           # contains Component1::Service1
│   │   │   │   ├── service2.rb           # contains Component1::Service2
```

And that's only for a single pack! As your modular monolith grows, you'll likely have dozens (maybe you'll have 
hundreds) of packs. That's a lot of "namespace" directories that aren't adding a lot of value. You already 
know the namespace of those classes in a strongly namespaced pack -- it's the pack name -- can Zeitwerk know it, too?

This gem configures the Rails 7 autoloader so that most subdirectories under your strongly namespaced component's `app` directory are 
automatically associated with the namespace. 

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add automatic_namespaces

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install automatic_namespaces

## Usage

Given the `package.yml` of a strongly namespaced pack:

```yml
enforce_dependencies: true
enforce_privacy: true
public_path: app/public/
dependencies:
 - "packs/components/core_ui"
 - "packs/components/core_ext"
 - "packs/components/us_states"
 - "packs/subsystems/products"
 - "packs/subsystems/inventory"
metadata:
```

modify the metadata to opt into automatic namespacing:

```yml
metadata:
 automatic_pack_namespace: true
```

Now restructure your files to remove the extra namespace directories under `app`. Note that some directories do not 
generally contain namespaced classes. These are exempted from `automatic_namespaces`:

* assets
* helpers
* javascript
* views

Additional directories can be excluded by adding them to the `automatic_pack_namespace_exclusions` key in your 
`package.yml` file. This is useful if you require files in your pack that sit outside of your packs namespace:

```yml
metadata:
  automatic_pack_namespace: true
  automatic_pack_namespace_exclusions:
    - app/policies # Exclude pundit policies
    - app/admin # Exclude active admin definition files
```

If your package / namespace name requires ActiveSupport inflections, you will probably need to tell `automatic_namespaces`
what the correct namespace name should be in that package:

```yml
# packs/shoes_ui/package.yml
metadata:
  automatic_pack_namespace: true
  namespace_override: ShoesUI
```

This is necessary because `automatic_namespaces` works by modifying the autoloader paths, which has to 
happen during Rails application initialization; but the inflector is not available for use then.

If you would like to use your own file layout conventions for packs (i.e. not `app/*`) you can specify 
your own glob by using `autoload_glob` to append the glob to the folder containing package.yml. This defaults
to `'/app/*'`, the same pack directories packs-rails adds to the autoload paths. To also pick up `app` directories
nested deeper inside the pack (the behavior before this default changed), use `'/**/app/*'`.

```yml
metadata:
  # Put the folder containing package.yml as the root for the autoloader.
  autoload_glob: ''
```

## Development

After checking out the repo, run `bundle install` to install dependencies. Then, run `rspec` to run the tests. 

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Credits

Thanks to a handful of individuals who directly contributed to the creation of this gem:

* [Caleb Woods](https://github.com/calebwoods) - For feeling the pain and helping to spike an approach during a project kickoff at [RoleModel Software](https://www.rolemodelsoftware.com)
* [Alex Evanczuk](https://github.com/alexevanczuk) - For being willing to collaborate on the project, helping to refine the approach, and even mentoring me on how to create my first gem for sharing with others. 
* [Xavier Noria](https://github.com/fxn) - For his suggestions on how to patch Zeitwerk to make this work at all, and for suggestions on how to keep hot reloading working after Rails autopaths were missing all pack directories. 

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/gap777/automatic_namespaces. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/gap777/automatic_namespaces/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the AutomaticNamespaces project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/gap777/automatic_namespaces/blob/main/CODE_OF_CONDUCT.md).
