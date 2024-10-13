#!/usr/bin/env node

const { exec } = require('child_process');
const path = require('path');

const rootPath = path.join(__dirname, '..');

console.log('-----------------');
console.log('generate_style_code');
console.log('-----------------');

exec('./tool/style/generate_style_code.js', { cwd: rootPath });

console.log('-----------------');
console.log('generate_expression_code');
console.log('-----------------');

exec('./tool/style/generate_expression_code.dart', { cwd: rootPath });

console.log('-----------------');
console.log('generate_tilejson_spec');
console.log('-----------------');

exec('./tool/tilejson/generate_tilejson_spec.js', { cwd: rootPath });

console.log('-----------------');
console.log('generate_fixtures');
console.log('-----------------');

exec('./tool/test/generate_fixtures.js', { cwd: rootPath });
