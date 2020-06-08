import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:isotope/src/formatters/credit_card_number_input_formatter.dart';
import 'package:isotope/src/formatters/date_input_formatter.dart';
import 'package:isotope/src/formatters/thousands_number_input_formatter.dart';

class FormGenerator extends StatefulWidget {
  final String schema;
  final ValueChanged<Map> onChanged;
  final Map values;

  FormGenerator({@required this.schema, @required this.onChanged, this.values});

  @override
  _FormGeneratorState createState() => _FormGeneratorState(json.decode(schema));
}

class _FormGeneratorState extends State<FormGenerator> {
  final dynamic formItems;
  final Map<String, dynamic> formResults = {};

  Map<String, dynamic> _radioValueMap = {};
  Map<String, String> _dropDownMap = {};
  Map<String, String> _datevalueMap = {};
  Map<String, bool> _booleanValueMap = {};

  Map _values;
  _FormGeneratorState(this.formItems);

  @override
  void initState() {
    _values = widget.values;
    print(_values);
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

  void _updateBooleanMapValue(dynamic item, bool value) {
    setState(() {
      _booleanValueMap[item] = value;
    });
  }

  List<Widget> _buildForm() {
    List<Widget> listWidget = new List<Widget>();

    for (var item in formItems) {
      if (item['type'] == 'text' ||
          item['type'] == 'password' ||
          item['type'] == 'creditcard' ||
          item['type'] == 'email' ||
          item['type'] == 'phone' ||
          item['type'] == 'decimal' ||
          item['type'] == 'integer') {
        listWidget.add(
          Container(
            margin: EdgeInsets.symmetric(vertical: 10.0),
            child: TextFormField(
              initialValue: _values != null ? _values[item['name']] : null,
              autofocus: false,
              onChanged: (String value) {
                formResults[item['name']] = value;
                _handleChanged();
              },
              inputFormatters: _determineFormatters(item['type'], item['length']),
              keyboardType: _determineKeyboard(item['type']),
              validator: (String value) {
                if (item['required'] == 'no') {
                  return null;
                }
                if (value.isEmpty) {
                  return '${item['name']} cannot be empty';
                }
                return null;
              },
              maxLines: 1,
              obscureText: _determineObscurity(item['type'], item['obscure']),
              decoration: InputDecoration(
                contentPadding: EdgeInsets.fromLTRB(10, 5, 10, 0),
                labelText: item['label'],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5.0)
                ),
              ),
            ),
          ),
        );
      }

      if (item['type'] == 'multiline') {
        listWidget.add(
          Container(
            margin: EdgeInsets.symmetric(vertical: 10.0),
            child: TextFormField(
              initialValue: _values != null ? _values[item['name']] : null,
              autofocus: false,
              onChanged: (String value) {
                formResults[item['name']] = value;
                _handleChanged();
              },
              inputFormatters: _determineFormatters(item['type'], item['length']),
              keyboardType: _determineKeyboard(item['type']),
              validator: (String value) {
                if (item['required'] == 'no') {
                  return null;
                }
                if (value.isEmpty) {
                  return '${item['name']} cannot be empty';
                }
                return null;
              },
              maxLines: item['lines'] != null ? int.parse(item['lines']) : 10,
              obscureText: _determineObscurity(item['type'], item['obscure']),
              decoration: InputDecoration(
                contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                labelText: item['label'],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5.0)
                ),
              ),
            ),
          ),
        );
      }

      if (item['type'] == 'select') {
        var newlist = List<String>.from(item['items']);

        listWidget.add(Container(
          margin: EdgeInsets.symmetric(vertical: 10.0),
          child: DropdownButtonFormField<String>(
            decoration: InputDecoration(
              contentPadding: EdgeInsets.fromLTRB(10, 0, 10, 0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5.0)
              ),
            ),
            hint: Text('Select ${item['name']}'),
            validator: (String value) {
              if (item['required'] == 'no') {
                return null;
              }
              if (value == null) {
                return '${item['name']} cannot be empty';
              }
              return null;
            },
            value: _dropDownMap[item['name']],
            isExpanded: true,
            style: Theme.of(context).textTheme.subtitle1,
            onChanged: (String newValue) {
              setState(() {
                _dropDownMap[item['name']] = newValue;
                formResults[item['name']] = newValue.trim();
              });
              _handleChanged();
            },
            items: newlist.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ));
      }

      if (item['type'] == 'date') {
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
            setState(() => _datevalueMap[item['name']] = picked.toString().substring(0, 10));
          }
        }

        listWidget.add(
          Container(
            margin: EdgeInsets.symmetric(vertical: 10.0),
            child: TextFormField(
              initialValue: _values != null ? _values[item['name']] : null,
              autofocus: false,
              readOnly: true,
              controller: TextEditingController(text: _datevalueMap[item['name']]),
              inputFormatters: _determineFormatters(item['type'], null),
              validator: (String value) {
                if (value.isEmpty) {
                  return '${item['name']} cannot be empty';
                }
                return null;
              },
              onChanged: (String value) {
                _handleChanged();
              },
              onTap: () async {
                await _selectDate();
                formResults[item['name']] = _datevalueMap[item['name']];
                _handleChanged();
              },
              decoration: InputDecoration(
                contentPadding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                labelText: item['label'],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5.0)
                ),
                suffixIcon: Icon(
                  Icons.calendar_today,
                ),
              ),
            )
          ),
        );
      }

      if (item['type'] == 'radio') {
        _radioValueMap["${item['name']}"] =
            _radioValueMap["${item['name']}"] == null
                ? 'none'
                : _radioValueMap["${item['name']}"];

        listWidget.add(
          new Container(
            margin: new EdgeInsets.only(top: 5.0, bottom: 5.0),
            child: new Text(
              item['label'],
              style: new TextStyle(
                fontWeight: FontWeight.bold, 
                fontSize: 16.0
              )
            )
          )
        );

        for (var i = 0; i < item['items'].length; i++) {
          listWidget.add(
            new Row(
              children: <Widget>[
                new Expanded(child: new Text(item['items'][i])),
                new Radio<dynamic>(
                    // hoverColor: Colors.red,
                    value: item['items'][i],
                    groupValue: _radioValueMap["${item['name']}"],
                    onChanged: (dynamic value) {
                      setState(() {
                        _radioValueMap["${item['name']}"] = value;
                      });
                      formResults[item['name']] = value;
                      _handleChanged();
                    })
              ],
            ),
          );
        }
      }

      if (item['type'] == 'checkbox') {
        if (_booleanValueMap["${item['name']}"] == null) {
          setState(() {
            _booleanValueMap["${item['name']}"] = false;
          });
        }
        listWidget.add(
          Row(
            children: <Widget>[
              new Expanded(child: new Text(item['label'])),
              Checkbox(
                value: _booleanValueMap["${item['name']}"],
                onChanged: (bool value) {
                  _updateBooleanMapValue(item['name'], value);
                  formResults[item['name']] = value;
                  _handleChanged();
                }
              ),
            ],
          )
        );
      }

      if (item['type'] == 'switch') {
        if (_booleanValueMap["${item['name']}"] == null) {
          setState(() {
            _booleanValueMap["${item['name']}"] = false;
          });
        }
        listWidget.add(
          Row(
            children: <Widget>[
              new Expanded(child: new Text(item['label'])),
              Switch(
                value: _booleanValueMap["${item['name']}"],
                onChanged: (bool value) {
                  _updateBooleanMapValue(item['name'], value);
                  formResults[item['name']] = value;
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

  List<TextInputFormatter> _determineFormatters(String type, String length) {
    List<TextInputFormatter> formatters = new List<TextInputFormatter>();
    int maxLength;

    if (length != null) {
      maxLength = int.parse(length);
    }

    switch(type) {
      case 'integer':
        formatters.add(ThousandsNumberInputFormatter());
        if (maxLength != null) {
          formatters.add(LengthLimitingTextInputFormatter(maxLength));
        } 
        break;
      case 'decimal':
        formatters.add(ThousandsNumberInputFormatter(allowFraction: true));
        if (maxLength != null) {
          formatters.add(LengthLimitingTextInputFormatter(maxLength));
        } 
        break;
      case 'creditcard':
        formatters.add(CreditCardNumberInputFormatter());
        break;
      case 'date':
        formatters.add(DateInputFormatter());
        break;
      case 'phone':
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
      case 'creditcard':
        textInputType = TextInputType.number;
        break;
      case 'email':
        textInputType = TextInputType.emailAddress;
        break;
      case 'multiline':
        textInputType = TextInputType.multiline;
        break;
      case 'phone':
        textInputType = TextInputType.phone;
        break;
      case 'url':
        textInputType = TextInputType.url;
        break;
      case 'integer':
        textInputType = TextInputType.number;
        break;
      case 'decimal':
        textInputType = TextInputType.numberWithOptions(decimal: true);
        break;
      case 'date':
        textInputType = TextInputType.datetime;
        break;
      default:
        textInputType = null;
        break;
    }

    return textInputType;
  }

  bool _determineObscurity(String type, String obscure) {
    bool obscurity = false;

    if (type == 'password' || obscure == 'yes') {
      obscurity = true;
    }

    return obscurity;
  }
}
