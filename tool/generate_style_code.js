#!/usr/bin/env node

const path = require('path');
const util = require('util');

const scriptLocation = path.resolve(__dirname);
const rootLocation = path.resolve(scriptLocation, '..');
const generatedLocation = path.resolve(rootLocation, 'lib', 'src', 'gen', 'style.gen.dart');

const reference = require(path.resolve(rootLocation, 'reference', 'v8.json'));

// Convert ab-cd-ef and ab_cd_ef to AbCdEf
const convertToDartClassName = (name) => {
  const parts = name.split(/[-_]/);
  return parts.map(part => part.charAt(0).toUpperCase() + part.slice(1)).join('');
}

// Convert ab-cd-ef and ab_cd_ef to abCdEf
const convertToDartVariableName = (name) => {
  const parts = name.split(/[-_]/);
  return parts.map((part, index) => index === 0 ? part : part.charAt(0).toUpperCase() + part.slice(1)).join('');
}

const ignoreTopLevelKeys = [
  '$version',
  'function',
  'function_stop',
  'expression',
  'expression_name',
  'property-type'
]

const duplicatedEnumKeys = [
  'visibility',
]

const classes = [];
const enums = [];
const typedefs = [];
const classExtends = {};

const jsDartTypeMap = {
  'string': 'String',
  'number': 'num',
  'boolean': 'bool',
  'object': 'Object',
  'array': 'List',
  '*': 'Object',
}

const dartJsonNativeTypes = [
  'String',
  'num',
  'bool',
  'List',
  'Map',
  'Object',
]

const convertToDartType = (type) => jsDartTypeMap[type] || convertToDartClassName(type);

const getDartType = (object) => {
  if (typeof object === 'string') {
    return convertToDartType(object);
  }

  const type = object.type;

  if (type === 'array') {
    const subtype = object.value;
    return `List<${getDartType(subtype)}>`;
  }

  return convertToDartType(type);
}

const createEnum = (name, parentName, object) => {
  let enumName = name;
  let isDuplicated = duplicatedEnumKeys.includes(name);

  if (isDuplicated) {
    const found = enums.find(e => e.rawName === name);
    if (found) return found;
  }

  if (parentName && !isDuplicated) {
    enumName = `${convertToDartClassName(parentName)}$${convertToDartClassName(name)}`;
  }

  enumName = convertToDartClassName(enumName);

  const values = object.values;

  const enumValues = [];

  for (const key in values) {
    const { doc } = values[key];

    enumValues.push({
      rawName: key,
      name: convertToDartVariableName(key),
      doc,
    });
  }

  const result = {
    rawName: name,
    name: enumName,
    values: enumValues,
  };

  enums.push(result);
  return result;
}

const createField = (name, parentName, object) => {
  let dartType = getDartType(object);

  if (object.type === 'array') {
    const subtype = object.value;

    if (subtype === 'enum') {
      const $enum = createEnum(name, parentName, object);
      dartType = `List<${$enum.name}>`;
    }
  }

  if (object.type === 'enum') {
    const $enum = createEnum(name, parentName, object);
    dartType = $enum.name;
  }

  if (name === 'filter') {
    dartType = 'Expression<bool>';
  }

  const props = {
    rawName: name,
    name: convertToDartVariableName(name),
    type: dartType,
    isRequired: object.required ?? false,
    defaultValue: object.default,
    propertyType: object['property-type'],
    doc: object.doc,
  };

  return props;
}

