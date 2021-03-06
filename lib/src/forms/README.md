# Isotope Forms

Generate forms at runtime using serialized JSON schemas.

## Installation

Add the following to your `pubspec.yaml`:

```dart
dependencies:
  isotope:
    git: git://github.com/IsotopeLtd/isotope.git
    version: 1.0.0
```

## Implementation

Import the forms library in your dart source:

```dart
import 'package:isotope/forms.dart';
```


### Field Types

| Type | Description |
| --- | --- |
| `text` | Renders a single line text field |
| `multiline` | Renders a multiline text field (`maxLines` is set to `10`) |
| `password` | Renders a password text field (`obscureText` is set to `true`) |
| `creditcard` | Renders a credit card number text field (`keyboardType` is set to `TextInputType.number`) |
| `email` | Renders a single line email text field (`keyboardType` is set to `TextInputType.emailAddress`) |
| `phone` | Renders a single line phone number field (`keyboardType` is set to `TextInputType.phone`) |
| `url` | Renders a single line url address field (`keyboardType` is set to `TextInputType.url`) |
| `integer` | Renders a text field that only accepts integer numbers (`keyboardType` is set to `TextInputType.number`) |
| `decimal` | Renders a text field that only accepts decimal numbers (`keyboardType` is set to `TextInputType.numberWithOptions`) |
| `date` | Renders a text field with a button for a modal date selector dialog |
| `select` | Renders a dropdown select field |
| `radio` | Renders a vertical list of radio buttons preceded by a label |
| `checkbox` | Renders a checkbox control returning `true` or `false` |
| `switch` | Renders a switch control returning `true` or `false` |

### Text Field

Configuration:

| Key | Required | Value |
| --- | --- | --- |
| `name` | Yes | A name for the field - this is returned in the form response |
| `label` | No | Text you would like to appear as the placeholder and floating label |
| `type` | Yes | `text` |
| `required` | Yes | `true` or `false` |
| `length` | No | Sets maxLength property for the TextInputFormatter |
| `obscure` | No | Sets the obscureText property for the text field |

Example:

```dart
import 'dart:convert';

String schema = json.encode([
  {
    'name': 'Name',
    'type': 'text',
    'label': 'Your full name',
    'required': 'true',
    'length': '40'
  },
]);
```

### Multiline Field

Configuration:

| Key | Required | Value |
| --- | --- | --- |
| `name` | Yes | A name for the field - this is returned in the form response |
| `label` | No | Text you would like to appear as the placeholder and floating label |
| `type` | Yes | `multiline` |
| `required` | Yes | `true` or `false` |
| `length` | No | Sets maxLength property for the TextInputFormatter |
| `lines` | No | Sets the maxLines property for the text field - defaults to 10 |
| `obscure` | No | Sets the obscureText property for the text field |

Example:

```dart
import 'dart:convert';

String schema = json.encode([
  {
    'name': 'bio',
    'type': 'multiline',
    'label': 'A short bio',
    'required': 'false',
    'length': '300',
    'lines': '5'
  },
]);
```

### Password Field

Configuration:

| Key | Required | Value |
| --- | --- | --- |
| `name` | Yes | A name for the field - this is returned in the form response |
| `label` | No | Text you would like to appear as the placeholder and floating label |
| `type` | Yes | `password` |
| `required` | Yes | `true` or `false` |
| `length` | No | Sets maxLength property for the TextInputFormatter |

Example:

```dart
import 'dart:convert';

String schema = json.encode([
  {
    'name': 'pwd',
    'type': 'password',
    'label': 'Your password',
    'required': 'true'
  },
]);
```

### Credit Card Field

Configuration:

| Key | Required | Value |
| --- | --- | --- |
| `name` | Yes | A name for the field - this is returned in the form response |
| `label` | No | Text you would like to appear as the placeholder and floating label |
| `type` | Yes | `creditcard` |
| `required` | Yes | `true` or `false` |
| `length` | No | Sets maxLength property for the TextInputFormatter |
| `obscure` | No | Sets the obscureText property for the text field |

Example:

```dart
import 'dart:convert';

String schema = json.encode([
  {
    'name': 'creditcard',
    'type': 'creditcard',
    'label': 'Credit card number',
    'required': 'true'
  },
]);
```

### Email Field

Configuration:

| Key | Required | Value |
| --- | --- | --- |
| `name` | Yes | A name for the field - this is returned in the form response |
| `label` | No | Text you would like to appear as the placeholder and floating label |
| `type` | Yes | `email` |
| `required` | Yes | `true` or `false` |
| `length` | No | Sets maxLength property for the TextInputFormatter |
| `obscure` | No | Sets the obscureText property for the text field |

Example:

```dart
import 'dart:convert';

String schema = json.encode([
  {
    'name': 'email',
    'type': 'email',
    'label': 'Your email address',
    'required': 'true'
  },
]);
```

### Phone Field

Configuration:

| Key | Required | Value |
| --- | --- | --- |
| `name` | Yes | A name for the field - this is returned in the form response |
| `label` | No | Text you would like to appear as the placeholder and floating label |
| `type` | Yes | `phone` |
| `required` | Yes | `true` or `false` |
| `length` | No | Sets maxLength property for the TextInputFormatter |
| `obscure` | No | Sets the obscureText property for the text field |

Example:

```dart
import 'dart:convert';

String schema = json.encode([
  {
    'name': 'phone',
    'type': 'phone',
    'label': 'Your phone number',
    'required': 'false'
  },
]);
```

### URL Field

Configuration:

