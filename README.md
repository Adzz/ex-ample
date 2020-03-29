# Example

A repo with a collection of elixir code examples for quick reference. Powers [www.ex-ample.co.uk](www.ex-ample.co.uk)

### Contributing

To add an example clone the repo then choose a snake cased name for your example. This will appear in the contents so short names are good.

Start by running the generator for new examples:
```sh
$ mix new_example my_awesome_example
```

This creates two files, an `.ex` file in code_examples and a `.html` file in explanations. Put the code example in the `.ex` file and write an explanation of it in the explanations file. Once you are happy, add your new example to `examples_order.txt`. The order of this determines the order of the examples, so if it's similar to an existing one, it might be a good idea to group it together with that.
E.g.

```
hello_world
another_similar_example
my_awesome_example
more_examples
```

Once that's done build the site with:
```sh
$ mix build_site
```

Then submit the PR! :tada:
