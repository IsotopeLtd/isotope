import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:isotope/formatters.dart';
import 'package:isotope/src/forms/form_field_types.dart';

class FormGenerator extends StatefulWidget {
  final String schema;
  final ValueChanged<Map> onChanged;
  final Map values;

  FormGenerator({@required this.schema, @required this.onChanged, this.values});

  @override
  _FormGeneratorState createState() => _FormGeneratorState(json.decode(schema));
}

class _FormGeneratorState extends State<FormGenerator> {
  final dynamic formFields;
  final Map<String, dynamic> formResults = {};

  Map<String, dynamic> _radioValueMap = {};
  Map<String, String> _selectValueMap = {};
  Map<String, String> _dateValueMap = {};
  Map<String, bool> _booleanValueMap = {};

  _FormGeneratorState(this.formFields);

  @override
  void initState() {
    widget.values.forEach((key, value) {
      var field = formFields[key];
      switch(field['type']) {
        case FormFieldType.CheckboxField:
          if (value.toString().toLowerCase() == 'yes') {
            _booleanValueMap[key] = true;
          } else {
            _booleanValueMap[key] = false;
          }
          break;
        case FormFieldType.DateField:
          _dateValueMap[key] = value;
          break;
        case FormFieldType.RadioField:
          _radioValueMap[key] = value;
          break;
        case FormFieldType.SelectField:
          _selectValueMap[key] = value;
          break;
        case FormFieldType.SwitchField:
          if (value.toString().toLowerCase() == 'yes') {
            _booleanValueMap[key] = true;
          } else {
            _booleanValueMap[key] = false;
          }
          break;
      }
    });
    print(widget.values);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      padding: EdgeInsets.all(30),
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: _buildForm(),
      ),
    );
  }

  void _handleChanged() {
    widget.onChanged(formResults);
  }

  List<Widget> _buildForm() {
    List<Widget> listWidget = new List<Widget>();

    for (var field in formFields) {
      String _fieldType = field['type'];
      String _fieldName = field['name'];
      String _fieldLabel = field['label'];
      int _fieldLength = int.tryParse(field['length']);
      bool _fieldRequired = field['required'] == 'yes' ? true : false;

      if (_fieldType == FormFieldType.TextField || 
          _fieldType == FormFieldType.PasswordField || 
          _fieldType == FormFieldType.CreditCardField || 
          _fieldType == FormFieldType.EmailField || 
          _fieldType == FormFieldType.PhoneField || 
          _fieldType == FormFieldType.UrlField || 
          _fieldType == FormFieldType.DecimalField || 
          _fieldType == FormFieldType.IntegerField) {
        listWidget.add(
          Container(
            margin: EdgeInsets.symmetric(vertical: 10.0),
            child: TextFormField(
              initialValue: widget.values[_fieldName],
              autofocus: false,
              onChanged: (String value) {
                formResults[_fieldName] = value;
                _handleChanged();
              },
              inputFormatters: _determineFormatters(_fieldType, _fieldLength),
              keyboardType: _determineKeyboard(_fieldType),
              validator: (String value) {
                if (value.isEmpty && _fieldRequired) {
                  return '${_fieldName} cannot be empty';
                }
                else {
                  return null;
                }
              },
              maxLines: 1,
              obscureText: _determineObscurity(_fieldType, field['obscure']),
              decoration: InputDecoration(
                contentPadding: EdgeInsets.fromLTRB(10, 5, 10, 0),
                labelText: _fieldLabel,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5.0)
                ),
              ),
            ),
          ),
        );
      }

      if (_fieldType == FormFieldType.MultilineTextField) {
        listWidget.add(
          Container(
            margin: EdgeInsets.symmetric(vertical: 10.0),
            child: TextFormField(
              initialValue: widget.values[_fieldName],
              autofocus: false,
              onChanged: (String value) {
                formResults[_fieldName] = value;
                _handleChanged();
              },
              inputFormatters: _determineFormatters(_fieldType, _fieldLength),
              keyboardType: _determineKeyboard(_fieldType),
              validator: (String value) {
                if (value.isEmpty && _fieldRequired) {
                  return '${_fieldName} cannot be empty';
                } else {
                  return null;
                }
              },
              maxLines: _determineMaxLines(field['lines'], 10),
              obscureText: _determineObscurity(_fieldType, field['obscure']),
              decoration: InputDecoration(
                contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                labelText: _fieldLabel,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5.0)
                ),
              ),
            ),
          ),
        );
      }

      if (_fieldType == FormFieldType.SelectField) {
        var _items = List<String>.from(field['options']);
        listWidget.add(Container(
          margin: EdgeInsets.symmetric(vertical: 10.0),
          child: DropdownButtonFormField<String>(
            decoration: InputDecoration(
              contentPadding: EdgeInsets.fromLTRB(10, 0, 10, 0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5.0)
              ),
            ),
            hint: Text('Select ${_fieldName}'),
            validator: (String value) {
              if (value == null && _fieldRequired) {
                return '${_fieldName} cannot be empty';
              } else {
                return null;
              }
            },
            value: _selectValueMap[_fieldName],
            isExpanded: true,
            style: Theme.of(context).textTheme.subtitle1,
            onChanged: (String newValue) {
              setState(() {
                _selectValueMap[_fieldName] = newValue;
                formResults[_fieldName] = newValue.trim();
              });
              _handleChanged();
            },
            items: _items.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ));
      }

      if (_fieldType == FormFieldType.DateField) {
        Future _selectDate() async {
          DateTime picked = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(1880),
            lastDate: DateTime(2021),
            builder: (BuildContext context, Widget child) {
              return Theme(
                data: ThemeData.light(),
                child: child,
              );
            },
          );
          if (picked != null) {
            setState(() => _dateValueMap[_fieldName] = picked.toString().substring(0, 10));
          }
        }

        listWidget.add(
          Container(
            margin: EdgeInsets.symmetric(vertical: 10.0),
            child: TextFormField(
              initialValue: widget.values[_fieldName],
              autofocus: false,
              readOnly: true,
              controller: TextEditingController(text: _dateValueMap[_fieldName]),
              inputFormatters: _determineFormatters(_fieldType, null),
              validator: (String value) {
                if (value.isEmpty && _fieldRequired) {
                  return '${_fieldName} cannot be empty';
                } else {
                  return null;
                }
              },
              onChanged: (String value) {
                _handleChanged();
              },
              onTap: () async {
                await _selectDate();
                formResults[_fieldName] = _dateValueMap[_fieldName];
                _handleChanged();
              },
              decoration: InputDecoration(
                contentPadding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                labelText: _fieldLabel,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5.0)
                ),
                suffixIcon: Icon(
                  Icons.calendar_today,
                ),
              ),
            ),
          ),
        );
      }

      if (_fieldType == FormFieldType.RadioField) {
        _radioValueMap[_fieldName] =
            _radioValueMap[_fieldName] == null ? 'none' : _radioValueMap[_fieldName];

        listWidget.add(
          new Container(
            margin: new EdgeInsets.only(top: 5.0, bottom: 5.0),
            child: new Text(
              _fieldLabel,
              style: new TextStyle(
                fontWeight: FontWeight.bold, 
                fontSize: 16.0
              ),
            ),
          ),
        );

        for (var i = 0; i < field['options'].length; i++) {
          listWidget.add(
            new Row(
              children: <Widget>[
                new Expanded(child: new Text(field['options'][i])),
                new Radio<dynamic>(
                  value: field['options'][i],
                  groupValue: _radioValueMap[_fieldName],
                  onChanged: (dynamic value) {
                    setState(() {
                      _radioValueMap[_fieldName] = value;
                    });
                    formResults[_fieldName] = value;
                    _handleChanged();
                  }
                )
              ],
            ),
          );
        }
      }

      if (_fieldType == FormFieldType.CheckboxField) {
        if (_booleanValueMap[_fieldName] == null) {
          setState(() {
            _booleanValueMap[_fieldName] = false;
          });
        }
        listWidget.add(
          Row(
            children: <Widget>[
              new Expanded(child: new Text(_fieldLabel)),
              Checkbox(
                value: _booleanValueMap[_fieldName],
                onChanged: (bool value) {
                  _booleanValueMap[_fieldName] = value;
                  formResults[_fieldName] = value;
                  _handleChanged();
                }
              ),
            ],
          )
        );
      }

      if (_fieldType == FormFieldType.SwitchField) {
        if (_booleanValueMap[_fieldName] == null) {
          setState(() {
            _booleanValueMap[_fieldName] = false;
          });
        }
        listWidget.add(
          Row(
            children: <Widget>[
              new Expanded(child: new Text(_fieldLabel)),
              Switch(
                value: _booleanValueMap[_fieldName],
                onChanged: (bool value) {
                  _booleanValueMap[_fieldName] = value;
                  formResults[_fieldName] = value;
                  _handleChanged();
                }
              ),
            ],
          )
        );
      }
    }
    return listWidget;
  }

  List<TextInputFormatter> _determineFormatters(String type, int length) {
    List<TextInputFormatter> formatters = new List<TextInputFormatter>();
    switch(type) {
      case FormFieldType.IntegerField:
        formatters.add(ThousandsNumberInputFormatter());
        if (length != null) {
          formatters.add(LengthLimitingTextInputFormatter(length));
        } 
        break;
      case FormFieldType.DecimalField:
        formatters.add(ThousandsNumberInputFormatter(allowFraction: true));
        if (length != null) {
          formatters.add(LengthLimitingTextInputFormatter(length));
        } 
        break;
      case FormFieldType.CreditCardField:
        formatters.add(CreditCardNumberInputFormatter());
        break;
      case FormFieldType.DateField:
        formatters.add(DateInputFormatter());
        break;
      case FormFieldType.PhoneField:
        formatters.add(WhitelistingTextInputFormatter.digitsOnly);
        break;
      default:
        return null;
    }
    return formatters;
  }

  TextInputType _determineKeyboard(String type) {
    TextInputType textInputType;
    switch(type) {
      case FormFieldType.CreditCardField:
        textInputType = TextInputType.number;
        break;
      case FormFieldType.EmailField:
        textInputType = TextInputType.emailAddress;
        break;
      case FormFieldType.MultilineTextField:
        textInputType = TextInputType.multiline;
        break;
      case FormFieldType.PhoneField:
        textInputType = TextInputType.phone;
        break;
      case FormFieldType.UrlField:
        textInputType = TextInputType.url;
        break;
      case FormFieldType.IntegerField:
        textInputType = TextInputType.number;
        break;
      case FormFieldType.DecimalField:
        textInputType = TextInputType.numberWithOptions(decimal: true);
        break;
      case FormFieldType.DateField:
        textInputType = TextInputType.datetime;
        break;
      default:
        textInputType = null;
    }
    return textInputType;
  }

  bool _determineObscurity(String type, String obscure) {
    bool obscurity = false;
    if (type == FormFieldType.PasswordField || obscure == 'yes') {
      obscurity = true;
    }
    return obscurity;
  }

  int _determineMaxLines(String lines, int defaultMaxLines) {
    int maxLines = 10;
    int result = int.tryParse(lines);
    if (lines != null) {
      maxLines = result;
    }
    return maxLines;
  }
}