| Key | Required | Value |
| --- | --- | --- |
| `name` | Yes | A name for the field - this is returned in the form response |
| `label` | No | Text you would like to appear as the placeholder and floating label |
| `type` | Yes | `url` |
| `required` | Yes | `true` or `false` |
| `length` | No | Sets maxLength property for the TextInputFormatter |
| `obscure` | No | Sets the obscureText property for the text field |

Example:

```dart
import 'dart:convert';

String schema = json.encode([
  {
    'name': 'url',
    'type': 'url',
    'label': 'Your web site address',
    'required': 'false'
  },
]);
```

### Integer Field

Configuration:

| Key | Required | Value |
| --- | --- | --- |
| `name` | Yes | A name for the field - this is returned in the form response |
| `label` | No | Text you would like to appear as the placeholder and floating label |
| `type` | Yes | `integer` |
| `required` | Yes | `true` or `false` |

Example:

```dart
import 'dart:convert';

String schema = json.encode([
  {
    'name': 'engines',
    'type': 'integer',
    'label': 'Number of engines',
    'required': 'false'
  },
]);
```

### Decimal Field

Configuration:

| Key | Required | Value |
| --- | --- | --- |
| `name` | Yes | A name for the field - this is returned in the form response |
| `label` | No | Text you would like to appear as the placeholder and floating label |
| `type` | Yes | `integer` |
| `required` | Yes | `true` or `false` |

Example:

```dart
import 'dart:convert';

String schema = json.encode([
  {
    'name': 'price',
    'type': 'decimal',
    'label': 'Price of engine',
    'required': 'true'
  },
]);
```

### Date Field

Configuration:

| Key | Required | Value |
| --- | --- | --- |
| `name` | Yes | A name for the field - this is returned in the form response |
| `label` | No | Text you would like to appear as the placeholder and floating label |
| `type` | Yes | `date` |
| `required` | Yes | `true` or `false` |

Example:

```dart
import 'dart:convert';

String schema = json.encode([
  {
    'name': 'dob',
    'type': 'date',
    'label': 'Date of birth',
    'required': 'true'
  },
]);
```

### Select Field

Configuration:

| Key | Required | Value |
| --- | --- | --- |
| `name` | Yes | A name for the field - this is returned in the form response |
| `label` | No | Text you would like to appear as the placeholder and floating label |
| `type` | Yes | `select` |
| `required` | Yes | `true` or `false` |
| `options` | Yes | An array of string values, see example below |

Example:

```dart
import 'dart:convert';

String schema = json.encode([
  {
    'name': 'ageGroup',
    'type': 'select',
    'label': 'Your age group',
    'required': 'false',
    'options': ['1-20', '21-30', '31-40', '41-50', '51-60']
  },
]);
```

### Radio Buttons Field

Configuration:

| Key | Required | Value |
| --- | --- | --- |
| `name` | Yes | A name for the field - this is returned in the form response |
| `type` | Yes | `radio` |
| `label` | Yes | Text you would like to appear as the options list label |
| `required` | Yes | `true` or `false` |
| `options` | Yes | An array of string values, see example below |

Example:

```dart
import 'dart:convert';

String schema = json.encode([
  {
    'name': 'color',
    'type': 'radio',
    'label': 'Your favorite color',
    'required': 'false',
    'options': ['red', 'green', 'blue'],
  },
]);
```

### Checkbox Field

Configuration:

| Key | Required | Value |
| --- | --- | --- |
| `name`  | Yes | A name for the field - this is returned in the form response |
| `type`  | Yes | `checkbox` |
| `label` | Yes | Text you would like to appear as the checkbox label |

Example:

```dart
import 'dart:convert';

String schema = json.encode([
  {
    'name': 'agreement',
    'type': 'checkbox',
    'label': 'I agree to the Terms & Conditions'
  },
]);
```

### Switch Field

Configuration:

| Key | Required | Value |
| --- | --- | --- |
| `name`  | Yes | A name for the field - this is returned in the form response |
| `type`  | Yes | `switch` |
| `label` | Yes | Text you would like to appear as the switch label |

Example:

```dart
import 'dart:convert';

String schema = json.encode([
  {
    'name': 'dark',
    'type': 'switch',
    'label': 'Enable dark theme'
  },
]);
```

### Forms

The `FormGenerator` class accepts a `schema` and an optional map of `values`. The schema should be passed as a `String` and the values as a `Map`.

Example:

```dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:isotope/forms.dart';

class DynamicForm extends StatefulWidget {
  @override
  _DynamicFormState createState() => _DynamicFormState();
}

class _DynamicFormState extends State<DynamicForm> {
  // Dynamic response to store your form data:
  dynamic response;

  // Set the form key for validation:
  var _formkey = GlobalKey<FormState>();

  // Define the forms fields as encode as a String:
  String _schema = json.encode([
    {
      'name': 'Name',
      'type': 'text',
      'label': 'Your full name',
      'required': 'true',
      'length': '40',
    },
    {
      'name': 'dob',
      'type': 'date',
      'label': 'Date of birth',
      'required': 'true',
    },
  ]);

  // Define some default initial values as a Map:
  Map<String, dynamic> _values = { 
    'name': 'Fred Flintstone', 
    'dob': '1970-02-01', 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Dynamic Form"),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formkey, // add the formkey here
          child: Column(children: <Widget>[
            FormGenerator(
              schema: _schema, // add the schema here
              values: _values, // add the initial value map here
              onChanged: (dynamic value) {
                setState(() {
                  this.response = value;
                });
              },
            ),
            new RaisedButton(
              child: new Text('Save'),
              onPressed: () {
                if (_formkey.currentState.validate()) {
                  print(this.response.toString());
                }
              },
            ),
          ]),
        ),
      ),
    );
  }
}
```

## License

This library is available as open source under the terms of the MIT License.

## Copyright

Copyright © 2020 Jurgen Jocubeit