const parseTopLevelObject = (key, object) => {
  if (ignoreTopLevelKeys.includes(key)) {
    return;
  }

  if (Array.isArray(object)) {
    for (const item of object) {
      classExtends[convertToDartClassName(item)] = convertToDartClassName(key);
    }

    return;
  }

  if (!object.type && Object.keys(object).length === 1 && object['*']) {
    // This is a map typedef
    const name = convertToDartClassName(key);

    typedefs.push({
      name,
      type: `Map<Object, ${getDartType(object['*'])}>`,
    });

    return;
  }

  if (!object.type || typeof object.type === 'object') {
    // This is a class
    let fieldKeys = Object.keys(object).filter(k => k !== '*')

    if (key == '$root') {
      fieldKeys = fieldKeys.filter(f => f !== 'version');
    }

    const name = convertToDartClassName(key);

    let fields = fieldKeys.map(k => createField(k, key, object[k]));
    fields = fields.filter(f => f.type !== '*')

    classes.push({
      name: key === '$root' ? 'Style' : name,
      extends: classExtends[name],
      fields,
    });
  }
  else if (object.type === '*') {
    // This is a list
  }
  else if (object.type === 'enum') {
    // This is an enum
  }
  else if (object.type === 'array') {
    // This is a typedef
    const name = convertToDartClassName(key);
    const subtype = getDartType(object.value);

    typedefs.push({
      name,
      type: `List<${subtype}>`,
    });
  }
  else {
    throw new Error(`Unknown type: [${object.type}] in [${key}]`);
  }
}

for (const key in reference) {
  parseTopLevelObject(key, reference[key]);
}

// Apply typedefs
for (const $class of classes) {
  const { fields } = $class;

  for (const field of fields) {
    const { type } = field;

    const found = typedefs.find(t => t.name === type);
    if (found) {
      field.type = found.type;
    }
  }
}

// Dump JSON to file
const fs = require('fs');

const content = {
  classes,
  enums,
  typedefs,
};

fs.writeFileSync('style.gen.temp.json', JSON.stringify(content, null, 2));

const getGeneratedFieldType = (field) => {
  const { name, type, isRequired, defaultValue, propertyType, doc } = field;
  const hasDefaultValue = defaultValue !== undefined;

  const _isRequired = isRequired || hasDefaultValue;
  const hasPropertyType = propertyType !== undefined;
  let _type = type;

  if (propertyType === 'data-driven') {
    _type = `DataDrivenProperty<${type}>`;
  }
  else if (propertyType === 'cross-faded') {
    _type = `CrossFadedProperty<${type}>`;
  }
  else if (propertyType === 'cross-faded-data-driven') {
    _type = `CrossFadedDataDrivenProperty<${type}>`;
  }
  else if (propertyType === 'color-ramp') {
    _type = `ColorRampProperty`;
  }
  else if (propertyType === 'data-constant') {
    _type = `DataConstantProperty<${type}>`;
  }
  else if (propertyType === 'constant') {
    _type = `ConstantProperty<${type}>`;
  }

  return _type;
}

const generateClassConstConstructor = ($class) => {
  const { name, extends: $extends, fields } = $class;
  const code = [];

  code.push(`  const ${name}({`);

  for (const field of fields) {
    const { name, isRequired, defaultValue } = field;
    const hasDefaultValue = defaultValue !== undefined;

    code.push(`    ${isRequired || hasDefaultValue ? 'required ' : ''}this.${name},`);
  }

  code.push(`  });`);

  return code;
}

const generateFieldDefaultValue = (field) => {
  const { name, type, isRequired, defaultValue, propertyType, doc } = field;
  const _type = getGeneratedFieldType(field);
}

const generateWithDefaultsFactory = ($class) => {
  const { name, extends: $extends, fields } = $class;
  const code = [];

  code.push(`  factory ${name}.withDefaults({`);

  for (const field of fields) {
    const { name, isRequired, defaultValue } = field;
    const fieldType = getGeneratedFieldType(field);
    const hasDefaultValue = defaultValue !== undefined;

    const _isRequired = isRequired && !hasDefaultValue;

    code.push(`    ${_isRequired ? 'required ' : ''}${fieldType}${_isRequired ? '' : '?'} ${name},`);
  }

  code.push(`  }) {`);
  code.push(`    return ${name}(`);

  for (const field of fields) {
    let { name, isRequired, type, defaultValue } = field;
    const hasDefaultValue = defaultValue !== undefined;
    const hasPropertyType = field.propertyType !== undefined;
    const _type = getGeneratedFieldType(field);

    const isTypeEnum = enums.find(e => e.name === type);

    if (hasDefaultValue) {
      if (isTypeEnum) {
        defaultValue = `${type}.${convertToDartVariableName(defaultValue)}`;
      }
      if (type.startsWith('List<')) {
        if (type === 'List<String>') {
          defaultValue = `const [${defaultValue.map(v => `'${v}'`).join(', ')}]`;
        }
        else {
          defaultValue = `${type}.from([${defaultValue}])`;
        }
      }
      if (type === 'Color') {
        defaultValue = `Color.fromJson('${defaultValue}')`;
      }
      if (type === 'Padding') {
        defaultValue = `Padding.fromJson([${defaultValue}])`;
      }
      if (type === 'Formatted') {
        if (defaultValue.length === 0) {
          defaultValue = 'const Formatted.empty()';
        }
        else {
          defaultValue = `Formatted.parse(${defaultValue})`;
        }
      }
    }

    let _line = `      ${name}: ${name}`;

    if (hasDefaultValue) {
      if (hasPropertyType) {
        _line += `?.withDefaultValue(${defaultValue})`;
      }

      _line += ` ?? `;

      if (hasPropertyType) {
        _line += `${_type}.value(${defaultValue})`;
      }
      else {
        _line += defaultValue;
      }
    }

    _line += `,`;

    code.push(_line);
  }

  code.push(`    );`);
  code.push(`  }`);

  return code;
}

const generateFromJsonFactory = ($class) => {
  const { name, extends: $extends, fields } = $class;
  const code = [];

  code.push(`  factory ${name}.fromJson(Map<String, dynamic> json) {`);
  code.push(`    return ${name}.withDefaults(`);

  for (const field of fields) {
    const { rawName, name, isRequired, defaultValue } = field;
    const hasDefaultValue = defaultValue !== undefined;
    const type = getGeneratedFieldType(field);

    let _cast = `json['${rawName}'] as ${type}`;

    if (type.startsWith('List<')) {
      const subtype = type.substring(5, type.length - 1);

      if (type === 'List<List<num>>') {
        _cast = `(json['${rawName}'] as List).map((e) => (e as List).map((e) => e as num).toList()).toList()`;
      }
      else if (!dartJsonNativeTypes.includes(subtype)) {
        _cast = `(json['${rawName}'] as List).map((e) => ${subtype}.fromJson(e)).toList()`;
      }
      else {
        _cast = `(json['${rawName}'] as List).cast<${subtype}>()`;
      }
    }
    else if (type.startsWith('Map<')) {
      const subtype = type.substring(4, type.length - 1);
      const keyType = subtype.split(', ')[0];
      const valueType = subtype.split(', ')[1];

      if (!dartJsonNativeTypes.includes(valueType)) {
        _cast = `(json['${rawName}'] as Map).map((k, v) => MapEntry(k, ${valueType}.fromJson(v)))`;
      }
      else {
        _cast = `(json['${rawName}'] as Map).cast<${subtype}>()`;
      }
    }
    else if (type === 'Layout') {
      _cast = `Layout.fromJson(json['${rawName}'], type: Layer$Type.fromJson(json['type']))`;
    }
    else if (type === 'Paint') {
      _cast = `Paint.fromJson(json['${rawName}'], type: Layer$Type.fromJson(json['type']))`;
    }
    else if (!dartJsonNativeTypes.includes(type)) {
      if (!dartJsonNativeTypes.includes(type) && type !== type) {
        _cast = `${type}.fromJson(${type}.fromJson(json['${rawName}']))`;
      }
      else {
        _cast = `${type}.fromJson(json['${rawName}'])`;
      }
    }

    let _line = `      ${name}: `

    if (isRequired && !hasDefaultValue) {
      _line += `${_cast}`;
    }
    else {
      _line += `json['${rawName}'] != null? ${_cast} : null`;
    }

    _line += `,`;

    code.push(_line);
  }

  code.push(`    );`);
  code.push(`  }`);

  return code;
}

