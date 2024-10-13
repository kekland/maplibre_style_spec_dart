# Tools

## generate_expression_code

Generates Dart code for each expression in `lib/src/expression/definitions/`.

## generate_style_code

Generates Dart code for the style spec in `reference/v8.json`.

## generate_fixtures

Downloads JSON style objects from various sources and performs `gl-style-migrate` so that they're compatible with latest MapLibre spec. After that, saves the fixtures in `test/fixtures`.

To run this, you need to have `gl-style-migrate` installed globally. See https://github.com/maplibre/maplibre-style-spec/blob/main/README.md#gl-style-migrate for more information.

Also, you need to create a file called `tool/keys.js`. See `tool/keys.template.js` for an example.

## generate_all

Runs all the above tools.