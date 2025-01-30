#!/usr/bin/env node

const path = require('path');
const util = require('util');
const fs = require('fs');

const scriptLocation = path.resolve(__dirname);
const rootLocation = path.resolve(scriptLocation, '..', '..');
const generatedLocation = path.resolve(rootLocation, 'lib', 'src', 'gen', 'tilejson.gen.dart');

const referenceFolder = path.resolve(rootLocation, 'reference', 'tilejson');

const getReferences = () => {
  const files = fs.readdirSync(referenceFolder);

  return files.map(file => {
    const filePath = path.resolve(referenceFolder, file);
    return {
      version: file.replace('.json', ''),
      spec: JSON.parse(fs.readFileSync(filePath, 'utf8')),
    };
  });
}

// Convert ab-cd-ef and ab_cd_ef to abCdEf
const convertToDartVariableName = (name) => {
  const parts = name.split(/[-_]/);
  return parts.map((part, index) => index === 0 ? part : part.charAt(0).toUpperCase() + part.slice(1)).join('');
}

const specToDartTypeMap = {
  'string': 'String',
  'integer': 'int',
  'number': 'num',
  'object': 'Object'
}

const convertToDartType = (type, items) => {
  if (type === 'array') {
    // TODO: Handle nested object types
    const subtype = convertToDartType(items.type, items.items);
    return `List<${subtype}>`;
  }

  return specToDartTypeMap[type] || type;
}

const _generateConstructor = (className, spec) => {
  const code = [];

  code.push(`const ${className}({`);

  for (const [key, value] of Object.entries(spec.properties)) {
    const variableName = convertToDartVariableName(key);
    const isRequired = value.required ?? spec.required?.includes(key) ?? false;

    code.push(`  ${isRequired ? 'required ' : ''}this.${variableName},`);
  }

  code.push('});');

  return code;
}

const _generateFromJsonFactory = (className, spec) => {
  const code = [];

  code.push(`factory ${className}.fromJson(Map<String, dynamic> json) {`);

  for (const [key, value] of Object.entries(spec.properties)) {
    const variableName = convertToDartVariableName(key);
    const type = convertToDartType(value.type, value.items);
    const isRequired = value.required ?? spec.required?.includes(key) ?? false;

    let cast = `json[\'${key}\'] as ${type}`;

    if (value.type === 'array') {
      const subtype = type.substring(5, type.length - 1);
      cast = `(json[\'${key}\'] as List).cast<${subtype}>()`;
    }

    if (isRequired) {
      code.push(`  final ${variableName} = ${cast};`);
    }
    else {
      code.push(`  final ${variableName} = json[\'${key}\'] != null? ${cast} : null;`);
    }

    let validation = null;

    // Validations
    // MapTiler doesn't respect this?
    // if (value.type === 'string' && value.pattern) {
    //   validation = `RegExp(r'${value.pattern}').hasMatch(${variableName})`;
    // }
    if (value.type === 'integer' && (value.minimum || value.maximum)) {
      validation = `${variableName} >= ${value.minimum} && ${variableName} <= ${value.maximum}`;
    }

    if (validation) {
      if (isRequired) {
        code.push(`  if (!(${validation})) {`);
      }
      else {
        code.push(`  if (${variableName} != null && !(${validation})) {`);
      }

      code.push(`    throw ArgumentError('${variableName} is not valid');`);
      code.push(`  }`);
      code.push('');
    }
  }

  if (code[code.length - 1] !== '') code.push('');
  code.push(`  return ${className}(`);

  for (const [key, value] of Object.entries(spec.properties)) {
    const variableName = convertToDartVariableName(key);
    code.push(`    ${variableName}: ${variableName},`);
  }

  code.push('  );');
  code.push('}');

  return code;
}

const _generateFields = (spec) => {
  const { properties } = spec;

  const code = [];

  for (const [key, value] of Object.entries(properties)) {
    const variableName = convertToDartVariableName(key);
    const type = convertToDartType(value.type, value.items);
    const isRequired = value.required ?? spec.required?.includes(key) ?? false;
    
    if (commonFields.includes(variableName)) {
      code.push('');
      code.push('@override');
    }

    code.push(`final ${type}${isRequired ? '' : '?'} ${variableName};`);
  }

  return code;
}

const _generateEquatable = (className, spec) => {
  const code = [];

  code.push('@override');
  code.push('List<Object?> get props => [');

  for (const [key, value] of Object.entries(spec.properties)) {
    const variableName = convertToDartVariableName(key);
    code.push(`  ${variableName},`);
  }

  code.push('];');
  code.push('');
  code.push('@override');
  code.push('bool get stringify => true;');

  return code;
}

const generateDartCodeForReference = ({ version, spec }) => {
  const code = [];

  // Convert x.y.z to x_y_z
  const versionParts = version.split('.');
  const versionUnderscore = versionParts.join('_');
  const className = `$TileJson_${versionUnderscore}`;

  code.push(`class ${className} extends $TileJson with EquatableMixin {`);

  code.push(_generateConstructor(className, spec).map(line => `  ${line}`).join('\n'));
  code.push('');
  code.push(_generateFromJsonFactory(className, spec).map(line => `  ${line}`).join('\n'));
  code.push('');
  code.push(_generateFields(spec).map(line => `  ${line}`).join('\n'));
  code.push('')
  code.push(_generateEquatable(className, spec).map(line => `  ${line}`).join('\n'));

  code.push('}');

  return code;
}

const commonFields = [
  'tilejson',
  'tiles',
  'attribution',
  'version',
  'minzoom',
  'maxzoom',
];

const generateDartCode = (references) => {
  const code = [];

  code.push(`// GENERATED CODE - DO NOT MODIFY BY HAND`);
  code.push(`// Generated by tool/tilejson/generate_style_code.js`);
  code.push('');
  code.push('// ignore_for_file: camel_case_types, unused_import');
  code.push('');
  code.push(`import 'package:equatable/equatable.dart';`);
  code.push(`import 'package:maplibre_style_spec/src/_src.dart';`);
  code.push('');
  code.push('sealed class $TileJson {');
  code.push('  const $TileJson();');
  code.push('');
  code.push('  String get tilejson;')
  code.push('');
  code.push('  List<String> get tiles;')
  code.push('');
  code.push('  String? get attribution;')
  code.push('');
  code.push('  String? get version;')
  code.push('');
  code.push('  int? get minzoom;')
  code.push('');
  code.push('  int? get maxzoom;')
  code.push('');
  code.push('  factory $TileJson.fromJson(Map<String, dynamic> json) {');
  code.push('    final tilejson = json[\'tilejson\'] as String;');
  code.push('');
  code.push('    return switch (tilejson) {');

  for (const { version } of references) {
    const versionParts = version.split('.');
    const versionUnderscore = versionParts.join('_');
    const className = `$TileJson_${versionUnderscore}`;

    code.push(`      '${version}' => ${className}.fromJson(json),`);
  }

  code.push('      _ => throw ArgumentError(\'Unknown TileJSON version: $tilejson\'),');
  code.push('    };');
  code.push('  }');
  code.push('}');
  code.push('');

  for (const reference of references) {
    code.push(generateDartCodeForReference(reference).join('\n'));
    code.push('');
  }

  return code.join('\n');
}

const references = getReferences();
const code = generateDartCode(references);

fs.writeFileSync(generatedLocation, code);