const generateFields = ($class) => {
  const { name, extends: $extends, fields } = $class;
  const code = [];

  for (const field of fields) {
    const isLast = fields.indexOf(field) === fields.length - 1;

    const { name, type, isRequired, defaultValue, propertyType, doc } = field;
    const hasDefaultValue = defaultValue !== undefined;

    const _isRequired = isRequired || hasDefaultValue;
    let _type = getGeneratedFieldType(field);

    if (doc && doc.length > 0) {
      for (const line of doc.split('\n')) {
        code.push(`  /// ${line}`);
      }
    }

    code.push(`  final ${_type}${_isRequired ? '' : '?'} ${name};`);

    if (!isLast) code.push('');
  }

  return code;
}

const _safeDartString = (str) => {
  // Prepend \ to $
  str = str.replace(/\$/g, '\\$');
  return str;
}

const generateDartCode = () => {
  const code = [];

  code.push(`// GENERATED CODE - DO NOT MODIFY BY HAND`);
  code.push(`// Generated by tool/generate_style_code.js`);

  code.push('');
  code.push(`import 'package:maplibre_style_spec/src/_src.dart';`);
  code.push('');

  for (const $class of classes) {
    const { name, extends: $extends, fields } = $class;

    if ($extends) {
      code.push(`class ${name} extends ${$extends} {`);
    }
    else {
      code.push(`class ${name} {`);
    }

    code.push(generateClassConstConstructor($class).join('\n'));
    code.push('');
    code.push(generateWithDefaultsFactory($class).join('\n'));
    code.push('');
    code.push(generateFromJsonFactory($class).join('\n'));
    code.push('');
    code.push(generateFields($class).join('\n'));

    code.push('}');
    code.push('');
  }

  for (const $enum of enums) {
    const { name, values } = $enum;
    const enumName = name;

    code.push(`enum ${name} {`);

    for (const value of values) {
      let isLast = values.indexOf(value) === values.length - 1;
      const { name, doc } = value;

      if (doc && doc.length > 0) {
        for (const line of doc.split('\n')) {
          code.push(`  /// ${line}`);
        }
      }

      code.push(`  ${name}${isLast ? ';' : ','}`);
    }

    code.push('');

    code.push(`  static ${name} fromJson(String json) {`);
    code.push(`    return switch (json) {`)

    for (const value of values) {
      const { rawName, name } = value;

      code.push(`      '${rawName}' => ${enumName}.${name},`);
    }

    code.push(`      _ => throw Exception('Unknown ${_safeDartString(name)}: \$json'),`);
    code.push(`    };`);
    code.push(`  }`);

    code.push('}');
    code.push('');
  }

  code.push('bool isTypeEnum<T>() {')
  code.push('  return switch(T) {')

  for (const $enum of enums) {
    const { name } = $enum;

    code.push(`    const (${name}) => true,`);
  }

  code.push(`    _ => false,`);
  code.push('  };');
  code.push('}');

  code.push('T parseEnumJson<T>(dynamic json) {');
  code.push('  return switch(T) {')

  for (const $enum of enums) {
    const { name } = $enum;

    code.push(`    const (${name}) => ${name}.fromJson(json) as T,`);
  }

  code.push(`    _ => throw Exception('Unknown enum type: \$T'),`);
  code.push('  };');
  code.push('}');

  code.push('bool isTypeEnumList<T>() {')
  code.push('  return switch(T) {')

  for (const $enum of enums) {
    const { name } = $enum;

    code.push(`    const (List<${name}>) => true,`);
  }

  code.push(`    _ => false,`);
  code.push('  };');
  code.push('}');

  code.push('T parseEnumListJson<T>(dynamic json) {');
  code.push('  return switch(T) {')

  for (const $enum of enums) {
    const { name } = $enum;

    code.push(`    const (List<${name}>) => (json as List).map((e) => ${name}.fromJson(e)).toList() as T,`);
  }

  code.push(`    _ => throw Exception('Unknown enum type: \$T'),`);
  code.push('  };');
  code.push('}');

  return code;
}

const dartCode = generateDartCode();

// Replace "Geojson" with "GeoJson" in the generated code
for (let i = 0; i < dartCode.length; i++) {
  dartCode[i] = dartCode[i].replace(/Geojson/g, 'GeoJson');
}

fs.writeFileSync(generatedLocation, dartCode.join('\n'));
